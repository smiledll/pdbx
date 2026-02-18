/// Base class for all PDBX-related exceptions.
///
/// This class is [sealed], meaning all possible exception types
/// are defined in this library, allowing for exhaustive pattern matching.
sealed class PdbxException implements Exception {
  /// A user-friendly message describing the error.
  final String message;

  /// The underlying error or stack trace, if available.
  final dynamic error;

  PdbxException(this.message, [this.error]);

  @override
  String toString() => 'PdbxException: $message';
}

/// Exception thrown when authentication fails.
///
/// Usually occurs due to an incorrect master password or
/// corrupted key derivation data.
class PdbxAuthException extends PdbxException {
  PdbxAuthException([
    super.message = 'Invalid master password or decryption key.',
  ]);
}

/// Exception thrown when performing operations on a locked manager.
///
/// Call `unlock()` before attempting to read or write data.
class PdbxLockedException extends PdbxException {
  PdbxLockedException([
    super.message = 'Operation denied: The storage is currently locked.',
  ]);
}

/// Exception thrown when the file structure is invalid.
///
/// Occurs if the file is not a PDBX storage, has a wrong magic number,
/// or has been corrupted.
class PdbxFormatException extends PdbxException {
  PdbxFormatException([
    super.message = 'The file is corrupted or not in a valid PDBX format.',
  ]);
}

/// Exception thrown during low-level I/O or storage failures.
///
/// Used for file system errors, such as "permission denied" or "disk full".
class PdbxStorageException extends PdbxException {
  PdbxStorageException(super.message, [super.origin]);
}
