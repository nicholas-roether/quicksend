import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:quicksend/client/crypto_utils.dart';
import 'package:quicksend/client/db.dart';

class User {
  final String username;
  final String display;

  const User(this.username, this.display);
}

class AuthManager {
  static final Codec<String, String> strBase64 = utf8.fuse(base64);

  bool _inititalized = false;
  bool _loggedIn = false;
  final ClientDB _db;
  final Dio _dio;

  AuthManager(this._db, this._dio);

  Future<void> init() async {
    if (_inititalized) return;
    _loggedIn = await _db.getSignatureKey() != null;
    _inititalized = true;
  }

  Future<void> registerDevice(
    String deviceName,
    String username,
    String password,
  ) async {
    _assertInit();

    final keypairs = await Future.wait([
      CryptoUtils.generateKeypair(),
      CryptoUtils.generateKeypair(),
    ]);

    final res = await _dio.post(
      "/devices/add",
      data: {
        "name": deviceName,
        "type": 1,
        "signaturePublicKey": keypairs[0].public,
        "encryptionPublicKey": keypairs[1].public
      },
      options: _authenticateBasic(username, password),
    );
    if (res.statusCode != 200) {
      throw Exception("Device registration failed: ${res.data.error}");
    }

    final String deviceID = res.data.data.id;
    _db.setDeviceID(deviceID);

    await Future.wait([
      _db.setSignatureKey(keypairs[0].private),
      _db.setEncryptionKey(keypairs[1].private),
    ]);
  }

  Future<User> getUserInfo() async {
    final res = await _dio.get(
      "/user/info",
      options: await _authenticateSignature("get", "/user/info"),
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to get user info: ${res.data.error}");
    }
    final body = res.data;
    return User(body.data.username, body.data.display);
  }

  bool isLoggedIn() {
    _assertInit();
    return _loggedIn;
  }

  void _assertInit() {
    if (!_inititalized) throw Exception("AuthManager was not initialized");
  }

  Options _authenticateBasic(String username, String password) {
    final token = strBase64.encode("$username:$password");
    return Options(headers: {
      "Authorization": "Basic $token",
    });
  }

  Future<Options> _authenticateSignature(String method, String path) async {
    if (_loggedIn) throw Exception("Not logged in");
    final deviceID = _db.getDeviceID();
    if (deviceID == null) throw Exception("Device ID not found");
    final key = await _db.getSignatureKey();
    if (key == null) throw Exception("Signature key not found");

    final date = _getDateISOString();
    final signatureStr = "(request-target): $method $path\ndate: $date\n";
    final signature = await CryptoUtils.sign(signatureStr, key);

    return Options(headers: {
      "Date": date,
      "Authorization":
          'Signature keyId="$deviceID",signature="$signature",headers="(request-target) date"'
    });
  }

  String _getDateISOString() {
    final dateTime = DateTime.now().toUtc();
    final noMicroseconds = DateTime.utc(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
      dateTime.millisecond,
      0,
    );
    return noMicroseconds.toIso8601String();
  }
}
