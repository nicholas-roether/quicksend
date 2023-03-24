import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:quicksend/client/internal/login_manager.dart';
import 'package:quicksend/client/internal/request_manager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../config.dart';
import 'utils.dart';

class EventManager extends EventSource {
  static const _reconnectDelay = Duration(seconds: 5);

  final LoginManager _loginManager;
  final RequestManager _requestManager;
  WebSocketChannel? _ws;

  EventManager({
    required LoginManager loginManager,
    required RequestManager requestManager,
  })  : _loginManager = loginManager,
        _requestManager = requestManager;

  Future<void> onLoggedIn() async {
    connectLoop();
  }

  Future<void> connectLoop() async {
    await connect();
    while (_loginManager.isLoggedIn()) {
      if (Config.logWebSocketConnectionLoss) {
        debugPrint("WebSocket connection lost. Reconnecting in 5 seconds...");
      }
      await Future.delayed(_reconnectDelay);
      try {
        await connect();
      } catch (err) {
        debugPrint("WebSocket error: $err");
      }
    }
  }

  Future<void> connect() async {
    final auth = await _loginManager.getAuthenticator();
    final token = await _requestManager.getSocketToken(auth);
    _ws = WebSocketChannel.connect(Uri.parse(Config.socketUri));
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
