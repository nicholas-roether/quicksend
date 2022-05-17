import 'package:fast_rsa/fast_rsa.dart';

class Keypair {
  final String public;
  final String private;

  const Keypair(this.public, this.private);
}

class CryptoUtils {
  static Future<Keypair> generateKeypair() async {
    var keys = await RSA.generate(2048);
    return Keypair(keys.publicKey, keys.privateKey);
  }

  static Future<String> sign(String str, String key) async {
    return await RSA.signPKCS1v15(str, Hash.SHA256, key);
  }
}
