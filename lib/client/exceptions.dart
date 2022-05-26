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

/// Thrown when the backend server returns an error for a request.
class RequestException implements Exception {
  /// The HTTP status of the server's response
  int status;

  /// The error messsage sent by the server
  String message;

  RequestException(this.status, this.message);

  @override
  String toString() {
    return "[$status] $message";
  }
}
