import 'package:flutter/cupertino.dart';

/// Thrown when an object that needs to be initialized is used before
/// initialization is complete.
class InitializationException<T> implements Exception {
  @override
  String toString() {
    return "${T.toString()} instance was not initialized";
  }
}

abstract class Initialized<T> {
  bool _didInit = false;

  /// Initializes this instance. It is necessary to call this method before
  /// using this instance in any capacity.
  Future<void> init() async {
    await onInit();
    _didInit = true;
  }

  @protected
  Future<void> onInit();

  @protected
  void assertInit() {
    if (!_didInit) throw InitializationException<T>();
  }
}
