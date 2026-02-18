// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PdbxGroup _$PdbxGroupFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'revision', 'title', 'created_at', 'updated_at'],
  );
  return PdbxGroup(
    id: json['id'] as String,
    revision: (json['revision'] as num).toInt(),
    title: json['title'] as String,
    createdAt: (json['created_at'] as num).toInt(),
    updatedAt: (json['updated_at'] as num).toInt(),
    parentGroupId: json['parent_group_id'] as String?,
    deleted: json['deleted'] as bool? ?? false,
  );
}

Map<String, dynamic> _$PdbxGroupToJson(PdbxGroup instance) => <String, dynamic>{
  'id': instance.id,
  'revision': instance.revision,
  'title': instance.title,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'parent_group_id': instance.parentGroupId,
  'deleted': instance.deleted,
};
