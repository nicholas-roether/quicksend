// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_chat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DBChatAdapter extends TypeAdapter<DBChat> {
  @override
  final int typeId = 2;

  @override
  DBChat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DBChat(
      fields[0] as String,
      fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DBChat obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.hasUnreadMessages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DBChatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
