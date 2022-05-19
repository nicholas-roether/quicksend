import 'package:quicksend/client/initialized.dart';
import 'package:quicksend/client/login_manager.dart';
import 'package:quicksend/client/request_manager.dart';

import 'db.dart';

class _QuicksendClient extends Initialized<_QuicksendClient> {
  final _db = ClientDB();
  final _requestManager = RequestManager();
  late final _loginManager = LoginManager(_db, _requestManager);

  @override
  Future<void> onInit() async {
    await _db.init();
    await _loginManager.init();
  }

  /// Creates a new account with the provided [username] and [password], as well
  /// as optionally with the provided display name ([display]). Throws a
  /// [RequestException] if account creation fails.
  ///
  /// Calling this function will not automatically log this device in; please
  /// call `quicksendClient.logIn(...)` seperately, but do NOT permanently save
  /// the user credentials.
  Future<void> createAccount(
    String username,
    String password,
    String? display,
  ) async {
    assertInit();
    await _requestManager.createUser(username, password, display);
  }

  /// Returns `true` if this device is logged into an account.
  bool isLoggedIn() {
    assertInit();
    return _loginManager.isLoggedIn();
  }

  /// Registers this device to an account and logs it in. For this it is
  /// necessary to not only provide the account [username] and [password], but
  /// also a name for this device, [deviceName], that is unique among all
  /// devices registered to this account. Does nothing if this device is
  /// already logged in. Throws a [RequestException] if the login attempt fails.
  ///
  /// Note that this function generates RSA keypairs for this device, and can
  /// therefore take quite a long time to execute.
  Future<void> logIn(
    String deviceName,
    String username,
    String password,
  ) async {
    assertInit();
    await _loginManager.logIn(deviceName, username, password);
  }

  /// Removes this device from the currently associated account and logs it out.
  /// Throws a [RequestException] if the logout attempt fails. The device will
  /// stay logged in if this happens.
  Future<void> logOut() async {
    assertInit();
    await _loginManager.logOut();
  }

  /// Returns the user info of the currently logged in account. Will throw a
  /// [LoginStateException] if this device is not logged into any account
  /// (use `quicksendClient.isLoggedIn()` to check beforehand), and throws a
  /// [RequestException] if the user info request fails.
  Future<UserInfo> getUserInfo() async {
    assertInit();
    _loginManager.assertLoggedIn();
    SignatureAuthenticator auth = await _loginManager.getAuthenticator();
    return await _requestManager.getUserInfo(auth);
  }

  /// Returns the user info for the user with the given ID. Returns null if the
  /// User with the ID does not exist. Throws a [RequestException] if the
  /// user info request fails.
  Future<UserInfo?> getUserInfoFor(String id) async {
    assertInit();
    return await _requestManager.getUserInfoFor(id);
  }
}

/// The API used for interaction with the quicksend system.
///
/// See `/client/quicksend_client.dart` for more details.
final quicksendClient = _QuicksendClient();
