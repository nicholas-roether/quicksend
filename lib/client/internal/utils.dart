class CachedValue<T> {
  static const defaultLifetime = 300000; // 5 minutes

  final int lifetime;
  int? lastUpdate;
  T? cached;

  CachedValue({this.lifetime = defaultLifetime});

  Future<T> get(Future<T> Function() getter) async {
    if (lastUpdate == null ||
        lastUpdate! - DateTime.now().millisecondsSinceEpoch > lifetime) {
      cached = await getter();
      lastUpdate = DateTime.now().millisecondsSinceEpoch;
    }
    return cached as T;
  }

  void clear() {
    lastUpdate = null;
  }
}

class CachedMap<K, V> {
  final Map<K, CachedValue<V>> _values = {};

  Future<V> get(K key, Future<V> Function(K key) getter) async {
    if (!_values.containsKey(key)) _values[key] = CachedValue();
    return _values[key]!.get(() => getter(key));
  }

  void clear() {
    _values.clear();
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
