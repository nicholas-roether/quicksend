import 'package:quicksend/client/internal/crypto_utils.dart';
import 'package:quicksend/client/internal/db.dart';
import 'package:quicksend/client/internal/initialized.dart';
import 'package:quicksend/client/internal/platform_utils.dart';
import 'package:quicksend/client/internal/request_manager.dart';

import '../exceptions.dart';

class LoginManager with Initialized<LoginManager> {
  final ClientDB _db;
  final RequestManager _requestManager;
  bool _loggedIn = false;

  LoginManager({required ClientDB db, required RequestManager requestManager})
      : _db = db,
        _requestManager = requestManager;

  String get userId {
    assertInit();
    assertLoggedIn();
    return _db.getUserID()!;
  }

  String get deviceId {
    assertInit();
    assertLoggedIn();
    return _db.getDeviceID()!;
  }

  Future<void> logIn(
    String username,
    String password,
  ) async {
    assertInit();
    if (isLoggedIn()) return;
    final userInfo = await _requestManager.findUser(username);
    if (userInfo == null) throw UnknownUserException(username);
    final basicAuth = BasicAuthenticator(username, password);
    final keypairs = await Future.wait([
      CryptoUtils.generateKeypair(),
      CryptoUtils.generateKeypair(),
    ]);
    final sigKeypair = keypairs[0];
    final encKeypair = keypairs[1];

    final platformInfo = await getPlatformInfo();
    final deviceID = await _requestManager.addDevice(
      basicAuth,
      platformInfo.deviceDescriptor,
      platformInfo.platformCode,
      sigKeypair.public,
      encKeypair.public,
    );

    await _db.setDeviceID(deviceID);
    await _db.setUserID(userInfo.id);
    await _db.setSignatureKey(sigKeypair.private);
    await _db.setEncryptionKey(encKeypair.private);
  }

  Future<void> logOut() async {
    assertInit();
    assertLoggedIn();
    final SignatureAuthenticator auth = await getAuthenticator();
    final String deviceID = _db.getDeviceID() as String;
    await _requestManager.removeDevice(auth, deviceID);
    await _localLogout();
  }

  bool isLoggedIn() {
    return _db.getDeviceID() != null;
  }

  void assertLoggedIn() {
    assertInit();
    if (!isLoggedIn()) throw const LoginStateException("Not logged in!");
  }

  Future<SignatureAuthenticator> getAuthenticator() async {
    assertInit();
    assertLoggedIn();
    return await _getAuthenticatorUnchecked();
  }

  Future<SignatureAuthenticator> _getAuthenticatorUnchecked() async {
    final sigKey = await _db.getSignatureKey();
    final deviceID = _db.getDeviceID();
    assert(sigKey != null);
    assert(deviceID != null);
    return SignatureAuthenticator(sigKey as String, deviceID as String);
  }

  Future<void> _localLogout() async {
    await _db.setDeviceID(null);
    await _db.setUserID(null);
    await _db.setEncryptionKey(null);
    await _db.setSignatureKey(null);
  }

  @override
  Future<void> onInit() async {
    if (_db.getDeviceID() != null) {
      try {
        final auth = await _getAuthenticatorUnchecked();
        await _requestManager.getUserInfo(auth);
        _loggedIn = true;
      } on RequestException catch (err) {
        if (err.status == 401) {
          await _localLogout();
        } else {
          rethrow;
        }
      }
    } else {
      await _localLogout();
    }
    if (isLoggedIn()) {
      final sigKey = await _db.getSignatureKey();
      final encKey = await _db.getEncryptionKey();

      if (sigKey == null || encKey == null) {
        throw const LoginStateException(
          "Should be logged in, but at least one of the private keys could not be found. This is bad and should not happen.",
        );
      }
    }
  }
}
