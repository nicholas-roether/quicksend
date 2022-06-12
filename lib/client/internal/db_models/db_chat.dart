import 'package:hive_flutter/hive_flutter.dart';

part 'db_chat.g.dart';

@HiveType(typeId: 2)
class DBChat extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  bool hasUnreadMessages;

  @HiveField(2)
  bool isArchived = false;

  DBChat(this.id, this.hasUnreadMessages) : super();
}
