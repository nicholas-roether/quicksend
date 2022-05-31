// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DBMessageAdapter extends TypeAdapter<DBMessage> {
  @override
  final int typeId = 1;

  @override
  DBMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DBMessage(
      fields[0] as String,
      fields[1] as bool,
      fields[2] as DateTime,
      fields[3] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, DBMessage obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.incoming)
      ..writeByte(2)
      ..write(obj.sentAt)
      ..writeByte(3)
      ..write(obj.content);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DBMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
