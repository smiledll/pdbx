sealed class PdbxException implements Exception {
  final String message;
  final dynamic error;

  PdbxException(this.message, [this.error]);

  @override
  String toString() => 'PdbxException: $message';
}

class PdbxAuthException extends PdbxException {
  PdbxAuthException([super.message = 'Неверный пароль или ключ расшифровки.']);
}

class PdbxLockedException extends PdbxException {
  PdbxLockedException([
    super.message = 'Операция отклонена: хранилище заблокировано.',
  ]);
}

class PdbxFormatException extends PdbxException {
  PdbxFormatException([
    super.message = 'Файл повреждён или имеет неверный формат.',
  ]);
}

class PdbxStorageException extends PdbxException {
  PdbxStorageException(super.message, [super.origin]);
}
