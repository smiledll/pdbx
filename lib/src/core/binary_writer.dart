import 'dart:io';
import 'dart:typed_data';

import 'package:pdbx/src/core/constants.dart';

/// A low-level utility for structured binary writing to PDBX storage files.
///
/// The [BinaryWriter] handles the assembly of the file header and the
/// sequential writing of encrypted blocks to the disk.
class BinaryWriter {
  /// The target file where the data will be written.
  final File file;

  /// Creates a [BinaryWriter] instance for the specified [file].
  BinaryWriter(this.file);

  /// Overwrites the storage file with a new structure.
  ///
  /// This method constructs the file header using the provided [version],
  /// [salt], and [iv], then writes the [encryptedIndex] followed by
  /// all [entryBlocks] in sequence.
  ///
  /// Uses a [RandomAccessFile] to ensure data is flushed and closed properly.
  Future<void> writeTo(
    File targetFile, {
    required int version,
    required Uint8List salt,
    required Uint8List iv,
    required Uint8List encryptedIndex,
    required List<Uint8List> entryBlocks,
  }) async {
    final raw = await targetFile.open(mode: .write);

    try {
      final header = _buildHeader(version, encryptedIndex.length, salt, iv);

      // Write header first (Fixed size: headerSize)
      await raw.writeFrom(header);

      // Write index block immediately after the header
      await raw.writeFrom(encryptedIndex);

      // Write all data entry blocks sequentially
      for (final block in entryBlocks) {
        await raw.writeFrom(block);
      }

      // Ensure all data is physically written to the storage device
      await raw.flush();
    } finally {
      await raw.close();
    }
  }

  /// Constructs the binary header for the PDBX file.
  ///
  /// The header structure (defined in constants) includes:
  /// * Magic number (4 bytes)
  /// * Format version (2 bytes)
  /// * Index length (4 bytes)
  /// * Salt for key derivation (32 bytes)
  /// * Initialization Vector for the index (16 bytes)
  Uint8List _buildHeader(
    int version,
    int indexLength,
    Uint8List salt,
    Uint8List iv,
  ) {
    final buffer = Uint8List(headerSize);
    final view = ByteData.view(buffer.buffer);

    // Set magic number and metadata
    view.setUint32(magicOffset, magic, .little);
    view.setUint16(versionOffset, version, .little);
    view.setUint32(indexLengthOffset, indexLength, .little);

    // Copy salt and IV to their respective offsets
    buffer.setRange(saltOffset, saltOffset + saltSize, salt);
    buffer.setRange(indexIvOffset, indexIvOffset + indexIvSize, iv);

    return buffer;
  }
}
