class CachedValue<T> {
  T? cached;

  Future<T> get(Future<T> Function() getter) async {
    cached ??= await getter();
    return cached!;
  }
}

class CachedMap<K, V> {
  final Map<K, V> _values = {};

  Future<V> get(K key, Future<V> Function(K key) getter) async {
    _values[key] ??= await getter(key);
    return _values[key]!;
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
