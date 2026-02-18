import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pdbx/src/models/group.dart';

part 'index.g.dart';

@immutable
@JsonSerializable()
class PdbxEntryPointer {
  @JsonKey(name: 'id', required: true)
  final String id;

  @JsonKey(name: 'title', required: true)
  final String title;

  @JsonKey(name: 'group_id', required: true)
  final String groupId;

  @Uint8ListConverter()
  @JsonKey(name: 'iv', required: true)
  final Uint8List iv;

  @JsonKey(name: 'revision', required: true)
  final int revision;

  @JsonKey(name: 'updated_at', required: true)
  final int updatedAt;

  @JsonKey(name: 'deleted', required: true)
  final bool deleted;

  @JsonKey(name: 'offset', required: true)
  final int offset;

  @JsonKey(name: 'size', required: true)
  final int size;

  const PdbxEntryPointer({
    required this.id,
    required this.title,
    required this.groupId,
    required this.iv,
    required this.revision,
    required this.updatedAt,
    required this.offset,
    required this.size,
    required this.deleted,
  });

  PdbxEntryPointer copyWith({
    String? id,
    String? title,
    String? groupId,
    Uint8List? iv,
    int? revision,
    int? updatedAt,
    bool? deleted,
    int? offset,
    int? size,
  }) => .new(
    id: id ?? this.id,
    title: title ?? this.title,
    groupId: groupId ?? this.groupId,
    iv: iv ?? this.iv,
    revision: revision ?? this.revision,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    offset: offset ?? this.offset,
    size: size ?? this.size,
  );

  factory PdbxEntryPointer.fromJson(Map<String, dynamic> json) =>
      _$PdbxEntryPointerFromJson(json);

  Map<String, dynamic> toJson() => _$PdbxEntryPointerToJson(this);
}

@immutable
@JsonSerializable(explicitToJson: true)
class PdbxIndex {
  @JsonKey(name: 'revision', required: true)
  final int revision;

  @JsonKey(name: 'groups', required: true)
  final List<PdbxGroup> _groups;

  @JsonKey(name: 'entry_pointers', required: true)
  final List<PdbxEntryPointer> _entryPointers;

  @JsonKey(name: 'updated_at', required: true)
  final int updatedAt;

  const PdbxIndex({
    required this.revision,
    required List<PdbxGroup> groups,
    required List<PdbxEntryPointer> entryPointers,
    required this.updatedAt,
  }) : _groups = groups,
       _entryPointers = entryPointers;

  List<PdbxGroup> get groups => .unmodifiable(_groups);
  List<PdbxEntryPointer> get entryPointers => .unmodifiable(_entryPointers);

  static PdbxIndex create() => .new(
    revision: 1,
    groups: [.createRoot(), .createTrash()],
    entryPointers: const [],
    updatedAt: DateTime.now().millisecondsSinceEpoch,
  );

  PdbxIndex copyWith({
    List<PdbxGroup>? groups,
    List<PdbxEntryPointer>? entryPointers,
    int? updatedAt,
  }) => .new(
    revision: revision + 1,
    groups: groups ?? _groups,
    entryPointers: entryPointers ?? _entryPointers,
    updatedAt: updatedAt ?? DateTime.now().millisecondsSinceEpoch,
  );

  factory PdbxIndex.fromJson(Map<String, dynamic> json) =>
      _$PdbxIndexFromJson(json);

  Map<String, dynamic> toJson() => _$PdbxIndexToJson(this);
}

class Uint8ListConverter implements JsonConverter<Uint8List, String> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(String json) => base64Decode(json);

  @override
  String toJson(Uint8List object) => base64Encode(object);
}
