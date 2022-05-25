/// Thrown when an object that needs to be initialized is used before
/// initialization is complete.
class InitializationException<T> implements Exception {
  @override
  String toString() {
    return "${T.toString()} instance was not initialized";
  }
}

/// Thrown primarily when attempting to perform an action that requires this
/// device to be logged into an account, when it is not.
class LoginStateException implements Exception {
  final String message;

  const LoginStateException(this.message);

  @override
  String toString() {
    return message;
  }
}

class RequestException implements Exception {
  int status;
  String message;

  RequestException(this.status, this.message);

  @override
  String toString() {
    return "[$status] $message";
  }
}
