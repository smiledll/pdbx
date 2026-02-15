import 'package:json_annotation/json_annotation.dart';

part 'metadata.g.dart';

@JsonSerializable(
  createJsonSchema: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class PdbxMetadata {
  @JsonKey(name: 'created', required: true)
  final DateTime created;

  @JsonKey(name: 'updated', required: true)
  final DateTime updated;

  @JsonKey(name: 'revision', required: true)
  final int revision;

  PdbxMetadata({DateTime? created, DateTime? updated, required this.revision})
    : created = created ?? .now(),
      updated = updated ?? .now();

  Map<String, dynamic> toJson() => _$PdbxMetadataToJson(this);

  factory PdbxMetadata.fromJson(Map<String, dynamic> json) =>
      _$PdbxMetadataFromJson(json);
}
