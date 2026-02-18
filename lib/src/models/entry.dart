import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pdbx/src/core/internal/time.dart';
import 'package:pdbx/src/models/group.dart';
import 'package:uuid/uuid.dart';

part 'entry.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class PdbxEntry {
  @JsonKey(name: 'id', required: true)
  final String id;

  @JsonKey(name: 'revision', required: true)
  final int revision;

  @JsonKey(name: 'title', required: true)
  final String title;

  @JsonKey(name: 'group_id', required: true)
  final String groupId;

  @JsonKey(name: 'created_at', required: true)
  final int createdAt;

  @JsonKey(name: 'updated_at', required: true)
  final int updatedAt;

  @JsonKey(name: 'deleted', defaultValue: false)
  final bool deleted;

  @JsonKey(name: 'username')
  final String? username;

  @JsonKey(name: 'password')
  final String? password;

  @JsonKey(name: 'url')
  final String? url;

  @JsonKey(name: 'notes')
  final String? notes;

  @JsonKey(name: 'custom_fields')
  final Map<String, String> customFields;

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

  factory PdbxEntry.fromJson(Map<String, dynamic> json) =>
      _$PdbxEntryFromJson(json);

  Map<String, dynamic> toJson() => _$PdbxEntryToJson(this);
}
