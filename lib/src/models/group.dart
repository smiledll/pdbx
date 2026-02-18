import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pdbx/src/core/internal/time.dart';
import 'package:uuid/uuid.dart';

part 'group.g.dart';

/// Represents a folder or category used to organize entries and subgroups.
///
/// Groups support a tree-like hierarchy through [parentGroupId].
@immutable
@JsonSerializable(explicitToJson: true)
class PdbxGroup {
  /// The virtual root group ID (Nil UUID: 00000000-0000-0000-0000-000000000000).
  static const String rootGroupId = '00000000-0000-0000-0000-000000000000';

  /// The system trash group ID used for soft-deleted items.
  static const String trashGroupId = '77777777-7777-7777-7777-777777777777';

  /// Default title for the root group.
  static const String rootGroupName = 'Root';

  /// Default title for the trash group.
  static const String trashGroupName = 'Trash';

  /// Unique identifier (UUID v4 or system constant).
  @JsonKey(name: 'id', required: true)
  final String id;

  /// The version of this group metadata. Incremented on every change.
  @JsonKey(name: 'revision', required: true)
  final int revision;

  /// User-friendly name of the group.
  @JsonKey(name: 'title', required: true)
  final String title;

  /// Creation timestamp in milliseconds.
  @JsonKey(name: 'created_at', required: true)
  final int createdAt;

  /// Last modification timestamp in milliseconds.
  @JsonKey(name: 'updated_at', required: true)
  final int updatedAt;

  /// The ID of the parent group. Null only for the [rootGroupId].
  @JsonKey(name: 'parent_group_id')
  final String? parentGroupId;

  /// Flag indicating if the group is moved to trash.
  @JsonKey(name: 'deleted', defaultValue: false)
  final bool deleted;

  /// Standard constructor for [PdbxGroup].
  const PdbxGroup({
    required this.id,
    required this.revision,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.parentGroupId,
    this.deleted = false,
  });

  /// Factory method to create a new user-defined group.
  ///
  /// By default, the group is placed under the [rootGroupId].
  static PdbxGroup create({required String title, String? parentGroupId}) =>
      .new(
        id: const Uuid().v4(),
        revision: 1,
        title: title,
        createdAt: nowMs(),
        updatedAt: nowMs(),
        parentGroupId: parentGroupId ?? rootGroupId,
      );

  /// Generates the immutable system Root group.
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

  /// Generates the system Trash group, located under the Root.
  static PdbxGroup createTrash() => .new(
    id: trashGroupId,
    revision: 1,
    title: trashGroupName,
    createdAt: nowMs(),
    updatedAt: nowMs(),
    parentGroupId: rootGroupId,
    deleted: true,
  );

  /// Creates a copy of this group with updated values.
  ///
  /// Increments [revision] and updates [updatedAt] automatically.
  /// If [clearParent] is true, the [parentGroupId] will be set to null.
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

  /// Converts a JSON map into a [PdbxGroup] instance.
  factory PdbxGroup.fromJson(Map<String, dynamic> json) =>
      _$PdbxGroupFromJson(json);

  /// Converts this instance into a JSON map.
  Map<String, dynamic> toJson() => _$PdbxGroupToJson(this);
}
