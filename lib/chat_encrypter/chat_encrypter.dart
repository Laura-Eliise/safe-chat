import 'package:pointycastle/export.dart';

abstract class ChatEncrypter {
  String encrypt({
    required String text,
    required RSAPublicKey publicKey,
    required RSAPrivateKey privateKey,
  });
  String decrypt({
    required String message,
    required RSAPublicKey publicKey,
    required RSAPrivateKey privateKey,
  });
}
