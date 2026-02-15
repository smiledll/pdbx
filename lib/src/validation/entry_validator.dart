import 'package:pdbx/src/core/exceptions.dart';
import 'package:pdbx/src/model/entry.dart';

class EntryValidator {
  static void validate(PdbxEntry entry, Set<String> groupIds) {
    if (entry.id.trim().isEmpty) {
      throw ValidationException('Идентификатор записи пустой.');
    }

    if (!groupIds.contains(entry.groupId)) {
      throw ValidationException(
        'Запись [${entry.id}] ссылается на несуществующую группу [${entry.groupId}].',
      );
    }
  }
}
