import 'package:flutter/cupertino.dart';
import 'package:quicksend/client/chat.dart';
import 'package:quicksend/client/exceptions.dart';
import 'package:quicksend/client/internal/db.dart';
import 'package:quicksend/client/internal/login_manager.dart';
import 'package:quicksend/client/internal/request_manager.dart';

class ChatList extends ChangeNotifier {
  final String _userId;
  final LoginManager _loginManager;
  final RequestManager _requestManager;
  final ClientDB _db;
  final List<Chat> _chats = [];

  ChatList(this._requestManager, this._loginManager, this._db, this._userId) {
    _db.getChatList().forEach((chatId) {
      _chats.add(Chat(_db, _loginManager, _requestManager, chatId, _userId));
    });
  }

  List<Chat> getChats() {
    return List.from(_chats);
  }

  Chat? getChatFromId(String id) {
    return _chats.firstWhere((chat) => chat.recipientId == id);
  }

  Future<Chat> createChat(String username) async {
    final userInfo = await _requestManager.findUser(username);
    if (userInfo == null) throw UnknownUserException(username);
    return await createChatFromId(userInfo.id);
  }

  Future<Chat> createChatFromId(String id) async {
    await _db.createChat(id);
    final chat = Chat(
      _db,
      _loginManager,
      _requestManager,
      id,
      _userId,
    );
    _chats.add(chat);
    notifyListeners();
    return chat;
  }
}
