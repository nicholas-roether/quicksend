class CachedValue<T> {
  T? chached;

  Future<T> get(Future<T> Function() getter) {
    if (chached != null) return Future.value(chached);
    return getter();
  }
}
