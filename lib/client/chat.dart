import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:quicksend/client/internal/utils.dart';

import 'internal/crypto_utils.dart';
import 'internal/db.dart';
import 'internal/db_models/db_message.dart';
import 'internal/login_manager.dart';
import 'internal/request_manager.dart';
import 'models.dart';

/// An object that represents an open chat with a certain user.
class Chat {
  final String recipientId;

  final _recipientInfo = CachedValue<UserInfo?>();
  final List<Message> _messages = [];
  final StreamController<Message> _messageStreamController =
      StreamController.broadcast();
  final ClientDB _db;
  final LoginManager _loginManager;
  final RequestManager _requestManager;
  final String _userId;

  Chat(
    this._db,
    this._loginManager,
    this._requestManager,
    this.recipientId,
    this._userId,
  );

  Future<UserInfo?> getRecipient() {
    return _recipientInfo
        .get(() => _requestManager.getUserInfoFor(recipientId));
  }

  /// Loads the messages for this chat and broadcasts them to [messageStream].
  Future<void> loadMessages() async {
    final messages = await _loadMessagesFromDB();
    messages.forEach(_broadcastMessage);
  }

  /// A stream containing all messages sent in this chat, updated live as new
  /// messages come in.
  Stream<Message> get messageStream {
    return _messageStreamController.stream;
  }

  /// Returns a list of all messages that have been sent in this chat up until
  /// now.
  List<Message> getMessages() {
    return _messages;
  }

  /// Send a plain text message in this chat.
  Future<void> sendTextMessage(String body) {
    return sendMessage("text/plain", Uint8List.fromList(utf8.encode(body)));
  }

  /// Send a raw message in this chat; [type] is the MIME type of the message's
  /// content, and [body] the content in binary format. Additional [headers] can
  /// optionally be added.
  Future<void> sendMessage(
    String type,
    Uint8List body, {
    Map<String, String>? headers,
  }) async {
    final sentAt = DateTime.now();
    final key = await CryptoUtils.generateKey();
    final iv = await CryptoUtils.generateIV();
    final encryptedBody = await CryptoUtils.encrypt(body, key, iv);

    await _requestManager.sendMessage(
      await _loginManager.getAuthenticator(),
      recipientId,
      sentAt,
      {"type": type, ...(headers ?? {})},
      await _getEncryptedKeys(key),
      base64.encode(iv),
      base64.encode(encryptedBody),
    );

    await saveMessage(Message(type, MessageDirection.outgoing, sentAt, body));
  }

  /// Saves a message to this device WITHOUT sending it to the server.
  ///
  /// Unless you know what you are doing, consider using [sendMessage]
  /// or [sendTextMessage] instead.
  Future<void> saveMessage(Message message) async {
    _loginManager.assertLoggedIn();
    final encryptionKey = await _db.getEncryptionPublicKey();
    assert(encryptionKey != null);
    final key = await CryptoUtils.generateKey();
    final iv = await CryptoUtils.generateIV();
    final encryptedBody = await CryptoUtils.encrypt(message.content, key, iv);
    final encryptedKey =
        await CryptoUtils.encryptKey(key, encryptionKey as String);

    final dbMessage = DBMessage(
      message.type,
      message.direction == MessageDirection.incoming,
      message.sentAt,
      encryptedBody,
      recipientId,
      encryptedKey,
      iv,
    );
    _db.addMessage(recipientId, dbMessage);
    _broadcastMessage(message);
  }

  Future<List<Message>> _loadMessagesFromDB() async {
    final List<DBMessage> dbMessages = _db.getMessages(recipientId);
    return await Future.wait(List.from(
      dbMessages.where((msg) => msg.user == _userId).map(_decryptDBMessage),
    ));
  }

  void _broadcastMessage(Message message) {
    _messageStreamController.add(message);
    _messages.add(message);
  }

  Future<Message> _decryptDBMessage(DBMessage dbMessage) async {
    final encKey = await _db.getEncryptionKey();
    assert(encKey != null);
    final msgKey = await CryptoUtils.decryptKey(
      dbMessage.key,
      encKey as String,
    );
    final messageContent = await CryptoUtils.decrypt(
      dbMessage.content,
      msgKey,
      dbMessage.iv,
    );
    return Message(
      dbMessage.type,
      dbMessage.incoming
          ? MessageDirection.incoming
          : MessageDirection.outgoing,
      dbMessage.sentAt,
      messageContent,
    );
  }

  Future<Map<String, String>> _getEncryptedKeys(Uint8List key) async {
    final Map<String, String> deviceKeyMap = await _getTargetKeys();
    final List<MapEntry<String, String>> encKeyMapEntries = await Future.wait(
      deviceKeyMap.entries.map(
        (e) async => MapEntry(
          e.key,
          base64.encode(await CryptoUtils.encryptKey(key, e.value)),
        ),
      ),
    );
    final deviceEncKeyMap = Map.fromEntries(encKeyMapEntries);
    return deviceEncKeyMap;
  }

  Future<Map<String, String>> _getTargetKeys() async {
    return await _requestManager.getMessageTargets(
      await _loginManager.getAuthenticator(),
      recipientId,
    );
  }
}
