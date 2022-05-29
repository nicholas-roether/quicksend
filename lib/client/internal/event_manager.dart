import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quicksend/client/internal/login_manager.dart';
import 'package:quicksend/client/internal/request_manager.dart';

import 'utils.dart';

class EventManager extends EventSource {
  final LoginManager _loginManager;
  final RequestManager _requestManager;
  late final String _socketUri;
  WebSocket? _ws;

  EventManager({
    required LoginManager loginManager,
    required RequestManager requestManager,
  })  : _loginManager = loginManager,
        _requestManager = requestManager {
    final socketUri = dotenv.env["SOCKET_URI"];
    assert(
      socketUri != null,
      "A URI to the WebSocket endpoint must be provided",
    );
    _socketUri = socketUri!;
  }

  Future<void> onLoggedIn() async {
    final auth = await _loginManager.getAuthenticator();
    final token = _requestManager.getSocketToken(auth);
    _ws = await WebSocket.connect(
      _socketUri,
      headers: {"Authorization": "Token $token"},
    );
    _listen();
  }

  Future<void> _listen() async {
    await for (final msg in _ws!) {
      emit(msg["event"], data: msg["data"]);
    }
  }

  Future<void> onLoggedOut() async {
    await _ws?.close();
  }
}
