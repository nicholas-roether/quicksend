import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:quicksend/client/internal/event_manager.dart';

import '../chat_list.dart';
import 'crypto_utils.dart';
import 'db.dart';
import 'login_manager.dart';
import 'request_manager.dart';

import '../chat.dart';
import '../models.dart';

class ChatManager {
  final LoginManager _loginManager;
  final RequestManager _requestManager;
  final EventManager _eventManager;
  final ClientDB _db;
  late final _chatList = ChatList(
    requestManager: _requestManager,
    loginManager: _loginManager,
    db: _db,
  );

  ChatManager({
    required LoginManager loginManager,
    required RequestManager requestManager,
    required EventManager eventManager,
    required ClientDB db,
  })  : _loginManager = loginManager,
        _requestManager = requestManager,
        _eventManager = eventManager,
        _db = db {
    _eventManager.on("message", _onMessageEvent);
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

  void close() {
    _eventManager.removeListener("message", _onMessageEvent);
  }

  void _onMessageEvent(_) {
    refreshMessages();
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
