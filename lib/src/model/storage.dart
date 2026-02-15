import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:pdbx/src/core/exceptions.dart';
import 'package:pdbx/src/model/entry.dart';
import 'package:pdbx/src/model/group.dart';
import 'package:pdbx/src/model/metadata.dart';
import 'package:pdbx/src/validation/storage_validator.dart';

part 'storage.g.dart';

@JsonSerializable(
  explicitToJson: true,
  createJsonSchema: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class PdbxStorage {
  @JsonKey(name: 'schema_version', required: true)
  final int schemaVersion;

  @JsonKey(name: 'metadata', required: true)
  final PdbxMetadata metadata;

  @JsonKey(name: 'entries', required: true)
  final List<PdbxEntry> _entries;

  @JsonKey(name: 'groups', required: true)
  final List<PdbxGroup> _groups;

  PdbxStorage({
    required this.schemaVersion,
    required this.metadata,
    List<PdbxEntry>? entries,
    List<PdbxGroup>? groups,
  }) : _entries = entries ?? [],
       _groups = groups ?? [];

  Map<String, dynamic> toJson() => _$PdbxStorageToJson(this);

  factory PdbxStorage.fromJson(Map<String, dynamic> json) =>
      _$PdbxStorageFromJson(json);
}

extension StorageExtensions on PdbxStorage {
  UnmodifiableListView<PdbxEntry> get entries => .new(_entries);

  UnmodifiableListView<PdbxGroup> get groups => .new(_groups);

  void validate() => StorageValidator.validate(this);

  void addEntry(PdbxEntry entry) {
    entry.validate(_groups.map((g) => g.id).toSet());
    _entries.add(entry);
  }

  bool removeEntry(String id) {
    final initialLength = _entries.length;
    _entries.removeWhere((e) => e.id == id);
    return _entries.length < initialLength;
  }

  void addGroup(PdbxGroup group) {
    group.validate();

    if (_groups.any((g) => g.id == group.id)) {
      throw ValidationException(
        'Группа с идентификатором [${group.id}] уже существует.',
      );
    }

    _groups.add(group);
  }

  bool removeGroup(String groupId) {
    final initialLength = _groups.length;
    _groups.removeWhere((g) => g.id == groupId);
    return _groups.length < initialLength;
  }
}
