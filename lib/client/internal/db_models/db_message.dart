import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';

part 'db_message.g.dart';

@HiveType(typeId: 0)
class DBMessage {
  @HiveField(0)
  final String type;

  @HiveField(1)
  final bool incoming;

  @HiveField(2)
  final DateTime sentAt;

  @HiveField(3)
  final Uint8List content;

  DBMessage(this.type, this.incoming, this.sentAt, this.content) : super();
}
