import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:quicksend/client/crypto_utils.dart';
import 'package:quicksend/client/db.dart';
import 'package:quicksend/client/login_manager.dart';
import 'package:quicksend/client/request_manager.dart';

enum MessageDirection { incoming, outgoing }

/// The class representing a message in a chat.
class Message {
  /// The MIME type of this message's content. This will most commonly be
  /// `"text/plain"` for simple text messages.
  final String type;

  /// Whether this message was sent by this user themselves, or recieved from
  /// another user.
  final MessageDirection direction;

  /// The date and time at which this message was sent.
  final DateTime sentAt;

  /// The content of this message, in binary format.
  ///
  /// To get the message's content as a String, see [Message.asString].
  final Uint8List content;

  const Message(this.type, this.direction, this.sentAt, this.content);

  /// Returns this message's content interpreted as a UTF-8 string. Consider
  /// checking whether the message's type matches this, as this method will
  /// return garbage otherwise.
  String asString() {
    return utf8.decode(content);
  }
}

class Chat {
  final StreamController<Message> _messageStreamController =
      StreamController.broadcast();
  final ClientDB _db;
  final LoginManager _loginManager;
  final RequestManager _requestManager;
  final UserInfo recipient;
  final String _userId;

  Chat(
    this._db,
    this._loginManager,
    this._requestManager,
    this.recipient,
    this._userId,
  ) {
    getMessages().forEach(_messageStreamController.add);
  }

  /// A stream containing all messages sent in this chat, updated live as new
  /// messages come in.
  Stream<Message> get messageStream {
    return _messageStreamController.stream;
  }

  /// Returns a list of all messages that have been sent in this chat up until
  /// now.
  List<Message> getMessages() {
    final List<DBMessage> dbMessages = _db.getMessages(recipient.id);
    return List.from(
      dbMessages.where((msg) => msg.user == _userId).map(_decryptDBMessage),
    );
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
    final encryptedBody = await CryptoUtils.encrypt(body, key);

    await _requestManager.sendMessage(
      await _loginManager.getAuthenticator(),
      recipient.id,
      sentAt,
      {"type": type, ...(headers ?? {})},
      await _getEncryptedKeys(key),
      base64.encode(encryptedBody),
    );

    await _pushMessage(Message(type, MessageDirection.outgoing, sentAt, body));
  }

  Future<void> _pushMessage(Message message) async {
    _loginManager.assertLoggedIn();
    final encryptionKey = await _db.getEncryptionKey();
    assert(encryptionKey != null);
    final key = await CryptoUtils.generateKey();
    final encryptedBody = await CryptoUtils.encrypt(message.content, key);
    final encryptedKey =
        await CryptoUtils.encryptKey(key, encryptionKey as String);

    final dbMessage = DBMessage(
      message.type,
      DBMessageDirection.values[message.direction.index],
      message.sentAt,
      encryptedBody,
      recipient.id,
      encryptedKey,
    );
    _db.addMessage(recipient.id, dbMessage);
    _messageStreamController.add(message);
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
    );
    return Message(
      dbMessage.type,
      dbMessage.direction == DBMessageDirection.incoming
          ? MessageDirection.incoming
          : MessageDirection.outgoing,
      dbMessage.sentAt,
      messageContent,
    );
  }

  Future<Map<String, String>> _getEncryptedKeys(String key) async {
    final Map<String, String> deviceKeyMap = await _getTargetKeys();
    final List<MapEntry<String, String>> encKeyMapEntries = await Future.wait(
      deviceKeyMap.entries.map(
        (e) async => MapEntry(
          e.key,
          await CryptoUtils.encryptKey(key, e.value),
        ),
      ),
    );
    final deviceEncKeyMap = Map.fromEntries(encKeyMapEntries);
    return deviceEncKeyMap;
  }

  Future<Map<String, String>> _getTargetKeys() async {
    return await _requestManager.getMessageTargets(
      await _loginManager.getAuthenticator(),
      recipient.id,
    );
  }
}

class ChatManager {
  final String user;
  final LoginManager _loginManager;
  final RequestManager _requestManager;
  final ClientDB _db;

  const ChatManager(
      this.user, this._loginManager, this._requestManager, this._db);

  List<String> listChatIDs() {
    return _db.getChatList();
  }

  bool chatExists(String id) {
    return listChatIDs().contains(id);
  }

  Future<Chat?> getChat(String id) async {
    if (!chatExists(id)) return null;
    final UserInfo? recipient = await _requestManager.getUserInfoFor(id);
    if (recipient == null) return null;
    return Chat(_db, _loginManager, _requestManager, recipient, user);
  }

  Future<Chat> createChat(String userId) async {
    final existing = await getChat(userId);
    if (existing != null) return existing;
    final UserInfo? recipient = await _requestManager.getUserInfoFor(userId);
    if (recipient == null) throw Exception("User does not exist");
    await _db.createChat(userId);
    return Chat(_db, _loginManager, _requestManager, recipient, user);
  }

  Future<void> refreshMessages() async {
    final auth = await _loginManager.getAuthenticator();
    final List<IncomingMessage> messages =
        await _requestManager.pollMessages(auth);
    for (final message in messages) {
      _saveIncomingMessage(message);
    }
    await _requestManager.clearMessages(auth);
  }

  Future<void> _saveIncomingMessage(IncomingMessage message) async {
    final chat = await createChat(message.fromUser);
    chat._pushMessage(
      Message(
        message.headers["type"] ?? "text/plain",
        message.incoming
            ? MessageDirection.incoming
            : MessageDirection.outgoing,
        message.sentAt,
        await _decryptMessageBody(message),
      ),
    );
  }

  Future<Uint8List> _decryptMessageBody(IncomingMessage msg) async {
    final encKey = await _db.getEncryptionKey();
    assert(encKey != null);
    final msgKey = await CryptoUtils.decryptKey(msg.key, encKey as String);
    final Uint8List encMsgBody = base64.decode(msg.body);
    final msgBody = await CryptoUtils.decrypt(encMsgBody, msgKey);
    return msgBody;
  }
}
