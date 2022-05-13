import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class ClientDB {
  static final _storage = Hive.box("quicksend-client");
  static const _secureStorage = FlutterSecureStorage();

  String? getDeviceID() {
    return _storage.get("device-id");
  }

  void setDeviceID(String id) {
    _storage.put("device-id", id);
  }

  Future<String?> getSignatureKey() async {
    return await _secureStorage.read(key: "signature-key");
  }

  Future<void> setSignatureKey(String key) async {
    await _secureStorage.write(key: "signature-key", value: key);
  }

  Future<String?> getEncryptionKey() async {
    return await _secureStorage.read(key: "encryption-key");
  }

  Future<void> setEncryptionKey(String key) async {
    await _secureStorage.write(key: "encryption-key", value: key);
  }
}
