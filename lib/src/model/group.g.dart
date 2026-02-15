// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PdbxGroup _$PdbxGroupFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PdbxGroup', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['id', 'name', 'parent_group_id'],
        requiredKeys: const ['id', 'name', 'parent_group_id'],
      );
      final val = PdbxGroup(
        id: $checkedConvert('id', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String),
        parentGroupId: $checkedConvert('parent_group_id', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'parentGroupId': 'parent_group_id'});

Map<String, dynamic> _$PdbxGroupToJson(PdbxGroup instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'parent_group_id': instance.parentGroupId,
};

const _$PdbxGroupJsonSchema = {
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'type': 'object',
  'properties': {
    'id': {'type': 'string'},
    'name': {'type': 'string'},
    'parent_group_id': {'type': 'string'},
    'isRoot': {'type': 'boolean'},
  },
  'required': ['id', 'name', 'isRoot'],
};
