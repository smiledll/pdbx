import 'package:pdbx/src/core/exceptions.dart';
import 'package:pdbx/src/model/group.dart';

class GroupValidator {
  static void validate(PdbxGroup group) {
    if (group.id.trim().isEmpty) {
      throw ValidationException('Идентификатор группы пустой.');
    }
  }
}
