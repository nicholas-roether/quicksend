import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quicksend/client/initialized.dart';

class ClientDB extends Initialized<ClientDB> {
  static const _secureStorage = FlutterSecureStorage();
  late final Box _storage;

  @override
  Future<void> onInit() async {
    await Hive.initFlutter();
    _storage = await Hive.openBox("quicksend-client");
  }

  String? getDeviceID() {
    assertInit();
    return _storage.get("device-id");
  }

  void setDeviceID(String? id) {
    assertInit();
    _storage.put("device-id", id);
  }

  Future<String?> getSignatureKey() async {
    assertInit();
    return await _secureStorage.read(key: "signature-key");
  }

  Future<void> setSignatureKey(String? key) async {
    assertInit();
    await _secureStorage.write(key: "signature-key", value: key);
  }

  Future<String?> getEncryptionKey() async {
    assertInit();
    return await _secureStorage.read(key: "encryption-key");
  }

  Future<void> setEncryptionKey(String? key) async {
    assertInit();
    await _secureStorage.write(key: "encryption-key", value: key);
  }
}
