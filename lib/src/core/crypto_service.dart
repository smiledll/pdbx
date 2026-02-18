import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:pdbx/src/core/constants.dart';

class CryptoService {
  static const memory = 65536;
  static const _iterations = 3;
  static const _parallelism = 4;

  static final _aes = AesGcm.with256bits();

  static double estimatePasswordEntropy(String password) {
    if (password.isEmpty) return 0.0;

    int poolSize = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) poolSize += 26;
    if (RegExp(r'[A-Z]').hasMatch(password)) poolSize += 26;
    if (RegExp(r'[0-9]').hasMatch(password)) poolSize += 10;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) poolSize += 33;

    final entropy = password.length * (log(poolSize) / log(2));
    return double.parse(entropy.toStringAsFixed(2));
  }

  static Future<Uint8List> deriveKey(String password, Uint8List salt) async {
    final algorithm = Argon2id(
      parallelism: _parallelism,
      memory: memory,
      iterations: _iterations,
      hashLength: 32,
    );

    final secretKey = await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );

    final keyBytes = await secretKey.extractBytes();

    return .fromList(keyBytes);
  }

  static Uint8List generateRandomBytes(int length) {
    final random = Random.secure();
    return .fromList(List.generate(length, (_) => random.nextInt(256)));
  }

  static Uint8List generateRandomIv() => CryptoService.generateRandomBytes(12);

  static Uint8List generateRandomSalt() =>
      CryptoService.generateRandomBytes(saltSize);

  static Future<Uint8List> encrypt(
    Uint8List data,
    Uint8List key,
    Uint8List iv,
  ) async {
    final secretKey = SecretKey(key);
    final secretBox = await _aes.encrypt(data, secretKey: secretKey, nonce: iv);

    return .fromList(secretBox.cipherText + secretBox.mac.bytes);
  }

  static Future<Uint8List> decrypt(
    Uint8List encryptedData,
    Uint8List key,
    Uint8List iv,
  ) async {
    final secretKey = SecretKey(key);
    final macBytes = encryptedData.sublist(encryptedData.length - 16);
    final cipherText = encryptedData.sublist(0, encryptedData.length - 16);
    final secretBox = SecretBox(cipherText, nonce: iv, mac: Mac(macBytes));
    final decrypted = await _aes.decrypt(secretBox, secretKey: secretKey);

    return .fromList(decrypted);
  }
}
