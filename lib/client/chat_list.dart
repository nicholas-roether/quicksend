import 'package:flutter/cupertino.dart';
import 'package:quicksend/client/chat.dart';
import 'package:quicksend/client/exceptions.dart';
import 'package:quicksend/client/internal/db.dart';
import 'package:quicksend/client/internal/login_manager.dart';
import 'package:quicksend/client/internal/request_manager.dart';

class ChatList extends ChangeNotifier {
  final LoginManager _loginManager;
  final RequestManager _requestManager;
  final ClientDB _db;
  final List<Chat> _chats = [];

  ChatList(
      {required RequestManager requestManager,
      required LoginManager loginManager,
      required ClientDB db})
      : _requestManager = requestManager,
        _loginManager = loginManager,
        _db = db;

  /// Get all chats that currently exist
  List<Chat> getChats() {
    return List.from(_chats);
  }

  /// Get an existing chat from a user id
  Chat? getChatFromId(String id) {
    for (final chat in _chats) {
      if (chat.recipientId == id) return chat;
    }
    return null;
  }

  /// Create a new chat with a user with the provided [username]
  /// Throws an [UnknownUserException] if no such user exists.
  Future<Chat> createChat(String username) async {
    final userInfo = await _requestManager.findUser(username);
    if (userInfo == null) throw UnknownUserException(username);
    return await createChatFromId(userInfo.id);
  }

  /// Create a new chat with the user with [id].
  /// This method will not check whether that user actually exists.
  Future<Chat> createChatFromId(String id) async {
    await _db.createChat(id);
    final chat = Chat(
      id,
      db: _db,
      loginManager: _loginManager,
      requestManager: _requestManager,
    );
    _chats.add(chat);
    notifyListeners();
    return chat;
  }
}
