import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:intl/intl.dart';
import 'package:archive/archive.dart';
import 'package:quicksend/config.dart';

import '../exceptions.dart';
import 'crypto_utils.dart';
import '../models.dart';
import 'utils.dart';

final isoDateFormat = DateFormat("yyyy-MM-ddThh:mm:ss.SSS'Z'");
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
    final token = strBase64.encode("$_username:$_password");
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
    final methodStr = (options.method as String).toLowerCase();
    final signatureStr =
        "(request-target): $methodStr $target\nx-date: $dateStr\n";
    final signature = await CryptoUtils.sign(signatureStr, _key);
    options.headers ??= {};
    options.headers?["X-Date"] = dateStr;
    options.headers?["Authorization"] =
        'Signature keyId="$_deviceID",signature="$signature",headers="(request-target) x-date"';
  }

  String _getDateString() {
    final date = DateTime.now().toUtc();
    return isoDateFormat.format(date);
  }
}

class IncomingMessage {
  final String id;
  final String chat;
  final bool incoming;
  final DateTime sentAt;
  final Map<String, String> headers;
  final String key;
  final String iv;
  final String body;

  const IncomingMessage(
    this.id,
    this.chat,
    this.incoming,
    this.sentAt,
    this.headers,
    this.key,
    this.iv,
    this.body,
  );
}

class RequestManager {
  final _dio = dio.Dio();

  final _userInfo = CachedValue<UserInfo>();
  final _userInfoId = CachedMap<String, UserInfo?>();
  final _userInfoName = CachedMap<String, UserInfo?>();

  RequestManager() {
    _dio.options.baseUrl = Config.backendUri;
    _dio.options.headers["Accept"] = "application/json";
    _dio.options.validateStatus = (status) => true;
  }

  Future<String> createUser(
    String username,
    String password,
    String? display,
  ) async {
    final body = {
      "username": username,
      "password": password,
      "display": display
    };
    final res = await _request("POST", "/user/create", body: body);
    return res["id"];
  }

  Future<UserInfo> getUserInfo(SignatureAuthenticator auth) async {
    return _userInfo.get(() async {
      final res = await _request("GET", "/user/info", auth: auth);
      return UserInfo(
        id: res["id"],
        username: res["username"],
        display: res["display"],
        status: res["status"],
        pfpAssetId: res["profilePicture"],
      );
    });
  }

  Future<UserInfo?> getUserInfoFor(String id) async {
    return _userInfoId.get(id, (id) async {
      final res = await _request("GET", "/user/info/$id");
      if (res == null) return null;
      return UserInfo(
        id: res["id"],
        username: res["username"],
        display: res["display"],
        status: res["status"],
        pfpAssetId: res["profilePicture"],
      );
    });
  }

  Future<UserInfo?> findUser(String name) async {
    return _userInfoName.get(name, (name) async {
      final res = await _request("GET", "/user/find/$name");
      if (res == null) return null;
      return UserInfo(
        id: res["id"],
        username: res["username"],
        display: res["display"],
        status: res["status"],
        pfpAssetId: res["profilePicture"],
      );
    });
  }

  Future<void> updateUser(
    SignatureAuthenticator auth, {
    String? display,
    String? status,
    String? password,
  }) async {
    Map<String, String> body = {};
    if (display != null) body["display"] = display;
    if (status != null) body["status"] = status;
    if (password != null) body["password"] = password;
    await _request("POST", "/user/update", auth: auth, body: body);
  }

  Future<String> setUserPfp(
    SignatureAuthenticator auth,
    String mimeType,
    Uint8List imageData,
  ) async {
    final res = await _request(
      "POST",
      "/user/set-pfp",
      auth: auth,
      body: Stream.fromIterable(imageData),
      compress: true,
      options: dio.Options(
        contentType: mimeType,
        headers: {"Content-Length": imageData.length},
      ),
    );
    return res["id"];
  }

  Future<List<IncomingMessage>> pollMessages(
    SignatureAuthenticator auth,
  ) async {
    final List<dynamic> res = await _request("GET", "/messages/poll",
        auth: auth, acceptCompressed: true);
    return List.from(res.map((msg) => IncomingMessage(
          msg["id"],
          msg["chat"],
          msg["incoming"],
          DateTime.parse(msg["sentAt"]),
          Map.from(msg["headers"]),
          msg["key"],
          msg["iv"],
          msg["body"],
        )));
  }

  Future<Map<String, String>> getMessageTargets(
    SignatureAuthenticator auth,
    String userID,
  ) async {
    return Map.from(
      await _request("GET", "/messages/targets/$userID", auth: auth),
    );
  }

  Future<String> sendMessage(
    SignatureAuthenticator auth,
    String to,
    DateTime sentAt,
    Map<String, String> headers,
    Map<String, String> keys,
    String iv,
    String body,
  ) async {
    final reqBody = {
      "to": to,
      "sentAt": sentAt.toUtc().toIso8601String(),
      "headers": headers,
      "keys": keys,
      "iv": iv,
      "body": body
    };
    final res = await _request("POST", "/messages/send",
        auth: auth, body: reqBody, compress: true);
    return res["id"];
  }

  Future<void> clearMessages(SignatureAuthenticator auth) async {
    await _request("POST", "/messages/clear", auth: auth);
  }

  Future<String> addDevice(
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
    final res = await _request("POST", "/devices/add", auth: auth, body: body);
    return res["id"];
  }

  Future<void> removeDevice(SignatureAuthenticator auth, String id) async {
    final body = {"id": id};
    await _request("POST", "/devices/remove", auth: auth, body: body);
  }

  Future<List<DeviceInfo>> listDevices(SignatureAuthenticator auth) async {
    final res = await _request("GET", "/devices/list", auth: auth);
    assert(res is List<dynamic>);
    return List.from((res as List<dynamic>).map(
      (e) => DeviceInfo(
        id: e["id"],
        name: e["name"],
        type: e["type"],
        lastActivity: DateTime.parse(e["lastActivity"]),
      ),
    ));
  }

  Future<Uint8List> getSocketToken(SignatureAuthenticator auth) async {
    final res = await _request("GET", "/socket", auth: auth);
    return base64.decode(res["token"]);
  }

  void clearOwnUserInfoCache() {
    _userInfoId.clear();
  }

  void clearOtherUserInfoCache() {
    _userInfoId.clear();
    _userInfoName.clear();
  }

  List<int> _compressRequest(String request, dio.RequestOptions options) {
    final gzip = GZipEncoder();
    options.headers["Content-Encoding"] = "gzip";
    final compressed = gzip.encode(utf8.encode(request));
    if (compressed == null) {
      throw Exception("Request compression failed");
    }
    return compressed;
  }

  List<int> _decompressResponse(List<int> body) {
    final gzip = GZipDecoder();
    final decompressed = gzip.decodeBytes(body);
    return decompressed;
  }

  Future<dynamic> _request(
    String method,
    String target, {
    Authenticator? auth,
    dynamic body,
    dio.Options? options,
    bool compress = false,
    bool acceptCompressed = false,
  }) async {
    options ??= dio.Options();
    options.method = method;
    options.responseType = dio.ResponseType.bytes;

    if (Config.compressRequests && compress) {
      options.requestEncoder = _compressRequest;
    }
    if (acceptCompressed) {
      options.headers ??= {};
      options.headers!["Accept-Encoding"] = "gzip";
    }

    await auth?.authenticate(target, options);
    final response = await _dio.request(target, data: body, options: options);
    if (response.statusCode == null) throw Exception("Something broke :(");

    if (response.headers.value(dio.Headers.contentEncodingHeader) == "gzip") {
      response.data = _decompressResponse(response.data);
    }

    if (response.statusCode == 204) return null;
    final resObject = jsonDecode(utf8.decode(response.data));

    if ((response.statusCode as int) ~/ 100 != 2) {
      String? message = resObject["error"]?.toString();
      message ??= "(No error message provided)";
      throw RequestException(response.statusCode ?? 0, message);
    }

    final dynamic resBody = resObject["data"];
    return resBody;
  }
}
