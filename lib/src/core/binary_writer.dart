import 'dart:io';
import 'dart:typed_data';

import 'package:pdbx/src/core/constants.dart';

class BinaryWriter {
  final File file;

  BinaryWriter(this.file);

  /// Перезаписывает весь файл хранилища.
  Future<void> writeTo(
    File targetFile, {
    required int version,
    required Uint8List salt,
    required Uint8List iv,
    required Uint8List encryptedIndex,
    required List<Uint8List> entryBlocks,
  }) async {
    print('Подготовка к записи');
    final raw = await targetFile.open(mode: .write);

    try {
      final header = _buildHeader(version, encryptedIndex.length, salt, iv);

      await raw.writeFrom(header);
      await raw.writeFrom(encryptedIndex);

      for (final block in entryBlocks) {
        await raw.writeFrom(block);
      }

      await raw.flush();
    } finally {
      await raw.close();
    }
  }

  Uint8List _buildHeader(
    int version,
    int indexLength,
    Uint8List salt,
    Uint8List iv,
  ) {
    final buffer = Uint8List(headerSize);
    final view = ByteData.view(buffer.buffer);

    view.setUint32(magicOffset, magic, .little);
    view.setUint16(versionOffset, version, .little);
    view.setUint32(indexLengthOffset, indexLength, .little);

    buffer.setRange(saltOffset, saltOffset + saltSize, salt);
    buffer.setRange(indexIvOffset, indexIvOffset + indexIvSize, iv);

    print('Заголовок хранилища собран.');
    return buffer;
  }
}
