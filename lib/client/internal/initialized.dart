import '../exceptions.dart';

abstract class Initialized<T> {
  bool _didInit = false;

  /// Initializes this instance. It is necessary to call this method before
  /// using this instance in any capacity.
  Future<void> init() async {
    await onInit();
    _didInit = true;
  }

  Future<void> onInit();

  void assertInit() {
    if (!_didInit) throw InitializationException<T>();
  }
}
