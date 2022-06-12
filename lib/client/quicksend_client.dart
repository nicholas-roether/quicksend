import 'dart:typed_data';

import 'package:quicksend/client/internal/event_manager.dart';

import 'chat_list.dart';
import 'internal/chat_manager.dart';
import 'internal/initialized.dart';
import 'internal/login_manager.dart';
import 'internal/request_manager.dart';

import 'internal/db.dart';
import 'models.dart';

export 'chat.dart';
export 'chat_list.dart';
export 'models.dart';
export 'provider.dart';
export 'exceptions.dart';

class QuicksendClient with Initialized<QuicksendClient> {
  final _db = ClientDB();
  final _requestManager = RequestManager();
  late final _loginManager = LoginManager(
    db: _db,
    requestManager: _requestManager,
  );
  late final _eventManager = EventManager(
    requestManager: _requestManager,
    loginManager: _loginManager,
  );
  ChatManager? _chatManager;

  @override
  Future<void> onInit() async {
    await _db.init();
    await _loginManager.init();
    assert(false);
  }

  @override
  Future<void> afterInit() async {
    if (_loginManager.isLoggedIn()) await _onLoggedIn();
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
    String username,
    String password,
  ) async {
    assertInit();
    await _loginManager.logIn(username, password);
    await _db.reset();
    await _onLoggedIn();
  }

  /// Removes this device from the currently associated account and logs it out.
  /// Throws a [RequestException] if the logout attempt fails. The device will
  /// stay logged in if this happens.
  Future<void> logOut() async {
    assertInit();
    await _loginManager.logOut();
    await _onLoggedOut();
  }

  /// Removes the device with the provided [id] from this account. Throws
  /// an exception when attempting to remove the device that is currently logged
  /// in.
  Future<void> removeDevice(String id) async {
    if (id == _loginManager.deviceId) {
      throw Exception("Cannot remove the device that is currently in use");
    }
    final auth = await _loginManager.getAuthenticator();
    await _requestManager.removeDevice(auth, id);
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

  /// Update data for the current user. This method can be used to change the
  /// current user's status, display name, and/or password.
  Future<void> updateUser({
    String? status,
    String? display,
    String? password,
  }) async {
    assertInit();
    final auth = await _loginManager.getAuthenticator();
    await _requestManager.updateUser(
      auth,
      status: status,
      display: display,
      password: password,
    );
    _requestManager.clearOwnUserInfoCache();
  }

  /// Sets the logged in user's profile picture
  Future<void> setUserPfp(String mimeType, Uint8List image) async {
    assertInit();
    final auth = await _loginManager.getAuthenticator();
    await _requestManager.setUserPfp(auth, mimeType, image);
    _requestManager.clearOwnUserInfoCache();
  }

  /// Returns the ChatList instance for this client, which contains all open
  /// chats, which can be used to load and send messages.
  ChatList getChatList() {
    return _getChatManager().getChatList();
  }

  /// Gets all new messages from the server and saves them.
  Future<void> refreshMessages() {
    return _getChatManager().refreshMessages();
  }

  /// Gets a list of all devices registered to this account
  Future<List<DeviceInfo>> getRegisteredDevices() async {
    assertInit();
    final auth = await _loginManager.getAuthenticator();
    return await _requestManager.listDevices(auth);
  }

  ChatManager _getChatManager() {
    _loginManager.assertLoggedIn();

    return _chatManager!;
  }

  Future<void> _onLoggedIn() async {
    _chatManager = ChatManager(
      loginManager: _loginManager,
      eventManager: _eventManager,
      requestManager: _requestManager,
      db: _db,
    );
    await _eventManager.onLoggedIn();
  }

  Future<void> _onLoggedOut() async {
    _chatManager?.close();
    _chatManager = null;
    await _db.reset();
    _eventManager.onLoggedOut();
  }
}
