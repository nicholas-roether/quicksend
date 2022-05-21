import 'dart:convert';
import 'dart:typed_data';

import 'package:quicksend/client/db.dart';
import 'package:quicksend/client/login_manager.dart';
import 'package:quicksend/client/request_manager.dart';

enum MessageDirection { incoming, outgoing }

class Message {
  final String type;
  final MessageDirection direction;
  final DateTime sentAt;
  final Uint8List content;

  const Message(this.type, this.direction, this.sentAt, this.content);

  String asString() {
    return utf8.decode(content);
  }

  factory Message._fromDB(DBMessage msg) {
    MessageDirection direction = MessageDirection.values[msg.direction.index];
    return Message(msg.type, direction, msg.sentAt, msg.content);
  }

  DBMessage _toDB() {
    DBMessageDirection dir = DBMessageDirection.values[direction.index];
    return DBMessage(type, dir, sentAt, content);
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
  final LoginManager _loginManager;
  final RequestManager _requestManager;
  final ClientDB _db;

  const ChatManager(this._loginManager, this._requestManager, this._db);

  List<String> listChatIDs() {
    return _db.getChatList();
  }

  bool chatExists(String id) {
    return listChatIDs().contains(id);
  }

  Future<Chat?> getChat(String id) async {
    if (!chatExists(id)) return null;
    final UserInfo? user = await _requestManager.getUserInfoFor(id);
    if (user == null) return null;
    return Chat(_db, user);
  }

  Future<Chat> createChat(String userId) async {
    final existing = await getChat(userId);
    if (existing != null) return existing;
    final UserInfo? user = await _requestManager.getUserInfoFor(userId);
    if (user == null) throw Exception("User does not exist");
    await _db.createChat(userId);
    return Chat(_db, user);
  }

  Future<void> refreshMessages() async {
    final auth = await _loginManager.getAuthenticator();
    final List<IncomingMessage> messages =
        await _requestManager.pollMessages(auth);
    for (final message in messages) {
      if (!chatExists(message.fromUser)) await createChat(message.fromUser);
      _db.addMessage(
        message.fromUser,
        DBMessage(
            message.headers["type"] ?? "text/plain",
            message.incoming
                ? DBMessageDirection.incoming
                : DBMessageDirection.outgoing,
            message.sentAt,
            Uint8List(0) // TODO decrypt content
            ),
      );
    }
  }
}
