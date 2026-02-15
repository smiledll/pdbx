// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PdbxEntry _$PdbxEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PdbxEntry', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['id', 'title', 'username', 'password', 'group_id'],
        requiredKeys: const ['id', 'title', 'username', 'password', 'group_id'],
        disallowNullValues: const ['id', 'group_id'],
      );
      final val = PdbxEntry(
        id: $checkedConvert('id', (v) => v as String?),
        title: $checkedConvert('title', (v) => v as String),
        username: $checkedConvert('username', (v) => v as String),
        password: $checkedConvert('password', (v) => v as String),
        groupId: $checkedConvert('group_id', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'groupId': 'group_id'});

Map<String, dynamic> _$PdbxEntryToJson(PdbxEntry instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'username': instance.username,
  'password': instance.password,
  'group_id': instance.groupId,
};

const _$PdbxEntryJsonSchema = {
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'type': 'object',
  'properties': {
    'id': {'type': 'string'},
    'title': {'type': 'string'},
    'username': {'type': 'string'},
    'password': {'type': 'string'},
    'group_id': {'type': 'string'},
  },
  'required': ['id', 'title', 'username', 'password', 'group_id'],
};
