import 'package:quicksend/client/internal/crypto_utils.dart';
import 'package:quicksend/client/internal/db.dart';
import 'package:quicksend/client/internal/initialized.dart';
import 'package:quicksend/client/internal/request_manager.dart';

import '../exceptions.dart';

class LoginManager extends Initialized<LoginManager> {
  final ClientDB _db;
  final RequestManager _requestManager;
  bool _isLoggedIn = false;

  LoginManager({required ClientDB db, required RequestManager requestManager})
      : _db = db,
        _requestManager = requestManager;

  Future<void> logIn(
    String deviceName,
    String username,
    String password,
  ) async {
    assertInit();
    if (_isLoggedIn) return;
    final userInfo = await _requestManager.findUser(username);
    if (userInfo == null) throw UnknownUserException(username);
    final basicAuth = BasicAuthenticator(username, password);
    final keypairs = await Future.wait([
      CryptoUtils.generateKeypair(),
      CryptoUtils.generateKeypair(),
    ]);
    final sigKeypair = keypairs[0];
    final encKeypair = keypairs[1];

    final deviceID = await _requestManager.addDevice(
      basicAuth,
      deviceName,
      1,
      sigKeypair.public,
      encKeypair.public,
    );

    _db.setDeviceID(deviceID);
    await _db.setSignatureKey(sigKeypair.private);
    await _db.setEncryptionKey(encKeypair.private);
    _isLoggedIn = true;
  }

  Future<void> logOut() async {
    assertInit();
    assertLoggedIn();
    final SignatureAuthenticator auth = await getAuthenticator();
    final String deviceID = _db.getDeviceID() as String;
    await _requestManager.removeDevice(auth, deviceID);
    _isLoggedIn = false;
  }

  bool isLoggedIn() {
    assertInit();
    return _isLoggedIn;
  }

  void assertLoggedIn() {
    assertInit();
    if (!_isLoggedIn) throw const LoginStateException("Not logged in!");
  }

  Future<SignatureAuthenticator> getAuthenticator() async {
    assertInit();
    assertLoggedIn();
    final sigKey = await _db.getSignatureKey();
    final deviceID = _db.getDeviceID();
    assert(sigKey != null);
    assert(deviceID != null);
    return SignatureAuthenticator(sigKey as String, deviceID as String);
  }

  @override
  Future<void> onInit() async {
    final deviceId = _db.getDeviceID();
    _isLoggedIn = deviceId != null;
    if (_isLoggedIn) {
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
