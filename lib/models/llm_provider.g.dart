// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_provider.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LLMProviderTypeAdapter extends TypeAdapter<LLMProviderType> {
  @override
  final int typeId = 2;

  @override
  LLMProviderType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LLMProviderType.gemini;
      case 1:
        return LLMProviderType.openai;
      case 2:
        return LLMProviderType.anthropic;
      case 3:
        return LLMProviderType.groq;
      case 4:
        return LLMProviderType.huggingface;
      case 5:
        return LLMProviderType.openrouter;
      case 6:
        return LLMProviderType.together;
      case 7:
        return LLMProviderType.replicate;
      default:
        return LLMProviderType.gemini;
    }
  }

  @override
  void write(BinaryWriter writer, LLMProviderType obj) {
    switch (obj) {
      case LLMProviderType.gemini:
        writer.writeByte(0);
        break;
      case LLMProviderType.openai:
        writer.writeByte(1);
        break;
      case LLMProviderType.anthropic:
        writer.writeByte(2);
        break;
      case LLMProviderType.groq:
        writer.writeByte(3);
        break;
      case LLMProviderType.huggingface:
        writer.writeByte(4);
        break;
      case LLMProviderType.openrouter:
        writer.writeByte(5);
        break;
      case LLMProviderType.together:
        writer.writeByte(6);
        break;
      case LLMProviderType.replicate:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LLMProviderTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LLMProviderAdapter extends TypeAdapter<LLMProvider> {
  @override
  final int typeId = 3;

  @override
  LLMProvider read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LLMProvider(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as LLMProviderType,
      apiKey: fields[3] as String?,
      model: fields[4] as String,
      baseUrl: fields[5] as String,
      isEnabled: fields[6] as bool,
      isFree: fields[7] as bool,
      maxTokens: fields[8] as int?,
      temperature: fields[9] as double?,
      description: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LLMProvider obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.apiKey)
      ..writeByte(4)
      ..write(obj.model)
      ..writeByte(5)
      ..write(obj.baseUrl)
      ..writeByte(6)
      ..write(obj.isEnabled)
      ..writeByte(7)
      ..write(obj.isFree)
      ..writeByte(8)
      ..write(obj.maxTokens)
      ..writeByte(9)
      ..write(obj.temperature)
      ..writeByte(10)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LLMProviderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}