import 'package:pdbx/src/core/exceptions.dart';
import 'package:pdbx/src/model/entry.dart';
import 'package:pdbx/src/model/group.dart';
import 'package:pdbx/src/model/metadata.dart';
import 'package:pdbx/src/model/storage.dart';
import 'package:test/test.dart';

void main() {
  group('PdbxStorage Validation Tests', () {
    late PdbxGroup root;
    late PdbxStorage storage;

    setUp(() {
      root = PdbxGroup(name: 'Root', parentGroupId: null);
      storage = PdbxStorage(
        schemaVersion: 1,
        metadata: PdbxMetadata(revision: 0),
        groups: [root],
      );
    });

    test('EntryValidator accepts vaild entry', () {
      final entry = PdbxEntry(
        title: 'Test Entry',
        username: 'user',
        password: 'pass',
        groupId: root.id,
      );

      expect(() => entry.validate({root.id}), returnsNormally);
    });

    test('EntryValidator rejects entry with invalid groupId', () {
      final entry = PdbxEntry(
        title: 'Test Entry',
        username: 'user',
        password: 'pass',
        groupId: 'ne',
      );

      expect(
        () => entry.validate({root.id}),
        throwsA(isA<ValidationException>()),
      );
    });

    test('StorageValidator detects duplicate group ids', () {
      final group2 = PdbxGroup(
        id: root.id,
        name: 'Another',
        parentGroupId: null,
      );
      storage = PdbxStorage(
        schemaVersion: 1,
        metadata: storage.metadata,
        groups: [root, group2],
      );

      expect(() => storage.validate(), throwsA(isA<ValidationException>()));
    });

    test('StorageValidator rejects multiple root groups', () {
      final root2 = PdbxGroup(name: 'Root2', parentGroupId: null);
      storage = PdbxStorage(
        schemaVersion: 1,
        metadata: storage.metadata,
        groups: [root, root2],
      );

      expect(() => storage.validate(), throwsA(isA<ValidationException>()));
    });
  });
}
