/// Base class for all data-layer exceptions.
/// Exceptions are thrown by datasources and caught in repositories,
/// where they are converted to [Failure] objects.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when an Isar database operation fails.
class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

/// Thrown when a network request fails (non-2xx, timeout, etc.).
class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException(super.message, {this.statusCode});
}

/// Thrown when the device has no internet connectivity.
class NoInternetException extends AppException {
  const NoInternetException() : super('No internet connection.');
}

/// Thrown when the requested resource is not found.
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

