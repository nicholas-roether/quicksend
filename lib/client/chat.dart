import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:quicksend/client/exceptions.dart';
import 'package:quicksend/client/internal/db_models/db_chat.dart';
import 'package:uuid/uuid.dart';

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
  final DBChat _dbChat;

  final _recipientInfo = CachedValue<UserInfo?>();
  final List<Message> _messages = [];
  final ClientDB _db;
  final LoginManager _loginManager;
  final RequestManager _requestManager;
  bool _hasUnreadMessages = false;

  Chat(DBChat dbChat,
      {required ClientDB db,
      required LoginManager loginManager,
      required RequestManager requestManager})
      : _dbChat = dbChat,
        _db = db,
        _loginManager = loginManager,
        _requestManager = requestManager;

  String get recipientId {
    return _dbChat.id;
  }

  /// Loads all saved messages for this chat and broadcasts them.
  void loadSavedMessages() {
    final messages = _loadMessagesFromDB();
    messages.forEach(_addMessage);
    notifyListeners();
  }

  /// Returns the latest message sent in this chat, without loading any other
  /// messages, or notifying this chat's listeners.
  Message? getLatestMessage() {
    final dbMessage = _db.getLatestMessage(recipientId);
    if (dbMessage == null) return null;
    return _parseDBMessage(dbMessage);
  }

  bool hasUnreadMessages() {
    return _hasUnreadMessages;
  }

  void markAsRead() {
    _hasUnreadMessages = false;
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
    const uuid = Uuid();
    final sendingMsgId = uuid.v1();
    final sentAt = DateTime.now();

    _addMessage(
      Message(
        id: sendingMsgId,
        type: type,
        sentAt: sentAt,
        content: body,
        direction: MessageDirection.outgoing,
        state: MessageState.sending,
      ),
    );

    final key = await CryptoUtils.generateKey();
    final iv = await CryptoUtils.generateIV();
    final encryptedBody = await CryptoUtils.encrypt(body, key, iv);

    try {
      final msgId = await _requestManager.sendMessage(
        await _loginManager.getAuthenticator(),
        recipientId,
        sentAt,
        {"type": type, ...(headers ?? {})},
        await _getEncryptedKeys(key),
        base64.encode(iv),
        base64.encode(encryptedBody),
      );

      _removeMessage(sendingMsgId);

      await saveMessage(
        Message(
          id: msgId,
          type: type,
          state: MessageState.sent,
          direction: MessageDirection.outgoing,
          sentAt: sentAt,
          content: body,
        ),
      );
    } on RequestException {
      _addMessage(
        Message(
          id: sendingMsgId,
          type: type,
          sentAt: sentAt,
          content: body,
          direction: MessageDirection.outgoing,
          state: MessageState.failed,
        ),
      );
    }
  }

  /// Saves a message to this device WITHOUT sending it to the server.
  ///
  /// Unless you know what you are doing, consider using [sendMessage]
  /// or [sendTextMessage] instead.
  Future<void> saveMessage(Message message) async {
    _loginManager.assertLoggedIn();
    final dbMessage = DBMessage(
      message.id,
      message.type,
      message.direction == MessageDirection.incoming,
      message.sentAt,
      message.content,
    );
    _db.addMessage(recipientId, dbMessage);
    _addMessage(message);

    _hasUnreadMessages = true;
    notifyListeners();
  }

  void _sortMessages() {
    _messages.sort((msg1, msg2) => msg2.sentAt.compareTo(msg1.sentAt));
  }

  List<Message> _loadMessagesFromDB() {
    final List<DBMessage> dbMessages = _db.getMessages(recipientId);
    return List.from(dbMessages.map(_parseDBMessage));
  }

  Message _parseDBMessage(DBMessage dbMsg) {
    return Message(
      id: dbMsg.id,
      type: dbMsg.type,
      state: MessageState.sent,
      direction: dbMsg.incoming
          ? MessageDirection.incoming
          : MessageDirection.outgoing,
      sentAt: dbMsg.sentAt,
      content: dbMsg.content,
    );
  }

  void _removeMessage(String id) {
    _messages.removeWhere((msg) => msg.id == id);
  }

  void _addMessage(Message message) {
    _removeMessage(message.id);
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
