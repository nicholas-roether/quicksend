import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';

part 'db_message.g.dart';

@HiveType(typeId: 1)
class DBMessage {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final bool incoming;

  @HiveField(3)
  final DateTime sentAt;

  @HiveField(4)
  final Uint8List content;

  DBMessage(this.id, this.type, this.incoming, this.sentAt, this.content)
      : super();
}
