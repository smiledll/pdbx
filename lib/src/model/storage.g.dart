// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PdbxStorage _$PdbxStorageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PdbxStorage', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['schema_version', 'metadata', 'entries', 'groups'],
        requiredKeys: const ['schema_version', 'metadata'],
      );
      final val = PdbxStorage(
        schemaVersion: $checkedConvert(
          'schema_version',
          (v) => (v as num).toInt(),
        ),
        metadata: $checkedConvert(
          'metadata',
          (v) => PdbxMetadata.fromJson(v as Map<String, dynamic>),
        ),
        entries: $checkedConvert(
          'entries',
          (v) => (v as List<dynamic>?)
              ?.map((e) => PdbxEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        groups: $checkedConvert(
          'groups',
          (v) => (v as List<dynamic>?)
              ?.map((e) => PdbxGroup.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'schemaVersion': 'schema_version'});

Map<String, dynamic> _$PdbxStorageToJson(PdbxStorage instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'metadata': instance.metadata.toJson(),
      'entries': instance.entries.map((e) => e.toJson()).toList(),
      'groups': instance.groups.map((e) => e.toJson()).toList(),
    };

const _$PdbxStorageJsonSchema = {
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'type': 'object',
  'properties': {
    'schema_version': {'type': 'integer'},
    'metadata': {r'$ref': r'#/$defs/PdbxMetadata'},
    'entries': {
      'type': 'array',
      'items': {r'$ref': r'#/$defs/PdbxEntry'},
    },
    'groups': {
      'type': 'array',
      'items': {r'$ref': r'#/$defs/PdbxGroup'},
    },
  },
  'required': [
    'schema_version',
    'metadata',
    'entries',
    'groups',
    'entries',
    'groups',
  ],
  r'$defs': {
    'PdbxMetadata': {
      'type': 'object',
      'properties': {
        'created': {'type': 'string', 'format': 'date-time'},
        'updated': {'type': 'string', 'format': 'date-time'},
        'revision': {'type': 'integer'},
      },
      'required': ['created', 'updated', 'revision'],
    },
    'PdbxEntry': {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
        'title': {'type': 'string'},
        'username': {'type': 'string'},
        'password': {'type': 'string'},
        'groupId': {'type': 'string'},
      },
      'required': ['id', 'title', 'username', 'password', 'groupId'],
    },
    'PdbxGroup': {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
        'name': {'type': 'string'},
        'parentGroupId': {'type': 'string'},
        'isRoot': {'type': 'boolean'},
      },
      'required': ['id', 'name', 'isRoot'],
    },
  },
};
