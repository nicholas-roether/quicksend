import 'package:hive_flutter/hive_flutter.dart';

part 'db_chat.g.dart';

@HiveType(typeId: 2)
class DBChat extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  bool hasUnreadMessages;

  DBChat(this.id, this.hasUnreadMessages) : super();
}
