// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveDynamicDataModelAdapter extends TypeAdapter<HiveDynamicDataModel> {
  @override
  final int typeId = 0;

  @override
  HiveDynamicDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveDynamicDataModel(
      id: fields[0] as int?,
      dynamicData: (fields[1] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveDynamicDataModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dynamicData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveDynamicDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
