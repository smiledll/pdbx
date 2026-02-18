import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:pdbx/src/core/constants.dart';

class BinaryReader {
  final File file;

  BinaryReader(this.file);

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

  Future<Uint8List> readGeneralBlock(int offset, int size) async {
    final raw = await file.open(mode: .read);

    try {
      await raw.setPosition(offset);
      return await raw.read(size);
    } finally {
      await raw.close();
    }
  }

  Future<Uint8List> readIndexBlock(int offset, int size) async =>
      await readGeneralBlock(offset, size);

  Future<Uint8List> readEntryBlock(int offset, int size) async =>
      await readGeneralBlock(offset, size);
}

@immutable
class PdbxHeader {
  final int version;
  final int indexLength;
  final Uint8List salt;
  final Uint8List indexIv;

  const PdbxHeader({
    required this.version,
    required this.indexLength,
    required this.salt,
    required this.indexIv,
  });

  int get indexOffset => headerSize;

  int get entryBlocksOffset => headerSize + indexLength;
}
