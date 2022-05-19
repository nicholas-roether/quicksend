import 'dart:convert';
import 'dart:typed_data';

import 'package:quicksend/client/db.dart';
import 'package:quicksend/client/request_manager.dart';

enum MessageDirection { incoming, outgoing }

class Message {
  final String type;
  final MessageDirection direction;
  final Uint8List content;

  const Message(this.type, this.direction, this.content);

  String asString() {
    return utf8.decode(content);
  }

  factory Message._fromDB(DBMessage msg) {
    MessageDirection direction = MessageDirection.values[msg.direction.index];
    return Message(msg.type, direction, msg.content);
  }

  DBMessage _toDB() {
    DBMessageDirection dir = DBMessageDirection.values[direction.index];
    return DBMessage(type, dir, content);
  }
}

class Chat {
  final ClientDB _db;
  final UserInfo user;

  const Chat(this._db, this.user);

  List<Message> getMessages() {
    final List<DBMessage> dbMessages = _db.getMessages(user.id);
    return List.from(dbMessages.map(Message._fromDB));
  }
}

class ChatManager {
  final RequestManager _requestManager;
  final ClientDB _db;

  const ChatManager(this._requestManager, this._db);

  List<String> listChatIDs() {
    return _db.getChatList();
  }

  Future<Chat?> getChat(String id) async {
    if (!_db.getChatList().contains(id)) return null;
    final UserInfo? user = await _requestManager.getUserInfoFor(id);
    if (user == null) return null;
    return Chat(_db, user);
  }

  Future<Chat?> createChat(String userId) async {
    final UserInfo? user = await _requestManager.getUserInfoFor(userId);
    if (user == null) return null;
    await _db.createChat(userId);
    return Chat(_db, user);
  }
}
