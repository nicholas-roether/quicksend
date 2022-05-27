import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../chat_list.dart';
import 'crypto_utils.dart';
import 'db.dart';
import 'login_manager.dart';
import 'request_manager.dart';

import '../chat.dart';
import '../models.dart';

class ChatManager {
  final String _userId;
  final LoginManager _loginManager;
  final RequestManager _requestManager;
  final ClientDB _db;
  // final Map<String, Chat> openChats = {};
  late final _chatList = ChatList(_requestManager, _loginManager, _db, _userId);

  ChatManager(
      this._userId, this._loginManager, this._requestManager, this._db) {
    Timer.periodic(const Duration(seconds: 5), (_) {
      refreshMessages();
    });
  }

  ChatList getChatList() {
    return _chatList;
  }

  Future<void> refreshMessages() async {
    final auth = await _loginManager.getAuthenticator();
    final List<IncomingMessage> messages =
        await _requestManager.pollMessages(auth);
    await Future.wait(messages.map(_saveIncomingMessage));
    await _requestManager.clearMessages(auth);
  }

  Future<void> _saveIncomingMessage(IncomingMessage message) async {
    final Chat chat = _chatList.getChatFromId(message.chat) ??
        await _chatList.createChatFromId(message.chat);
    chat.saveMessage(
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
