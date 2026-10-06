/// Base type for every recoverable failure surfaced to the UI.
///
/// Domain and presentation code return `Either<Failures, T>` so callers are
/// forced to handle both outcomes - there are no thrown exceptions crossing
/// the repository boundary.
abstract class Failures {
  const Failures(this.message);

  /// User-facing message. Never a raw exception or stack trace.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Remote API / connectivity problems.
class ServerFailure extends Failures {
  const ServerFailure(super.message);
}

/// Authentication problems (sign in, sign up, sign out).
class AuthFailure extends Failures {
  const AuthFailure(super.message);
}

/// Local storage (SQLite cache) problems.
class CacheFailure extends Failures {
  const CacheFailure(super.message);
}
