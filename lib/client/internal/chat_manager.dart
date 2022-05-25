import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'crypto_utils.dart';
import 'db.dart';
import 'login_manager.dart';
import 'request_manager.dart';

import '../chat.dart';
import '../models.dart';

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
    chat.pushMessage(
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
    final msgKey = await CryptoUtils.decryptKey(
      base64.decode(msg.key),
      encKey as String,
    );
    final Uint8List msgBodyBytes = base64.decode(msg.body);
    final Uint8List ivBytes = base64.decode(msg.iv);
    final msgBody = await CryptoUtils.decrypt(msgBodyBytes, msgKey, ivBytes);
    return msgBody;
  }
}
