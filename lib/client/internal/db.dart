import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ignore: implementation_imports
import 'package:hive/src/adapters/date_time_adapter.dart';
import 'db_models/db_message.dart';
import 'initialized.dart';

class ClientDB extends Initialized<ClientDB> {
  final _secureStorage = const FlutterSecureStorage();
  late final Box _general;
  late final Box _chatList;

  @override
  Future<void> onInit() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DateTimeAdapter(), internal: true);
    Hive.registerAdapter(DBMessageAdapter());
    _general = await Hive.openBox("general");
    _chatList = await Hive.openBox("chat-list");
    await Future.wait(
      List.from(_chatList.values)
          .map((chatId) => Hive.openBox(_getChatBoxName(chatId))),
    );
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
    await Hive.openBox(_getChatBoxName(id));
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

  Future<String?> getEncryptionPublicKey() async {
    assertInit();
    return await _secureStorage.read(key: "encryption-public-key");
  }

  Future<void> setEncryptionPublicKey(String? key) async {
    assertInit();
    await _secureStorage.write(key: "encryption-public-key", value: key);
  }

  String _getChatBoxName(String id) {
    return "chat-$id";
  }

  Box _getChatBox(String id) {
    return Hive.box(_getChatBoxName(id));
  }
}
