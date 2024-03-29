import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ignore: implementation_imports
import 'package:hive/src/adapters/date_time_adapter.dart';
// ignore: implementation_imports
import 'package:hive/src/adapters/ignored_type_adapter.dart';
import 'package:quicksend/client/internal/crypto_utils.dart';
import 'package:quicksend/client/internal/db_models/db_chat.dart';
import 'db_models/db_message.dart';
import 'initialized.dart';

abstract class VersionTransition {
  Future<void> apply(Box general);
}

class V0Transition extends VersionTransition {
  @override
  Future<void> apply(Box general) {
    return Future.value();
  }
}

class V1Transition extends VersionTransition {
  @override
  Future<void> apply(Box general) async {
    final chatList = await Hive.openBox<dynamic>("chat-list");
    final chatListValues = List.from(chatList.values);
    await chatList.clear();
    Hive.registerAdapter(DBChatAdapter(), override: true);
    for (final id in chatListValues) {
      chatList.put(id, DBChat(id, false));
    }
    general.put("version", 1);
    await chatList.close();
  }
}

class V2Transition extends VersionTransition {
  @override
  Future<void> apply(Box general) async {
    Hive.registerAdapter(const IgnoredTypeAdapter(2), override: true);
    final chatList = await Hive.openBox<dynamic>("chat-list");
    final chatListKeys = List.from(chatList.keys);
    await chatList.clear();
    Hive.registerAdapter(DBChatAdapter(), override: true);
    for (final id in chatListKeys) {
      chatList.put(id, DBChat(id, false));
    }
    await general.put("version", 2);
    await chatList.close();
  }
}

final List<VersionTransition> versionTransitions = [
  V0Transition(),
  V1Transition(),
  V2Transition()
];

class ClientDB with Initialized<ClientDB> {
  final _secureStorage = const FlutterSecureStorage();

  Box get _general {
    return Hive.box("general");
  }

  Box<DBChat> get _chatList {
    return Hive.box<DBChat>("chat-list");
  }

  @override
  Future<void> onInit() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DateTimeAdapter(), internal: true);
    await Hive.openBox("general");
    await _applyVersionTransitions();

    Hive.registerAdapter(DBMessageAdapter(), override: true);
    Hive.registerAdapter(DBChatAdapter(), override: true);

    final _chatList = await Hive.openBox<DBChat>("chat-list");
    await Future.wait(
      List<DBChat>.from(_chatList.values).map(
        (dbChat) => _openChatBox(dbChat.id),
      ),
    );
  }

  Future<void> reset() async {
    await Future.wait(
      List.from(_chatList.keys).map((chatId) async {
        await _deleteChat(chatId);
      }),
    );
    await _chatList.clear();
  }

  String? getDeviceID() {
    assertInit();
    return _general.get("device-id");
  }

  Future<void> setDeviceID(String? id) async {
    assertInit();
    await _general.put("device-id", id);
  }

  String? getUserID() {
    assertInit();
    return _general.get("user-id");
  }

  Future<void> setUserID(String? val) async {
    assertInit();
    await _general.put("user-id", val);
  }

  List<DBChat> getChatList() {
    assertInit();
    return List.from(_chatList.values);
  }

  Future<DBChat> createChat(String id) async {
    assertInit();
    if (_chatList.containsKey(id)) return _chatList.get(id)!;
    final dbChat = DBChat(id, false);
    _chatList.put(id, dbChat);
    await _openChatBox(id);
    return dbChat;
  }

  Future<void> deleteChat(String id) async {
    assertInit();
    await _deleteChat(id);
    await _chatList.delete(id);
  }

  List<DBMessage> getMessages(String chatId) {
    assertInit();
    final box = _getChatBox(chatId);
    return List.from(box.values);
  }

  DBMessage? getLatestMessage(String chatId) {
    assertInit();
    final box = _getChatBox(chatId);
    return box.get(box.length - 1);
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

  Future<void> setSignatureKey(String? key) async {
    assertInit();
    await _secureStorage.write(key: "signature-key", value: key);
  }

  Future<String?> getEncryptionKey() async {
    assertInit();
    return await _secureStorage.read(key: "encryption-key");
  }

  Future<void> setEncryptionKey(String? key) async {
    assertInit();
    await _secureStorage.write(key: "encryption-key", value: key);
  }

  Future<void> _deleteChat(String chatId) async {
    await _getChatBox(chatId).clear();
    await _secureStorage.delete(key: "$chatId-key");
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
      await _setChatBoxKey(boxName, key);
    }
    await Hive.openBox(boxName, encryptionCipher: HiveAesCipher(key));
  }

  String _getChatBoxName(String id) {
    return "chat-$id";
  }

  Box _getChatBox(String id) {
    return Hive.box(_getChatBoxName(id));
  }

  Future<void> _applyVersionTransitions() async {
    final int version = _general.get("version", defaultValue: 0);
    if (versionTransitions.length - 1 == version) return;
    for (final transition in versionTransitions.sublist(version + 1)) {
      await transition.apply(_general);
    }
  }
}
