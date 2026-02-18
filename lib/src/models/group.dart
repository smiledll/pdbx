import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pdbx/src/core/internal/time.dart';
import 'package:uuid/uuid.dart';

part 'group.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class PdbxGroup {
  static const String rootGroupId = '00000000-0000-0000-0000-000000000000';
  static const String trashGroupId = '77777777-7777-7777-7777-777777777777';

  static const String rootGroupName = 'Root';
  static const String trashGroupName = 'Trash';

  @JsonKey(name: 'id', required: true)
  final String id;

  @JsonKey(name: 'revision', required: true)
  final int revision;

  @JsonKey(name: 'title', required: true)
  final String title;

  @JsonKey(name: 'created_at', required: true)
  final int createdAt;

  @JsonKey(name: 'updated_at', required: true)
  final int updatedAt;

  @JsonKey(name: 'parent_group_id')
  final String? parentGroupId;

  @JsonKey(name: 'deleted', defaultValue: false)
  final bool deleted;

  const PdbxGroup({
    required this.id,
    required this.revision,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.parentGroupId,
    this.deleted = false,
  });

  static PdbxGroup create({required String title, String? parentGroupId}) =>
      .new(
        id: const Uuid().v4(),
        revision: 1,
        title: title,
        createdAt: nowMs(),
        updatedAt: nowMs(),
        parentGroupId: parentGroupId ?? rootGroupId,
      );

  static PdbxGroup createRoot() {
    return .new(
      id: Namespace.nil.value,
      revision: 1,
      title: rootGroupName,
      createdAt: nowMs(),
      updatedAt: nowMs(),
      parentGroupId: null,
    );
  }

  static PdbxGroup createTrash() => .new(
    id: trashGroupId,
    revision: 1,
    title: trashGroupName,
    createdAt: nowMs(),
    updatedAt: nowMs(),
    parentGroupId: rootGroupId,
    deleted: true
  );

  PdbxGroup copyWith({
    String? title,
    String? parentGroupId,
    bool? deleted,
    bool clearParent = false,
  }) => .new(
    id: id,
    revision: revision + 1,
    title: title ?? this.title,
    createdAt: createdAt,
    updatedAt: nowMs(),
    parentGroupId: clearParent ? null : (parentGroupId ?? this.parentGroupId),
    deleted: deleted ?? this.deleted,
  );

  factory PdbxGroup.fromJson(Map<String, dynamic> json) =>
      _$PdbxGroupFromJson(json);

  Map<String, dynamic> toJson() => _$PdbxGroupToJson(this);
}
