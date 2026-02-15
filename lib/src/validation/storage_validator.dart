import 'package:pdbx/src/core/exceptions.dart';
import 'package:pdbx/src/model/entry.dart';
import 'package:pdbx/src/model/storage.dart';
import 'package:pdbx/src/validation/group_validator.dart';

class StorageValidator {
  static void validate(PdbxStorage storage) {
    final groupIds = _checkUniqueIds(storage);
    _validateHierarchy(storage);

    for (final g in storage.groups) {
      GroupValidator.validate(g);
    }

    for (final e in storage.entries) {
      e.validate(groupIds);
    }
  }

  static Set<String> _checkUniqueIds(PdbxStorage storage) {
    final groupIds = <String>{};
    for (final g in storage.groups) {
      if (!groupIds.add(g.id)) {
        throw ValidationException(
          'Обнаружен дубликат идентификатора группы: [${g.id}].',
        );
      }
    }

    final entryIds = <String>{};
    for (final e in storage.entries) {
      if (!entryIds.add(e.id)) {
        throw ValidationException(
          'Обнаружен дубликат идентификатора записи: [${e.id}].',
        );
      }
    }

    return groupIds;
  }

  static void _validateHierarchy(PdbxStorage storage) {
    final rootGroups = storage.groups
        .where((g) => g.parentGroupId == null)
        .toList();
    final visited = <String>{};

    void dfs(String id, Set<String> path) {
      if (path.contains(id)) {
        throw ValidationException(
          'Обнаружена циклическая ссылка в иерархии группы [$id].',
        );
      }
      if (visited.contains(id)) return;

      path.add(id);

      for (final child in storage.groups.where((g) => g.parentGroupId == id)) {
        dfs(child.id, path);
      }

      path.remove(id);
      visited.add(id);
    }

    if (rootGroups.isEmpty) {
      throw ValidationException('Корневая группа не найдена.');
    }

    if (rootGroups.length > 1) {
      throw ValidationException('Найдено несколько корневых групп');
    }

    dfs(rootGroups.first.id, {});

    for (final g in storage.groups.where((g) => g.parentGroupId == null)) {
      dfs(g.id, {});
    }
  }
}
