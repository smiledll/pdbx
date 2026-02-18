import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pdbx/pdbx.dart';
import 'package:pdbx/src/core/binary_reader.dart';
import 'package:pdbx/src/core/binary_writer.dart';
import 'package:pdbx/src/core/constants.dart';
import 'package:pdbx/src/core/crypto_service.dart';
import 'package:pdbx/src/core/exceptions.dart';

/// The central coordinator for Pdbx storage operations.
///
/// Handles encryption, indexing, and hierarchical data management
/// for passwords and groups.
class PdbxManager {
  /// The physical file of active storage.
  final File storageFile;
  final BinaryReader _reader;
  final BinaryWriter _writer;

  Uint8List? _masterKey;
  PdbxIndex? _index;

  /// Creates a new manager instance for the specified [storageFile].
  PdbxManager(this.storageFile)
    : _reader = .new(storageFile),
      _writer = .new(storageFile);

  /// Returns the current index if the storage is unlocked.
  PdbxIndex? get index => _index;

  // ==============================
  // === Management & Lifecycle ===
  // ==============================

  /// Creates a new encrypted storage file with the given [password].
  ///
  /// Throws [PdbxAuthException] if the password is empty.
  /// Throws [PdbxStorageException] if file operations fail.
  Future<void> createStorage(String password) async {
    if (password.isEmpty) {
      throw PdbxAuthException('Пароль не может быть пустым.');
    }

    print('Подготовка к созданию хранилища...');
    final salt = CryptoService.generateRandomSalt();

    _masterKey = await CryptoService.deriveKey(password, salt);
    _index = .create();

    final indexJson = utf8.encode(jsonEncode(_index!.toJson()));
    final indexIv = CryptoService.generateRandomIv();
    final encryptedIndex = await CryptoService.encrypt(
      .fromList(indexJson),
      _masterKey!,
      indexIv,
    );

    final tempFile = File('${storageFile.path}.tmp');

    try {
      print('Запись в ${tempFile.path}...');

      await _writer.writeTo(
        tempFile,
        version: pdbxVersion,
        salt: salt,
        iv: indexIv,
        encryptedIndex: encryptedIndex,
        entryBlocks: [],
      );

      print('Сохранение ${storageFile.path}...');

      if (await storageFile.exists()) {
        await storageFile.delete();
      }
      await tempFile.rename(storageFile.path);

      print('Создано новое хранилище.');
    } catch (e) {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      throw PdbxStorageException('Не удалось создать файл хранилища.', e);
    }
  }

  /// Permanently deletes the storage file and any temporary files.
  Future<void> deleteStorage() async {
    lock();

    try {
      if (await storageFile.exists()) {
        await storageFile.delete();
        print('Файл хранилища удален.');
      }

      final tempFile = File('${storageFile.path}.tmp');

      if (await tempFile.exists()) {
        await tempFile.delete();
        print('Временный файл хранилища удалён.');
      }
    } catch (e) {
      throw PdbxStorageException(
        'Не удалось удалить файлы хранилища. Возможно, они заняты другим процессом.',
        e,
      );
    }
  }

  /// Unlocks the storage using the provided [password].
  ///
  /// Decrypts the index and prepares the manager for data operations.
  /// Throws [PdbxAuthException] on incorrect password.
  Future<void> unlock(String password) async {
    if (!await _reader.isValid()) throw PdbxFormatException();

    try {
      print('Подготовка к разблокировке хранилища...');

      final header = await _reader.readHeader();

      _masterKey = await CryptoService.deriveKey(password, header.salt);

      final encryptedIndex = await _reader.readIndexBlock(
        header.indexOffset,
        header.indexLength,
      );

      print('Расшифровка...');
      final decryptedBytes = await CryptoService.decrypt(
        encryptedIndex,
        _masterKey!,
        header.indexIv,
      );

      final json = utf8.decode(decryptedBytes);
      _index = .fromJson(jsonDecode(json));

      print('Доступ разрешён. Индекс загружен.');
    } catch (e) {
      lock();
      throw PdbxAuthException();
    }
  }

  /// Locks the storage and securely wipes the master key from memory.
  void lock() {
    if (!locked) {
      _masterKey!.fillRange(0, _masterKey!.length, 0);
      _masterKey = null;
    }

    _index = null;

    print('Сессия завершена. Память очищена.');
  }

  /// Estimates the entropy (strength) of a [password] in bits.
  double estimatePasswordEntropy(String password) =>
      CryptoService.estimatePasswordEntropy(password);

  /// Returns true if the storage file exists on disk.
  Future<bool> get exists => storageFile.exists();

  /// Returns true if the storage is currently locked.
  bool get locked => _masterKey == null;

  /// Returns true if the index has been successfully loaded.
  bool get indexLoaded => _index != null;

  // ========================
  // === Entry Operations ===
  // ========================

  /// Creates and saves a new entry to the storage.
  Future<PdbxEntry> createEntry({
    required String title,
    String? groupId,
    String? username,
    String? password,
    String? url,
    String? notes,
    Map<String, String>? customFields,
  }) async {
    _ensureUnlocked();

    final entry = PdbxEntry.create(
      title: title,
      groupId: groupId ?? PdbxGroup.rootGroupId,
      username: username,
      password: password,
      url: url,
      notes: notes,
      customFields: customFields,
    );

    await saveEntry(entry);
    return entry;
  }

  /// Decrypts and returns the full [PdbxEntry] data from the storage file.
  Future<PdbxEntry> fetchEntry(PdbxEntryPointer pointer) async {
    _ensureUnlocked();

    final encryptedEntryBlock = await _reader.readEntryBlock(
      pointer.offset,
      pointer.size,
    );

    final decryptedBytes = await CryptoService.decrypt(
      encryptedEntryBlock,
      _masterKey!,
      pointer.iv,
    );

    final jsonString = utf8.decode(decryptedBytes);
    return .fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Updates or saves the provided [entry] to the storage.
  Future<void> saveEntry(PdbxEntry entry) async {
    _ensureUnlocked();

    final jsonBytes = utf8.encode(jsonEncode(entry.toJson()));
    final entryIv = CryptoService.generateRandomIv();
    final encryptedEntry = await CryptoService.encrypt(
      .fromList(jsonBytes),
      _masterKey!,
      entryIv,
    );

    final updatedPointers = List<PdbxEntryPointer>.from(_index!.entryPointers)
      ..removeWhere((p) => p.id == entry.id);

    final newPointer = PdbxEntryPointer(
      id: entry.id,
      title: entry.title,
      groupId: entry.groupId,
      iv: entryIv,
      revision: entry.revision,
      updatedAt: entry.updatedAt,
      deleted: entry.deleted,
      offset: 0,
      size: encryptedEntry.length,
    );

    updatedPointers.add(newPointer);
    _index = _index!.copyWith(entryPointers: updatedPointers);

    await _syncIndex(
      suggestedEntryBlock: encryptedEntry,
      suggestedEntryId: entry.id,
    );
  }

  /// Moves the entry with [entryId] to the trash group.
  Future<void> trashEntry(String entryId) async {
    _ensureUnlocked();

    final pointer = _index!.entryPointers.firstWhere((p) => p.id == entryId);
    final entry = await fetchEntry(pointer);

    await saveEntry(
      entry.copyWith(deleted: true, groupId: PdbxGroup.trashGroupId),
    );
  }

  /// Restores a deleted entry back to a [parentGroupId] or root.
  Future<void> restoreEntry(String entryId, {String? parentGroupId}) async {
    _ensureUnlocked();

    final pointer = _index!.entryPointers.firstWhere((p) => p.id == entryId);
    final entry = await fetchEntry(pointer);

    await saveEntry(
      entry.copyWith(
        deleted: false,
        groupId: parentGroupId ?? PdbxGroup.rootGroupId,
      ),
    );
  }

  /// Physically removes an entry from the index.
  Future<void> deleteEntry(String entryId) async {
    _ensureUnlocked();

    final originalLength = _index!.entryPointers.length;
    final updatedPointers = List<PdbxEntryPointer>.from(_index!.entryPointers)
      ..removeWhere((p) => p.id == entryId);

    if (updatedPointers.length == originalLength) return;

    _index = _index!.copyWith(entryPointers: updatedPointers);
    await _syncIndex();

    print('Удалена запись [$entryId].');
  }

  // ========================
  // === Group Operations ===
  // ========================

  /// Creates a new group within the storage.
  Future<PdbxGroup> createGroup({
    required String title,
    String? parentGroupId,
  }) async {
    _ensureUnlocked();

    final group = PdbxGroup.create(
      title: title,
      parentGroupId: parentGroupId ?? PdbxGroup.rootGroupId,
    );

    await saveGroup(group);
    return group;
  }

  /// Retrieves group metadata by its [groupId].
  PdbxGroup? getGroup(String groupId) {
    _ensureUnlocked();

    try {
      return _index!.groups.firstWhere((g) => g.id == groupId);
    } catch (_) {
      print('Группа [$groupId] не найдена.');
      return null;
    }
  }

  /// Updates or saves the group metadata.
  Future<void> saveGroup(PdbxGroup group) async {
    _ensureUnlocked();

    final updatedGroups = List<PdbxGroup>.from(_index!.groups)
      ..removeWhere((g) => g.id == group.id)
      ..add(group);

    _index = _index!.copyWith(groups: updatedGroups);
    await _syncIndex();

    print('Группа [${group.id}] сохранена.');
  }

  /// Moves a group to the trash. System groups cannot be trashed.
  Future<void> trashGroup(String groupId) async {
    _ensureUnlocked();

    if (groupId == PdbxGroup.rootGroupId || groupId == PdbxGroup.trashGroupId) {
      throw PdbxStorageException('Системные группы нельзя удалить.');
    }

    final group = getGroup(groupId);
    if (group == null) return;

    await saveGroup(
      group.copyWith(deleted: true, parentGroupId: PdbxGroup.trashGroupId),
    );

    print('Группа [$groupId] перемещена в корзину.');
  }

  /// Restores a deleted group.
  Future<void> restoreGroup(String groupId, {String? parentGroupId}) async {
    _ensureUnlocked();

    final group = getGroup(groupId);
    if (group == null) return;

    await saveGroup(
      group.copyWith(
        deleted: false,
        parentGroupId: parentGroupId ?? PdbxGroup.rootGroupId,
      ),
    );

    print(
      'Группа [$groupId] восстановлена (-> ${parentGroupId ?? PdbxGroup.rootGroupId}).',
    );
  }

  /// Permanently removes a group or marks it as deleted.
  Future<void> deleteGroup(String groupId, {bool permanent = false}) async {
    _ensureUnlocked();

    if (groupId == PdbxGroup.rootGroupId || groupId == PdbxGroup.trashGroupId) {
      throw PdbxStorageException('Системные группы нельзя удалить.');
    }

    final updatedGroups = List<PdbxGroup>.from(_index!.groups);

    if (permanent) {
      updatedGroups.removeWhere((g) => g.id == groupId);
    } else {
      final index = updatedGroups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        updatedGroups[index] = updatedGroups[index].copyWith(deleted: true);
      }
    }

    _index = _index!.copyWith(groups: updatedGroups);
    await _syncIndex();

    print('Группа [$groupId] удалена.');
  }

  /// Returns a list of subgroups for the specified [groupId].
  List<PdbxGroup> getSubgroups(String groupId) {
    _ensureUnlocked();
    return _index!.groups
        .where((g) => g.parentGroupId == groupId && !g.deleted)
        .toList();
  }

  // ==============================
  // === Query & Navigation API ===
  // ==============================

  /// Returns all entry pointers in the index.
  List<PdbxEntryPointer> get allEntries {
    _ensureUnlocked();
    return .unmodifiable(_index!.entryPointers);
  }

  /// Returns only non-deleted entry pointers.
  List<PdbxEntryPointer> get activeEntries {
    _ensureUnlocked();
    return .unmodifiable(_index!.entryPointers.where((p) => !p.deleted));
  }

  /// Returns the 10 most recently updated active entries.
  List<PdbxEntryPointer> get recentEntries {
    _ensureUnlocked();
    final pointers = _index!.entryPointers.where((p) => !p.deleted).toList();
    pointers.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return .unmodifiable(pointers.take(10));
  }

  /// Returns all active entries within a specific [groupId].
  List<PdbxEntryPointer> getEntriesInGroup(String groupId) {
    _ensureUnlocked();
    return .unmodifiable(
      _index!.entryPointers.where((p) => p.groupId == groupId && !p.deleted),
    );
  }

  /// Returns all groups in the index.
  List<PdbxGroup> get allGroups {
    _ensureUnlocked();
    return .unmodifiable(_index!.groups);
  }

  /// Returns all active groups (including system groups).
  List<PdbxGroup> get activeGroups {
    _ensureUnlocked();
    return .unmodifiable(
      _index!.groups.where((g) {
        if (g.id == PdbxGroup.rootGroupId || g.id == PdbxGroup.trashGroupId) {
          return true;
        }

        return !g.deleted;
      }),
    );
  }

  /// Returns groups that are children of the root group.
  List<PdbxGroup> get topLevelGroups {
    _ensureUnlocked();
    return .unmodifiable(
      _index!.groups.where(
        (g) => g.parentGroupId == PdbxGroup.rootGroupId && !g.deleted,
      ),
    );
  }

  /// Returns the root group instance.
  PdbxGroup get rootGroup {
    _ensureUnlocked();
    return _index!.groups.firstWhere((g) => g.id == PdbxGroup.rootGroupId);
  }

  /// Builds a list of groups representing the path from root to [groupId].
  List<PdbxGroup> getGroupPath(String groupId) {
    _ensureUnlocked();

    final path = <PdbxGroup>[];
    String? currentId = groupId;

    while (currentId != null) {
      final group = getGroup(currentId);
      if (group == null) break;

      path.insert(0, group);

      if (currentId == PdbxGroup.rootGroupId) break;
      currentId = group.parentGroupId;
    }

    return .unmodifiable(path);
  }

  /// Searches for entries across the entire storage by title.
  List<PdbxEntryPointer> searchEntriesInStorage(
    String query, {
    bool caseSensitive = false,
  }) {
    _ensureUnlocked();

    if (query.isEmpty) return [];

    return .unmodifiable(
      _index!.entryPointers.where((p) {
        query = caseSensitive ? query : query.toLowerCase();
        final title = caseSensitive ? p.title : p.title.toLowerCase();

        return title.contains(query);
      }),
    );
  }

  /// Searches for entries within a specific [groupId].
  List<PdbxEntryPointer> searchEntriesInGroup(
    String query,
    String groupId, {
    bool caseSensitive = false,
  }) {
    _ensureUnlocked();

    if (query.isEmpty) return [];

    return .unmodifiable(
      _index!.entryPointers.where((p) {
        query = caseSensitive ? query : query.toLowerCase();
        final title = caseSensitive ? p.title : p.title.toLowerCase();

        return p.groupId == groupId && title.contains(query) && !p.deleted;
      }),
    );
  }

  // ===========================
  // === Trash & Maintenance ===
  // ===========================

  /// Returns true if there are no deleted entries or groups.
  bool get isTrashEmpty {
    _ensureUnlocked();
    final hasDeletedEntries = _index!.entryPointers.any((p) => p.deleted);
    final hasDeletedGroups = _index!.groups.any(
      (g) => g.deleted && g.id != PdbxGroup.trashGroupId,
    );
    return !hasDeletedEntries && !hasDeletedGroups;
  }

  /// Returns all entry pointers currently in the trash.
  List<PdbxEntryPointer> get deletedEntries {
    _ensureUnlocked();
    return .unmodifiable(_index!.entryPointers.where((p) => p.deleted));
  }

  /// Returns all groups currently marked as deleted (excluding system trash).
  List<PdbxGroup> get deletedGroups {
    _ensureUnlocked();
    return .unmodifiable(
      _index!.groups.where((g) {
        if (g.id == PdbxGroup.trashGroupId) return false;
        return g.deleted;
      }),
    );
  }

  /// Permanently removes all items marked as deleted and compacts the storage.
  Future<void> emptyTrash() async {
    _ensureUnlocked();

    final excludedGroups = _index!.groups.where((g) {
      if (g.id == PdbxGroup.rootGroupId || g.id == PdbxGroup.trashGroupId) {
        return true;
      }

      return !g.deleted;
    }).toList();

    final excludedPointers = _index!.entryPointers
        .where((p) => !p.deleted)
        .toList();

    _index = _index!.copyWith(
      groups: excludedGroups,
      entryPointers: excludedPointers,
    );

    await _syncIndex();
    print('Корзина хранилища очищена.');
  }

  // ========================
  // === Storage Metadata ===
  // ========================

  /// Returns the timestamp of the last storage modification.
  DateTime get storageLastModified {
    _ensureUnlocked();
    return .fromMillisecondsSinceEpoch(_index!.updatedAt);
  }

  /// Returns the global revision number of the storage.
  int get storageRevision {
    _ensureUnlocked();
    return _index!.revision;
  }

  /// Returns the total number of entries, including deleted ones.
  int get totalEntriesCount {
    _ensureUnlocked();
    return _index!.entryPointers.length;
  }

  // =================
  // === Internals ===
  // =================

  void _ensureUnlocked() {
    if (locked || !indexLoaded) throw PdbxLockedException();
  }

  /// Synchronizes the in-memory index with the physical storage file.
  ///
  /// Re-calculates offsets and re-encrypts the index block.
  Future<void> _syncIndex({
    Uint8List? suggestedEntryBlock,
    String? suggestedEntryId,
  }) async {
    final tempFile = File('${storageFile.path}.tmp');

    try {
      final header = await _reader.readHeader();
      final allBlocks = <Uint8List>[];

      for (final pointer in _index!.entryPointers) {
        try {
          if (pointer.id == suggestedEntryId && suggestedEntryBlock != null) {
            allBlocks.add(suggestedEntryBlock);
          } else {
            allBlocks.add(
              await _reader.readEntryBlock(pointer.offset, pointer.size),
            );
          }
        } catch (e) {
          throw PdbxStorageException(
            'Ошибка чтения блока данных для [${pointer.title}]',
            e,
          );
        }
      }

      final indexIv = CryptoService.generateRandomIv();

      int lastIndexLength = 0;
      Uint8List finalEncryptedIndex;

      while (true) {
        finalEncryptedIndex = await _encryptIndex(indexIv);
        if (finalEncryptedIndex.length == lastIndexLength) break;

        lastIndexLength = finalEncryptedIndex.length;
        int offset = headerSize + lastIndexLength;

        final adjustedPointers = <PdbxEntryPointer>[];
        for (int i = 0; i < _index!.entryPointers.length; i++) {
          final pointer = _index!.entryPointers[i];
          final blockSize = allBlocks[i].length;
          adjustedPointers.add(
            pointer.copyWith(offset: offset, size: blockSize),
          );
          offset += blockSize;
        }

        _index = _index!.copyWith(entryPointers: adjustedPointers);
      }

      final tempWriter = BinaryWriter(tempFile);

      try {
        await tempWriter.writeTo(
          tempFile,
          version: header.version,
          salt: header.salt,
          iv: indexIv,
          encryptedIndex: finalEncryptedIndex,
          entryBlocks: allBlocks,
        );

        if (await storageFile.exists()) {
          await storageFile.delete();
        }

        await tempFile.rename(storageFile.path);
        print('Синхронизация завершена.');
      } catch (e) {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }

        throw PdbxStorageException('Ошибка записи на диск.', e);
      }
    } on PdbxException {
      rethrow;
    } catch (e) {
      throw PdbxStorageException('Ошибка синхронизации: $e');
    }
  }

  Future<Uint8List> _encryptIndex(Uint8List iv) async {
    final indexJson = utf8.encode(jsonEncode(_index!.toJson()));
    return await CryptoService.encrypt(.fromList(indexJson), _masterKey!, iv);
  }
}
