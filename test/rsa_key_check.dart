import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart';
import 'package:secure_messenger/chat_encrypter/chat_encrypter_service.dart';

void main() {
  late ChatEncrypterService encrypter;
  late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keys;

  setUp(() {
    encrypter = ChatEncrypterService();
    keys = encrypter.generateRSAKeys();
  });

  test("create a valid string from a public RSA key", () {
    dynamic publicKey;
    expect(() {
      publicKey = encrypter.rsaKeyToString(keys.publicKey);
    }, isNot(throwsA(anything)));
    expect(publicKey is String, true);
    expect(publicKey.split(":").length, 2);
  });

  test("create a valid string from a private RSA key", () {
    dynamic privateKey;
    expect(() {
      privateKey = encrypter.rsaKeyToString(keys.privateKey);
    }, isNot(throwsA(anything)));
    expect(privateKey is String, true);
    expect(privateKey.split(":").length, 4);
  });

  test("RSA public key string can be parsed back to a RSA public key", () {
    dynamic publicKey;
    expect(() {
      publicKey = encrypter.rsaKeyToString(keys.publicKey);
      publicKey = encrypter.stringToRSAKey(publicKey, isPrivate: false);
    }, isNot(throwsA(anything)));
    expect(publicKey is RSAPublicKey, true);
  });

  test("RSA private key string can be parsed back to a RSA private key", () {
    dynamic privateKey;
    expect(() {
      privateKey = encrypter.rsaKeyToString(keys.privateKey);
      privateKey = encrypter.stringToRSAKey(privateKey, isPrivate: true);
    }, isNot(throwsA(anything)));
    expect(privateKey is RSAPrivateKey, true);
  });

  test(
      "It is possible to encrypt and decrypt messages after the keys were turned into strings",
      () {
    RSAPublicKey publicKey;
    RSAPrivateKey privateKey;
    String decryptedMessage;
    var message = "Testing Keys";
    var newKeys = encrypter.generateRSAKeys();

    var privateKeyString = encrypter.rsaKeyToString(keys.privateKey);
    var publicKeyString = encrypter.rsaKeyToString(keys.publicKey);

    privateKey = encrypter.stringToRSAKey(privateKeyString, isPrivate: true);
    publicKey = encrypter.stringToRSAKey(publicKeyString, isPrivate: false);

    var encryptedMessage = encrypter.encrypt(
      text: message,
      publicKey: publicKey,
      privateKey: newKeys.privateKey,
    );
    decryptedMessage = encrypter.decrypt(
      message: encryptedMessage,
      publicKey: newKeys.publicKey,
      privateKey: privateKey,
    );

    expect(decryptedMessage, message);
  });
}
