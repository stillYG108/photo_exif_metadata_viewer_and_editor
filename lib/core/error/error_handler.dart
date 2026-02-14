import 'failures.dart';

/// Error handler utility class
class ErrorHandler {
  /// Get user-friendly error message from failure
  static String getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return '⚠️ SYSTEM ERROR: ${failure.message}';
      case NetworkFailure:
        return '📡 CONNECTION LOST: ${failure.message}';
      case AuthenticationFailure:
        return '🔒 ACCESS DENIED: ${failure.message}';
      case ValidationFailure:
        return '⚡ INVALID INPUT: ${failure.message}';
      case PermissionFailure:
        return '🚫 INSUFFICIENT CLEARANCE: ${failure.message}';
      default:
        return '❌ UNKNOWN ERROR: ${failure.message}';
    }
  }
  
  /// Log error with stack trace
  static void logError(Failure failure, StackTrace? stackTrace) {
    print('[ERROR] ${failure.code}: ${failure.message}');
    if (stackTrace != null) {
      print('[STACK TRACE]\n$stackTrace');
    }
  }
}
