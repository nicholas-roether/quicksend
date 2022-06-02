import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quicksend/client/internal/login_manager.dart';
import 'package:quicksend/client/internal/request_manager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'utils.dart';

class EventManager extends EventSource {
  static const _reconnectDelay = Duration(seconds: 5);

  final LoginManager _loginManager;
  final RequestManager _requestManager;
  late final String _socketUri;
  WebSocketChannel? _ws;

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
    connectLoop();
  }

  Future<void> connectLoop() async {
    while (_loginManager.isLoggedIn()) {
      try {
        await connect();
      } catch (err) {
        debugPrint("WebSocket connection lost. Reconnecting in 5 seconds...");
      }
      await Future.delayed(_reconnectDelay);
    }
  }

  Future<void> connect() async {
    final auth = await _loginManager.getAuthenticator();
    final token = await _requestManager.getSocketToken(auth);
    _ws = WebSocketChannel.connect(Uri.parse(_socketUri));
    _ws!.sink.add(token);
    emit("connect");
    await _listen();
  }

  Future<void> _listen() async {
    await for (final msgStr in _ws!.stream) {
      final msg = jsonDecode(msgStr);
      emit(msg["event"], data: msg["data"]);
    }
  }

  Future<void> onLoggedOut() async {
    await _ws?.sink.close();
  }
}
