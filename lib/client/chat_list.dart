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
  final Map<String, Chat> _chats = {};

  ChatList(
      {required RequestManager requestManager,
      required LoginManager loginManager,
      required ClientDB db})
      : _requestManager = requestManager,
        _loginManager = loginManager,
        _db = db {
    _db.getChatList().forEach((chatId) => createChatFromId(chatId));
  }

  /// Get all chats that currently exist
  List<Chat> getChats() {
    return List.from(_chats.values);
  }

  /// Get an existing chat from a user id
  Chat? getChatFromId(String id) {
    return _chats[id];
  }

  /// Create a new chat with a user with the provided [username]
  /// Throws an [UnknownUserException] if no such user exists.
  Future<Chat> createChat(String username) async {
    final userInfo = await _requestManager.findUser(username);
    if (userInfo == null) throw UnknownUserException(username);
    return await createChatFromId(userInfo.id);
  }

  /// Removes the chat with [id] from the chat list, but doesn't delete any
  /// stored messages in the chat, so that they will reappear if the chat is
  /// re-added
  void removeChat(String id) async {
    _db.removeChat(id);
    _chats.remove(id);
  }

  /// Removes the chat with [id] from the chat list, and deletes any
  /// stored messages from within it.
  Future<void> deleteChat(String id) async {
    await _db.deleteChat(id);
    _chats.remove(id);
  }

  /// Create a new chat with the user with [id].
  /// This method will not check whether that user actually exists.
  Future<Chat> createChatFromId(String id) async {
    final existing = getChatFromId(id);
    if (existing != null) return existing;
    await _db.createChat(id);
    final chat = Chat(
      id,
      db: _db,
      loginManager: _loginManager,
      requestManager: _requestManager,
    );
    _chats[id] = chat;
    notifyListeners();
    return chat;
  }
}
