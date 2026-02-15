import 'package:json_annotation/json_annotation.dart';
import 'package:pdbx/src/validation/entry_validator.dart';
import 'package:uuid/uuid.dart';

part 'entry.g.dart';

@JsonSerializable(
  createJsonSchema: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class PdbxEntry {
  @JsonKey(name: 'id', required: true, disallowNullValue: true)
  final String id;

  @JsonKey(name: 'title', required: true)
  final String title;

  @JsonKey(name: 'username', required: true)
  final String username;

  @JsonKey(name: 'password', required: true)
  final String password;

  @JsonKey(name: 'group_id', required: true, disallowNullValue: true)
  final String groupId;

  PdbxEntry({
    String? id,
    required this.title,
    required this.username,
    required this.password,
    required this.groupId,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toJson() => _$PdbxEntryToJson(this);

  factory PdbxEntry.fromJson(Map<String, dynamic> json) =>
      _$PdbxEntryFromJson(json);
}

extension EntryExtensions on PdbxEntry {
  bool get isDraft =>
      title.trim().isEmpty ||
      username.trim().isEmpty ||
      password.trim().isEmpty;

  void validate(Set<String> groupIds) =>
      EntryValidator.validate(this, groupIds);
}
