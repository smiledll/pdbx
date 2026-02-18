import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pdbx/src/models/group.dart';

part 'index.g.dart';

/// A lightweight metadata pointer to an encrypted entry block.
///
/// Contains searchable information and physical location [offset]
/// within the storage file.
@immutable
@JsonSerializable()
class PdbxEntryPointer {
  /// Unique identifier of the entry.
  @JsonKey(name: 'id', required: true)
  final String id;

  /// Entry title used for searching without full decryption.
  @JsonKey(name: 'title', required: true)
  final String title;

  /// ID of the group this entry belongs to.
  @JsonKey(name: 'group_id', required: true)
  final String groupId;

  /// Initialization Vector (IV) specific to this entry's encrypted block.
  @Uint8ListConverter()
  @JsonKey(name: 'iv', required: true)
  final Uint8List iv;

  /// Revision number of the entry.
  @JsonKey(name: 'revision', required: true)
  final int revision;

  /// Last modification timestamp in milliseconds.
  @JsonKey(name: 'updated_at', required: true)
  final int updatedAt;

  /// Soft-delete status flag.
  @JsonKey(name: 'deleted', required: true)
  final bool deleted;

  /// Byte offset of the encrypted entry block in the storage file.
  @JsonKey(name: 'offset', required: true)
  final int offset;

  /// Size in bytes of the encrypted entry block.
  @JsonKey(name: 'size', required: true)
  final int size;

  /// Standard constructor for [PdbxEntryPointer].
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

  /// Creates a copy of the pointer with updated fields.
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

  /// Converts a JSON map into a [PdbxEntryPointer] instance.
  factory PdbxEntryPointer.fromJson(Map<String, dynamic> json) =>
      _$PdbxEntryPointerFromJson(json);

  /// Converts this instance into a JSON map.
  Map<String, dynamic> toJson() => _$PdbxEntryPointerToJson(this);
}

/// The root manifest of the PDBX storage.
///
/// Contains the hierarchy of groups and pointers to all encrypted entries.
/// The index itself is stored as a single encrypted block.
@immutable
@JsonSerializable(explicitToJson: true)
class PdbxIndex {
  /// Global storage revision. Incremented on any structural change.
  @JsonKey(name: 'revision', required: true)
  final int revision;

  @JsonKey(name: 'groups', required: true)
  final List<PdbxGroup> _groups;

  @JsonKey(name: 'entry_pointers', required: true)
  final List<PdbxEntryPointer> _entryPointers;

  /// Timestamp of the last index synchronization.
  @JsonKey(name: 'updated_at', required: true)
  final int updatedAt;

  /// Standard constructor for [PdbxIndex].
  const PdbxIndex({
    required this.revision,
    required List<PdbxGroup> groups,
    required List<PdbxEntryPointer> entryPointers,
    required this.updatedAt,
  }) : _groups = groups,
       _entryPointers = entryPointers;

  /// Returns an unmodifiable list of all groups.
  List<PdbxGroup> get groups => .unmodifiable(_groups);

  /// Returns an unmodifiable list of all entry pointers.
  List<PdbxEntryPointer> get entryPointers => .unmodifiable(_entryPointers);

  /// Initializes a fresh index with default system groups (Root and Trash).
  static PdbxIndex create() => .new(
    revision: 1,
    groups: [.createRoot(), .createTrash()],
    entryPointers: const [],
    updatedAt: DateTime.now().millisecondsSinceEpoch,
  );

  /// Creates a copy of the index, incrementing the revision.
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

  /// Converts a JSON map into a [PdbxIndex] instance.
  factory PdbxIndex.fromJson(Map<String, dynamic> json) =>
      _$PdbxIndexFromJson(json);

  /// Converts this instance into a JSON map.
  Map<String, dynamic> toJson() => _$PdbxIndexToJson(this);
}

/// Internal converter to handle [Uint8List] as Base64 strings in JSON.
class Uint8ListConverter implements JsonConverter<Uint8List, String> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(String json) => base64Decode(json);

  @override
  String toJson(Uint8List object) => base64Encode(object);
}
