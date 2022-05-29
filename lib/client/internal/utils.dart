class CachedValue<T> {
  T? chached;

  Future<T> get(Future<T> Function() getter) {
    if (chached != null) return Future.value(chached);
    return getter();
  }
}

typedef EventListener = void Function(dynamic data);

class EventSource {
  final Map<String, Set<EventListener>> _listeners = {};

  void on(String event, EventListener listener) {
    if (!_listeners.containsKey(event)) _listeners[event] = {};
    _listeners[event]!.add(listener);
  }

  void removeListener(String event, EventListener listener) {
    if (!_listeners.containsKey(event)) return;
    _listeners[event]!.remove(listener);
  }

  void emit(String event, {dynamic data}) {
    if (!_listeners.containsKey(event)) return;
    for (final listener in _listeners[event]!) {
      listener(data);
    }
  }
}
