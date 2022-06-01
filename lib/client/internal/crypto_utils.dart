import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:fast_rsa/fast_rsa.dart' as frsa;

class Keypair {
  final String public;
  final String private;

  const Keypair(this.public, this.private);
}

class CryptoUtils {
  static Future<Keypair> generateKeypair() async {
    var keys = await frsa.RSA.generate(2048);
    return Keypair(keys.publicKey, keys.privateKey);
  }

  static Future<String> sign(String str, String key) async {
    return await frsa.RSA.signPKCS1v15(str, frsa.Hash.SHA256, key);
  }

  static Future<Uint8List> generateKey() async {
    return _secureRandom(32);
  }

  static Future<Uint8List> generateIV() async {
    return _secureRandom(16);
  }

  static Future<Uint8List> encrypt(
    Uint8List data,
    Uint8List key,
    Uint8List iv,
  ) async {
    final aes = enc.AES(enc.Key(key), mode: enc.AESMode.cbc);
    return aes.encrypt(data, iv: enc.IV(iv)).bytes;
  }

  static Future<Uint8List> decrypt(
    Uint8List data,
    Uint8List key,
    Uint8List iv,
  ) async {
    final aes = enc.AES(enc.Key(key), mode: enc.AESMode.cbc);
    return aes.decrypt(enc.Encrypted(data), iv: enc.IV(iv));
  }

  static Future<Uint8List> encryptKey(
    Uint8List key,
    String publicKey,
  ) async {
    return await frsa.RSA.encryptPKCS1v15Bytes(key, publicKey);
  }

  static Future<Uint8List> decryptKey(
    Uint8List encryptedKey,
    String privateKey,
  ) async {
    return await frsa.RSA.decryptPKCS1v15Bytes(encryptedKey, privateKey);
  }

  static Uint8List _secureRandom(int length) {
    final rand = Random.secure();
    final bytes = Uint8List.fromList(
      List.generate(length, (_) => rand.nextInt(0xFF)),
    );
    return bytes;
  }
}
