import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ignore: implementation_imports
import 'package:hive/src/adapters/date_time_adapter.dart';
import 'package:quicksend/client/internal/crypto_utils.dart';
import 'db_models/db_message.dart';
import 'initialized.dart';

class ClientDB extends Initialized<ClientDB> {
  final _secureStorage = const FlutterSecureStorage();

  Box get _general {
    return Hive.box("general");
  }

  Box get _chatList {
    return Hive.box("chat-list");
  }

  @override
  Future<void> onInit() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DateTimeAdapter(), internal: true);
    Hive.registerAdapter(DBMessageAdapter());
    await Hive.openBox("general");
    final _chatList = await Hive.openBox("chat-list");
    await Future.wait(List.from(_chatList.values)
        .map((chatId) => Hive.openBox(_getChatBoxName(chatId))));
  }

  Future<void> onLoggedOut() async {
    await Future.wait(
      List.from(_chatList.values).map((chatId) async {
        await Hive.deleteBoxFromDisk(_getChatBoxName(chatId));
        await _secureStorage.delete(key: "$chatId-key");
      }),
    );
    await _general.clear();
    await _chatList.clear();
  }

  String? getDeviceID() {
    assertInit();
    return _general.get("device-id");
  }

  void setDeviceID(String? id) {
    assertInit();
    _general.put("device-id", id);
  }

  List<String> getChatList() {
    assertInit();
    return List.from(_chatList.values);
  }

  Future<void> createChat(String id) async {
    assertInit();
    _chatList.add(id);
    await _openChatBox(id);
  }

  Future<void> deleteChat(String id) async {
    assertInit();
    _chatList.deleteAt(_chatList.values.singleWhere((val) => val == id));
    await Hive.deleteBoxFromDisk(_getChatBoxName(id));
  }

  List<DBMessage> getMessages(String chatId) {
    assertInit();
    final box = _getChatBox(chatId);
    return List.from(box.values);
  }

  void addMessage(String chatId, DBMessage message) {
    assertInit();
    final box = _getChatBox(chatId);
    box.add(message);
  }

  Future<String?> getSignatureKey() async {
    assertInit();
    return await _secureStorage.read(key: "signature-key");
  }

  Future<void> setSignatureKey(String key) async {
    assertInit();
    await _secureStorage.write(key: "signature-key", value: key);
  }

  Future<String?> getEncryptionKey() async {
    assertInit();
    return await _secureStorage.read(key: "encryption-key");
  }

  Future<void> setEncryptionKey(String key) async {
    assertInit();
    await _secureStorage.write(key: "encryption-key", value: key);
  }

  Future<Uint8List?> _getChatBoxKey(String name) async {
    final key = await _secureStorage.read(key: "$name-key");
    if (key == null) return null;
    return base64.decode(key);
  }

  Future<void> _setChatBoxKey(String name, Uint8List key) async {
    await _secureStorage.write(key: "$name-key", value: base64.encode(key));
  }

  Future<void> _openChatBox(String id) async {
    final boxName = _getChatBoxName(id);
    final savedKey = await _getChatBoxKey(boxName);
    Uint8List key;
    if (savedKey != null) {
      key = savedKey;
    } else {
      key = await CryptoUtils.generateKey();
      _setChatBoxKey(boxName, key);
    }
    await Hive.openBox(boxName, encryptionCipher: HiveAesCipher(key));
  }

  String _getChatBoxName(String id) {
    return "chat-$id";
  }

  Box _getChatBox(String id) {
    return Hive.box(_getChatBoxName(id));
  }
}
