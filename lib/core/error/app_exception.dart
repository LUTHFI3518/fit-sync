/// Base exception class for app errors
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception for storage operations
class StorageException extends AppException {
  StorageException(super.message, {super.code});
}

/// Exception for network operations
class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

/// Exception for validation errors
class ValidationException extends AppException {
  ValidationException(super.message, {super.code});
}

/// Exception for authentication errors
class AuthenticationException extends AppException {
  AuthenticationException(super.message, {super.code});
}

/// Exception for camera/image operations
class CameraException extends AppException {
  CameraException(super.message, {super.code});
}
