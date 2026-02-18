// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PdbxEntry _$PdbxEntryFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'revision',
      'title',
      'group_id',
      'created_at',
      'updated_at',
    ],
  );
  return PdbxEntry(
    id: json['id'] as String,
    revision: (json['revision'] as num).toInt(),
    title: json['title'] as String,
    groupId: json['group_id'] as String,
    createdAt: (json['created_at'] as num).toInt(),
    updatedAt: (json['updated_at'] as num).toInt(),
    username: json['username'] as String?,
    password: json['password'] as String?,
    url: json['url'] as String?,
    notes: json['notes'] as String?,
    customFields:
        (json['custom_fields'] as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as String),
        ) ??
        const {},
    deleted: json['deleted'] as bool? ?? false,
  );
}

Map<String, dynamic> _$PdbxEntryToJson(PdbxEntry instance) => <String, dynamic>{
  'id': instance.id,
  'revision': instance.revision,
  'title': instance.title,
  'group_id': instance.groupId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'username': instance.username,
  'password': instance.password,
  'url': instance.url,
  'notes': instance.notes,
  'custom_fields': instance.customFields,
  'deleted': instance.deleted,
};
