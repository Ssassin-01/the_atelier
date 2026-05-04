// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 0;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      mainImageUrl: fields[3] as String?,
      sketchImageUrl: fields[4] as String?,
      components: (fields[5] as List).cast<RecipeComponent>(),
      tags: (fields[6] as List).cast<String>(),
      createdAt: fields[7] as DateTime,
      sellingPrice: fields[8] as double?,
      targetYield: fields[9] as double?,
      isDraft: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.mainImageUrl)
      ..writeByte(4)
      ..write(obj.sketchImageUrl)
      ..writeByte(5)
      ..write(obj.components)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.sellingPrice)
      ..writeByte(9)
      ..write(obj.targetYield)
      ..writeByte(10)
      ..write(obj.isDraft);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
