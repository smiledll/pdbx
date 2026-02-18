@Timeout(Duration(minutes: 1))
library;

import 'dart:io';

import 'package:pdbx/pdbx.dart';
import 'package:pdbx/src/core/exceptions.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late File storageFile;
  late PdbxManager manager;

  // Константы для тестов (явные, чтобы тесты были предсказуемыми)
  const kMasterPassword = 'test-master-password-123';
  const kWrongPassword = 'wrong-password';

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pdbx_test_');
    storageFile = File('${tempDir.path}/test.pdbx');
    manager = PdbxManager(storageFile);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('1. Storage Initialization', () {
    test('Создание нового файла хранилища', () async {
      await manager.createStorage(kMasterPassword);

      expect(await storageFile.exists(), isTrue);
      expect(manager.locked, isFalse);
      expect(manager.index?.entryPointers, isEmpty);
      expect(manager.activeGroups.length, equals(2));
    });

    test('Удаление хранилища (включая .tmp файлы)', () async {
      await manager.createStorage(kMasterPassword);

      // Имитируем оставшийся после сбоя .tmp файл
      final tempFile = File('${storageFile.path}.tmp');
      await tempFile.writeAsString('leaked data');

      await manager.deleteStorage();

      expect(await storageFile.exists(), isFalse);
      expect(await tempFile.exists(), isFalse);
      expect(manager.locked, isTrue);
    });
  });

  group('2. Authentication & Session', () {
    test('Успешная разблокировка существующего файла', () async {
      await manager.createStorage(kMasterPassword);
      manager.lock(); // Закрываем

      await manager.unlock(kMasterPassword);
      expect(manager.locked, isFalse);
      expect(manager.indexLoaded, isTrue);
    });

    test('Ошибка при неверном пароле', () async {
      await manager.createStorage(kMasterPassword);
      manager.lock();

      expect(
        () => manager.unlock(kWrongPassword),
        throwsA(isA<PdbxAuthException>()),
      );
      expect(manager.locked, isTrue);
    });

    test('Метод lock() полностью очищает состояние в памяти', () async {
      await manager.createStorage(kMasterPassword);
      manager.lock();

      expect(manager.index, isNull);
      expect(manager.locked, isTrue);
      expect(() => manager.activeEntries, throwsA(isA<PdbxLockedException>()));
    });
  });

  group('3. CRUD & Data Integrity', () {
    test('Обновление существующей записи (Revision increment)', () async {
      await manager.createStorage(kMasterPassword);
      final entry = await manager.createEntry(title: 'Initial Title');
      final originalRevision = entry.revision;

      // Обновляем заголовок
      final updatedEntry = entry.copyWith(title: 'New Title');
      await manager.saveEntry(updatedEntry);

      final pointer = manager.activeEntries.first;
      expect(pointer.title, equals('New Title'));
      expect(pointer.revision, greaterThan(originalRevision));

      final fetched = await manager.fetchEntry(pointer);
      expect(fetched.title, equals('New Title'));
    });

    test('Физическое удаление записи без корзины (Permanent delete)', () async {
      await manager.createStorage(kMasterPassword);
      final entry = await manager.createEntry(title: 'Kill Me');

      await manager.deleteEntry(entry.id);

      expect(manager.allEntries, isEmpty);
      expect(manager.searchEntriesInStorage('Kill'), isEmpty);
    });
  });

  group('4. Advanced Hierarchy', () {
    test('Создание записи в глубоко вложенной группе', () async {
      await manager.createStorage(kMasterPassword);

      final g1 = await manager.createGroup(title: 'L1');
      final g2 = await manager.createGroup(title: 'L2', parentGroupId: g1.id);

      final entry = await manager.createEntry(
        title: 'Deep Entry',
        groupId: g2.id,
      );

      expect(manager.getEntriesInGroup(g2.id).first.id, equals(entry.id));
      expect(manager.getEntriesInGroup(g1.id), isEmpty); // В родительской пусто
    });

    test('Запрет удаления системных групп', () async {
      await manager.createStorage(kMasterPassword);

      expect(
        () => manager.deleteGroup(PdbxGroup.rootGroupId),
        throwsA(isA<PdbxStorageException>()),
      );
      expect(
        () => manager.trashGroup(PdbxGroup.trashGroupId),
        throwsA(isA<PdbxStorageException>()),
      );
    });
  });

  group('5. Search Logic', () {
    test('Регистронезависимый поиск в хранилище', () async {
      await manager.createStorage(kMasterPassword);
      await manager.createEntry(title: 'BANK OF AMERICA');

      final results = manager.searchEntriesInStorage(
        'bank',
        caseSensitive: false,
      );
      expect(results.length, 1);
      expect(results.first.title, contains('BANK'));
    });

    test('Поиск внутри конкретной группы', () async {
      await manager.createStorage(kMasterPassword);
      final work = await manager.createGroup(title: 'Work');

      await manager.createEntry(title: 'Slack', groupId: work.id);
      await manager.createEntry(title: 'Personal Slack'); // В корне

      final results = manager.searchEntriesInGroup('Slack', work.id);
      expect(results.length, 1);
      expect(results.first.title, equals('Slack'));
    });
  });

  group('6. Mass Operations & Stress', () {
    test('Очистка корзины удаляет и записи, и группы', () async {
      await manager.createStorage(kMasterPassword);

      final folder = await manager.createGroup(title: 'To Burn');
      await manager.createEntry(title: 'File in folder', groupId: folder.id);

      await manager.trashGroup(folder.id);
      await manager.trashEntry(manager.activeEntries.first.id);

      expect(manager.isTrashEmpty, isFalse);
      await manager.emptyTrash();

      expect(manager.isTrashEmpty, isTrue);
      expect(manager.allGroups.length, 2);
      expect(manager.allEntries, isEmpty);
    });

    test('Синхронизация большого количества записей (Stress Test)', () async {
      await manager.createStorage(kMasterPassword);

      for (int i = 0; i < 50; i++) {
        await manager.createEntry(title: 'Entry $i');
      }

      expect(manager.activeEntries.length, 50);

      manager.lock();
      await manager.unlock(kMasterPassword);

      expect(manager.activeEntries.length, 50);
      final lastEntry = await manager.fetchEntry(manager.activeEntries.last);
      expect(lastEntry.title, startsWith('Entry'));
    });
  });
}
