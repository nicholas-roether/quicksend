import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:quicksend/client/crypto_utils.dart';
import 'package:intl/intl.dart';

class User {
  final String username;
  final String display;

  const User(this.username, this.display);
}

final isoDateFormat = DateFormat("yyyy-MM-ddThh:mm:ss.SSSZ");
final Codec<String, String> strBase64 = utf8.fuse(base64);

abstract class Authenticator {
  const Authenticator();

  Future<void> authenticate(String target, dio.Options options);
}

class BasicAuthenticator extends Authenticator {
  final String _username;
  final String _password;

  const BasicAuthenticator(this._username, this._password);

  @override
  Future<void> authenticate(String target, dio.Options options) async {
    final token = strBase64.encode("$_username:$_password}");
    options.headers ??= {};
    options.headers?["Authorization"] = "Basic $token";
  }
}

class SignatureAuthenticator extends Authenticator {
  final String _key;
  final String _deviceID;

  const SignatureAuthenticator(this._key, this._deviceID);

  @override
  Future<void> authenticate(String target, dio.Options options) async {
    final dateStr = _getDateString();
    assert(options.method != null);
    final signatureStr =
        "(request-target): ${options.method} $target\nx-date: $dateStr\n";
    final signature = await CryptoUtils.sign(signatureStr, _key);
    options.headers ??= {};
    options.headers?["X-Date"] = dateStr;
    options.headers?["Authorization"] =
        'Signature keyId="$_deviceID",signature"$signature",headers="(request-target) x-date';
  }

  String _getDateString() {
    final date = DateTime.now().toUtc();
    return isoDateFormat.format(date);
  }
}

class UserInfo {
  final String id;
  final String username;
  final String? display;

  const UserInfo(this.id, this.username, this.display);

  String getName() {
    return display ?? username;
  }
}

class DeviceInfo {
  final String id;
  final String name;
  final int type;
  final DateTime lastActivity;

  const DeviceInfo(this.id, this.name, this.type, this.lastActivity);
}

class RequestException implements Exception {
  int status;
  String message;

  RequestException(this.status, this.message);

  @override
  String toString() {
    return "Error $status: $message";
  }
}

class RequestManager {
  static final _dio = dio.Dio();

  static Future<String> createUser(
    String username,
    String password,
    String? display,
  ) async {
    final body = {
      "username": username,
      "password": password,
      "display": display
    };
    final res = await _request("/user/create", body: body);
    return res["id"];
  }

  static Future<UserInfo> getUserInfo(SignatureAuthenticator auth) async {
    final res = await _request("/user/info", auth: auth);
    return UserInfo(res["id"], res["username"], res["display"]);
  }

  static Future<String> addDevice(
    BasicAuthenticator auth,
    String name,
    int type,
    String signatureKey,
    String encryptionKey,
  ) async {
    final body = {
      "name": name,
      "type": type,
      "signaturePublicKey": signatureKey,
      "encryptionPublicKey": encryptionKey
    };
    final deviceID = await _request("/devices/add", auth: auth, body: body);
    return deviceID;
  }

  static Future<void> removeDevice(
      SignatureAuthenticator auth, String id) async {
    final body = {"id": id};
    await _request("/devices/remove", auth: auth, body: body);
  }

  static Future<List<DeviceInfo>> listDevices(
      SignatureAuthenticator auth) async {
    final res = await _request("/devices/list", auth: auth);
    assert(res is List<dynamic>);
    return List.from((res as List<dynamic>).map(
      (e) => DeviceInfo(
        e["id"],
        e["name"],
        e["type"],
        DateTime.parse(e["lastActivity"]),
      ),
    ));
  }

  static Future<dynamic> _request(
    String target, {
    Authenticator? auth,
    dynamic body,
    dio.Options? options,
  }) async {
    options ??= dio.Options();
    auth?.authenticate(target, options);
    final response = await _dio.request(target, data: body, options: options);
    if (response.statusCode == null) throw Exception("Something broke :(");
    if ((response.statusCode as int) / 100 != 2) {
      String? message = response.data["error"]?.toString();
      message ??= "No error message provided";
      throw RequestException(response.statusCode ?? 0, message);
    }
    final resBody = response.data["data"];
    return resBody;
  }
}
