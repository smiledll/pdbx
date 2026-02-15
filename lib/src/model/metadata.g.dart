// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PdbxMetadata _$PdbxMetadataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PdbxMetadata', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['created', 'updated', 'revision'],
        requiredKeys: const ['created', 'updated', 'revision'],
      );
      final val = PdbxMetadata(
        created: $checkedConvert('created', (v) => DateTime.parse(v as String)),
        updated: $checkedConvert('updated', (v) => DateTime.parse(v as String)),
        revision: $checkedConvert('revision', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$PdbxMetadataToJson(PdbxMetadata instance) =>
    <String, dynamic>{
      'created': instance.created.toIso8601String(),
      'updated': instance.updated.toIso8601String(),
      'revision': instance.revision,
    };

const _$PdbxMetadataJsonSchema = {
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'type': 'object',
  'properties': {
    'created': {'type': 'string', 'format': 'date-time'},
    'updated': {'type': 'string', 'format': 'date-time'},
    'revision': {'type': 'integer'},
  },
  'required': ['created', 'updated', 'revision'],
};
