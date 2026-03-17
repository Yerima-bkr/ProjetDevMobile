// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 1;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      id: fields[0] as int,
      patientId: fields[1] as int,
      medecinId: fields[2] as int,
      expediteur: fields[3] as String,
      texte: fields[4] as String,
      dateEnvoi: fields[5] as DateTime,
      lu: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.medecinId)
      ..writeByte(3)
      ..write(obj.expediteur)
      ..writeByte(4)
      ..write(obj.texte)
      ..writeByte(5)
      ..write(obj.dateEnvoi)
      ..writeByte(6)
      ..write(obj.lu);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BotMessageAdapter extends TypeAdapter<BotMessage> {
  @override
  final int typeId = 0;

  @override
  BotMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BotMessage(
      id: fields[0] as int,
      texte: fields[1] as String,
      expediteur: fields[2] as String,
      dateEnvoi: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BotMessage obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.texte)
      ..writeByte(2)
      ..write(obj.expediteur)
      ..writeByte(3)
      ..write(obj.dateEnvoi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BotMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
