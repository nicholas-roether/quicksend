import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

import 'internal/utils.dart';

import 'internal/crypto_utils.dart';
import 'internal/db.dart';
import 'internal/db_models/db_message.dart';
import 'internal/login_manager.dart';
import 'internal/request_manager.dart';
import 'models.dart';

/// An object that represents an open chat with a certain user.
class Chat extends ChangeNotifier {
  /// The ID of the user this chat is with
  final String recipientId;

  final _recipientInfo = CachedValue<UserInfo?>();
  final List<Message> _messages = [];
  final ClientDB _db;
  final LoginManager _loginManager;
  final RequestManager _requestManager;

  Chat(this.recipientId,
      {required ClientDB db,
      required LoginManager loginManager,
      required RequestManager requestManager})
      : _db = db,
        _loginManager = loginManager,
        _requestManager = requestManager;

  /// Loads all saved messages for this chat and broadcasts them.
  void loadSavedMessages() {
    final messages = _loadMessagesFromDB();
    messages.forEach(_addMessage);
    notifyListeners();
  }

  /// Get the user info for the user this chat is with.
  /// Returns null if that user no longer exists.
  Future<UserInfo?> getRecipient() {
    return _recipientInfo
        .get(() => _requestManager.getUserInfoFor(recipientId));
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
    final dbMessage = DBMessage(
      message.type,
      message.direction == MessageDirection.incoming,
      message.sentAt,
      message.content,
    );
    _db.addMessage(recipientId, dbMessage);
    _sortMessages();
    _addMessage(message);
    notifyListeners();
  }

  void _sortMessages() {
    _messages.sort((msg1, msg2) => msg1.sentAt.compareTo(msg2.sentAt));
  }

  List<Message> _loadMessagesFromDB() {
    final List<DBMessage> dbMessages = _db.getMessages(recipientId);
    return List.from(dbMessages.map(
      (dbMsg) => Message(
        dbMsg.type,
        dbMsg.incoming ? MessageDirection.incoming : MessageDirection.outgoing,
        dbMsg.sentAt,
        dbMsg.content,
      ),
    ));
  }

  void _addMessage(Message message) {
    _messages.add(message);
    _sortMessages();
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
