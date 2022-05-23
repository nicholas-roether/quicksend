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

  static Future<String> generateKey() async {
    final key = enc.Key.fromSecureRandom(2048);
    return key.base64;
  }

  static Future<Uint8List> encrypt(Uint8List data, String key) async {
    final parsedKey = enc.Key.fromBase64(key);
    final aes = enc.AES(parsedKey);
    return aes.encrypt(data).bytes;
  }

  static Future<Uint8List> decrypt(Uint8List data, String key) async {
    final parsedKey = enc.Key.fromBase64(key);
    final aes = enc.AES(parsedKey);
    return aes.decrypt(enc.Encrypted(data));
  }

  static Future<String> encryptKey(
    String key,
    String publicKey,
  ) async {
    return await frsa.RSA.encryptPKCS1v15(key, publicKey);
  }

  static Future<String> decryptKey(
    String encryptedKey,
    String privateKey,
  ) async {
    return await frsa.RSA.decryptPKCS1v15(encryptedKey, privateKey);
  }
}
