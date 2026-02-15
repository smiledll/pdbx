import 'package:json_annotation/json_annotation.dart';
import 'package:pdbx/src/validation/group_validator.dart';
import 'package:uuid/uuid.dart';

part 'group.g.dart';

@JsonSerializable(
  explicitToJson: true,
  createJsonSchema: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class PdbxGroup {
  @JsonKey(name: 'id', required: true)
  final String id;

  @JsonKey(name: 'name', required: true)
  final String name;

  @JsonKey(name: 'parent_group_id', required: true)
  final String? parentGroupId;

  PdbxGroup({String? id, required this.name, required this.parentGroupId})
    : id = id ?? Uuid().v4();

  Map<String, dynamic> toJson() => _$PdbxGroupToJson(this);

  factory PdbxGroup.fromJson(Map<String, dynamic> json) =>
      _$PdbxGroupFromJson(json);
}

extension GroupExtensions on PdbxGroup {
  bool get isRoot => parentGroupId == null;

  void validate() => GroupValidator.validate(this);
}
