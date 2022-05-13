import 'package:dio/dio.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:quicksend/client/auth.dart';

import 'db.dart';

class _QuicksendClient {
  static final _dio =
      Dio(BaseOptions(baseUrl: FlutterConfig.get("SERVER_URI")));
  static final _db = ClientDB();
  static final _auth = AuthManager(_db, _dio);

  Future<void> init() async {
    await _auth.init();
  }

  bool isLoggedIn() {
    return _auth.isLoggedIn();
  }

  Future<User> getUserInfo() {
    return _auth.getUserInfo();
  }

  Future<void> registerDevice(
    String deviceName,
    String username,
    String password,
  ) {
    return _auth.registerDevice(deviceName, username, password);
  }
}

final quicksendClient = _QuicksendClient();
