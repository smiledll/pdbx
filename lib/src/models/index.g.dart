// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PdbxEntryPointer _$PdbxEntryPointerFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'title',
      'group_id',
      'iv',
      'revision',
      'updated_at',
      'offset',
      'size',
    ],
  );
  return PdbxEntryPointer(
    id: json['id'] as String,
    title: json['title'] as String,
    groupId: json['group_id'] as String,
    iv: const Uint8ListConverter().fromJson(json['iv'] as String),
    revision: (json['revision'] as num).toInt(),
    updatedAt: (json['updated_at'] as num).toInt(),
    offset: (json['offset'] as num).toInt(),
    size: (json['size'] as num).toInt(),
    deleted: json['deleted'] as bool? ?? false,
  );
}

Map<String, dynamic> _$PdbxEntryPointerToJson(PdbxEntryPointer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'group_id': instance.groupId,
      'iv': const Uint8ListConverter().toJson(instance.iv),
      'revision': instance.revision,
      'updated_at': instance.updatedAt,
      'deleted': instance.deleted,
      'offset': instance.offset,
      'size': instance.size,
    };

PdbxIndex _$PdbxIndexFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['revision', 'updated_at']);
  return PdbxIndex(
    revision: (json['revision'] as num).toInt(),
    groups: (json['groups'] as List<dynamic>)
        .map((e) => PdbxGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
    entryPointers: (json['entryPointers'] as List<dynamic>)
        .map((e) => PdbxEntryPointer.fromJson(e as Map<String, dynamic>))
        .toList(),
    updatedAt: (json['updated_at'] as num).toInt(),
  );
}

Map<String, dynamic> _$PdbxIndexToJson(PdbxIndex instance) => <String, dynamic>{
  'revision': instance.revision,
  'updated_at': instance.updatedAt,
  'groups': instance.groups.map((e) => e.toJson()).toList(),
  'entryPointers': instance.entryPointers.map((e) => e.toJson()).toList(),
};
