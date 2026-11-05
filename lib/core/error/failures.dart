/// Base class for all domain-layer failures.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Failure from local Isar database operations.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Failure from remote network/API calls.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure when device is offline.
class NoInternetFailure extends Failure {
  const NoInternetFailure() : super('No internet connection.');
}

/// Failure when a requested entity is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Unexpected / unclassified failure.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}

