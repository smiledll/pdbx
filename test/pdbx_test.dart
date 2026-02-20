@Timeout(Duration(minutes: 1))
library;

import 'dart:io';

import 'package:pdbx/pdbx.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late File storageFile;
  late PdbxManager manager;

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

  group('Storage Initialization', () {
    test(
      'should create a new storage file with default system groups',
      () async {
        await manager.createStorage(kMasterPassword);

        expect(await storageFile.exists(), isTrue);
        expect(manager.locked, isFalse);
        expect(manager.activeGroups, hasLength(2));
        expect(manager.index?.entryPointers, isEmpty);
      },
    );

    test('should delete storage and cleanup temporary files', () async {
      await manager.createStorage(kMasterPassword);
      final tempFile = File('${storageFile.path}.tmp')
        ..writeAsStringSync('leak');

      await manager.deleteStorage();

      expect(storageFile.existsSync(), isFalse);
      expect(tempFile.existsSync(), isFalse);
      expect(manager.locked, isTrue);
    });
  });

  group('Authentication & Session Management', () {
    test('should unlock existing storage with correct password', () async {
      await manager.createStorage(kMasterPassword);
      manager.lock();

      await manager.unlock(kMasterPassword);
      expect(manager.locked, isFalse);
      expect(manager.indexLoaded, isTrue);
    });

    test('should throw PdbxAuthException on incorrect password', () async {
      await manager.createStorage(kMasterPassword);
      manager.lock();

      expect(
        () => manager.unlock(kWrongPassword),
        throwsA(isA<PdbxAuthException>()),
      );
      expect(manager.locked, isTrue);
    });

    test('lock() should wipe sensitive data from memory', () async {
      await manager.createStorage(kMasterPassword);
      manager.lock();

      expect(manager.index, isNull);
      expect(() => manager.activeEntries, throwsA(isA<PdbxLockedException>()));
    });
  });

  group('Data Operations (CRUD)', () {
    test('should increment revision when updating an entry', () async {
      await manager.createStorage(kMasterPassword);
      final entry = await manager.createEntry(title: 'V1');

      await manager.saveEntry(entry.copyWith(title: 'V2'));

      final pointer = manager.getPointer(entry.id);
      expect(pointer?.title, 'V2');
      expect(pointer!.revision, greaterThan(entry.revision));
    });

    test('should permanently remove entry from index', () async {
      await manager.createStorage(kMasterPassword);
      final entry = await manager.createEntry(title: 'Delete Me');

      await manager.deleteEntry(entry.id);

      expect(manager.getPointer(entry.id), isNull);
      expect(manager.allEntries, isEmpty);
    });
  });

  group('Hierarchical Logic & Trashing', () {
    test('should manage deep nested groups and entries', () async {
      await manager.createStorage(kMasterPassword);

      final g1 = await manager.createGroup(title: 'L1');
      final g2 = await manager.createGroup(title: 'L2', parentGroupId: g1.id);
      final entry = await manager.createEntry(
        title: 'Deep Entry',
        groupId: g2.id,
      );

      expect(manager.getEntriesInGroup(g2.id).first.id, equals(entry.id));
    });

    test('should recursively move a group branch to trash', () async {
      await manager.createStorage(kMasterPassword);

      final group1 = await manager.createGroup(title: 'Parent');
      final group2 = await manager.createGroup(
        title: 'Child',
        parentGroupId: group1.id,
      );
      final entry = await manager.createEntry(
        title: 'Inner Entry',
        groupId: group2.id,
      );

      await manager.trashGroup(group1.id);

      expect(manager.getGroup(group1.id)?.deleted, isTrue);
      expect(manager.getGroup(group2.id)?.deleted, isTrue);
      expect(manager.getPointer(entry.id)?.deleted, isTrue);

      expect(
        manager.getGroup(group1.id)?.parentGroupId,
        PdbxGroup.trashGroupId,
      );
    });

    test('should protect system groups from deletion/trashing', () async {
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

  group('Search & Retrieval', () {
    test('should perform case-insensitive search', () async {
      await manager.createStorage(kMasterPassword);
      await manager.createEntry(title: 'SECURE DATA');

      final results = manager.searchEntriesInStorage(
        'secure',
        caseSensitive: false,
      );
      expect(results, hasLength(1));
    });
  });

  group('Maintenance & Stress', () {
    test('emptyTrash() should wipe all deleted entries and groups', () async {
      await manager.createStorage(kMasterPassword);
      final group = await manager.createGroup(title: 'To Burn');

      await manager.createEntry(title: 'Entry 1', groupId: group.id);
      await manager.createEntry(title: 'Entry 2', groupId: group.id);
      await manager.createEntry(title: 'Entry 3', groupId: group.id);
      await manager.trashGroup(group.id);

      expect(manager.isTrashEmpty, isFalse);
      await manager.emptyTrash();

      expect(manager.isTrashEmpty, isTrue);
      expect(manager.allGroups, hasLength(2));
    });

    test('Stress: handle multiple entries with persistence check', () async {
      await manager.createStorage(kMasterPassword);
      final count = 50;

      for (var i = 0; i < count; i++) {
        await manager.createEntry(title: 'Entry $i');
      }

      expect(manager.activeEntries, hasLength(count));

      manager.lock();
      await manager.unlock(kMasterPassword);

      expect(manager.activeEntries, hasLength(count));
      expect(
        manager.getPointer(manager.activeEntries.last.id)?.title,
        contains('49'),
      );
    });
  });
}
