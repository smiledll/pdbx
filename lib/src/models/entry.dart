import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pdbx/src/core/internal/time.dart';
import 'package:pdbx/src/models/group.dart';
import 'package:uuid/uuid.dart';

part 'entry.g.dart';

/// Represents a single password entry in the storage.
///
/// All fields in this class are encrypted when stored on disk within
/// an entry block.
@immutable
@JsonSerializable(explicitToJson: true)
class PdbxEntry {
  /// Unique identifier (UUID v4).
  @JsonKey(name: 'id', required: true)
  final String id;

  /// The version of this specific entry. Incremented on every change.
  @JsonKey(name: 'revision', required: true)
  final int revision;

  /// User-friendly title for the entry (e.g., "Google Account").
  @JsonKey(name: 'title', required: true)
  final String title;

  /// The ID of the group this entry belongs to.
  @JsonKey(name: 'group_id', required: true)
  final String groupId;

  /// Creation timestamp in milliseconds.
  @JsonKey(name: 'created_at', required: true)
  final int createdAt;

  /// Last modification timestamp in milliseconds.
  @JsonKey(name: 'updated_at', required: true)
  final int updatedAt;

  /// Flag indicating if the entry is moved to trash.
  @JsonKey(name: 'deleted', defaultValue: false)
  final bool deleted;

  /// The username or login associated with the account.
  @JsonKey(name: 'username')
  final String? username;

  /// The secret password or key.
  @JsonKey(name: 'password')
  final String? password;

  /// URL of the website or service.
  @JsonKey(name: 'url')
  final String? url;

  /// Multi-line text for additional information.
  @JsonKey(name: 'notes')
  final String? notes;

  /// A map of user-defined key-value pairs for flexible data storage.
  @JsonKey(name: 'custom_fields')
  final Map<String, String> customFields;

  /// Standard constructor for [PdbxEntry].
  const PdbxEntry({
    required this.id,
    required this.revision,
    required this.title,
    required this.groupId,
    required this.createdAt,
    required this.updatedAt,
    this.deleted = false,
    this.username,
    this.password,
    this.url,
    this.notes,
    this.customFields = const {},
  });

  /// Factory method to create a brand new entry with a fresh UUID.
  static PdbxEntry create({
    required String title,
    String? groupId,
    String? username,
    String? password,
    String? url,
    String? notes,
    Map<String, String>? customFields,
  }) => .new(
    id: const Uuid().v4(),
    revision: 1,
    title: title,
    groupId: groupId ?? PdbxGroup.rootGroupId,
    createdAt: nowMs(),
    updatedAt: nowMs(),
    username: username,
    password: password,
    url: url,
    notes: notes,
    customFields: customFields ?? {},
  );

  /// Creates a copy of this entry with updated values.
  ///
  /// Automatically increments the [revision] and updates [updatedAt].
  PdbxEntry copyWith({
    String? title,
    String? groupId,
    String? username,
    String? password,
    String? url,
    String? notes,
    Map<String, String>? customFields,
    bool? deleted,
  }) => .new(
    id: id,
    revision: revision + 1,
    title: title ?? this.title,
    groupId: groupId ?? this.groupId,
    createdAt: createdAt,
    updatedAt: nowMs(),
    deleted: deleted ?? this.deleted,
    username: username ?? this.username,
    password: password ?? this.password,
    url: url ?? this.url,
    notes: notes ?? this.notes,
    customFields: customFields ?? this.customFields,
  );

  /// Converts a JSON map into a [PdbxEntry] instance.
  factory PdbxEntry.fromJson(Map<String, dynamic> json) =>
      _$PdbxEntryFromJson(json);

  /// Converts this instance into a JSON map.
  Map<String, dynamic> toJson() => _$PdbxEntryToJson(this);
}
