import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:pdbx/src/core/constants.dart';

/// A low-level utility for reading structured binary data from PDBX storage files.
///
/// The [BinaryReader] provides methods to validate file integrity,
/// extract the header, and read encrypted data blocks.
class BinaryReader {
  /// The storage file to be read.
  final File file;

  /// Creates a [BinaryReader] instance for the specified [file].
  BinaryReader(this.file);

  /// Validates the file integrity by checking for the PDBX magic number.
  ///
  /// Returns `true` if the file exists and starts with the expected
  /// 4-byte signature ([magic]).
  Future<bool> isValid() async {
    if (!await file.exists()) return false;

    final raw = await file.open(mode: .read);

    try {
      if (await raw.length() < magicSize) {
        return false;
      }

      final bytes = await raw.read(magicSize);
      return ByteData.sublistView(bytes).getUint32(magicOffset, .little) ==
          magic;
    } finally {
      await raw.close();
    }
  }

  /// Reads and parses the fixed-size file header.
  ///
  /// Contains essential metadata for decryption, such as the [salt]
  /// and [indexIv].
  Future<PdbxHeader> readHeader() async {
    final raw = await file.open(mode: .read);

    try {
      final bytes = await raw.read(headerSize);
      final view = ByteData.view(bytes.buffer);

      return .new(
        version: view.getUint16(versionOffset, .little),
        indexLength: view.getUint32(indexLengthOffset, .little),
        salt: bytes.sublist(saltOffset, saltOffset + saltSize),
        indexIv: bytes.sublist(indexIvOffset, indexIvOffset + indexIvSize),
      );
    } finally {
      await raw.close();
    }
  }

  /// Reads a raw data block of a specific [size] starting at the given [offset].
  ///
  /// Used internally to fetch both the index and individual entry blocks.
  Future<Uint8List> readGeneralBlock(int offset, int size) async {
    final raw = await file.open(mode: .read);

    try {
      await raw.setPosition(offset);
      return await raw.read(size);
    } finally {
      await raw.close();
    }
  }

  /// Convenience method to read the encrypted index block.
  Future<Uint8List> readIndexBlock(int offset, int size) async =>
      await readGeneralBlock(offset, size);

  /// Convenience method to read an encrypted entry block.
  Future<Uint8List> readEntryBlock(int offset, int size) async =>
      await readGeneralBlock(offset, size);
}

/// Represents the PDBX file header containing file format metadata.
@immutable
class PdbxHeader {
  /// The version of the PDBX format used to write this file.
  final int version;

  /// The size (in bytes) of the encrypted index block.
  final int indexLength;

  /// The random salt used for master key derivation.
  final Uint8List salt;

  /// The Initialization Vector (IV) used to encrypt the index block.
  final Uint8List indexIv;

  /// Creates a [PdbxHeader] with the required metadata.
  const PdbxHeader({
    required this.version,
    required this.indexLength,
    required this.salt,
    required this.indexIv,
  });

  /// Calculates the file offset where the index block starts.
  int get indexOffset => headerSize;

  /// Calculates the file offset where the password entry blocks start.
  int get entryBlocksOffset => headerSize + indexLength;
}
