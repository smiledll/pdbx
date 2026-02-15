class PdbxException implements Exception {
  final String message;

  PdbxException(this.message);
}

class ValidationException extends PdbxException {
  ValidationException(super.message);
}
