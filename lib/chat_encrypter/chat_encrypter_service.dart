import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/user_api.dart';
import 'chat_encrypter.dart';
import 'generate_rsa_key_pair.dart';
import 'generate_secure_random.dart';

class ChatEncrypterService extends ChatEncrypter {
  @override
  String encrypt({
    required String text,
    required RSAPublicKey publicKey,
    required RSAPrivateKey privateKey,
  }) {
    final senderEncryptedRSA =
        enc.Encrypter(enc.RSA(publicKey: publicKey, privateKey: privateKey));
    final encryptedMessage =
        senderEncryptedRSA.encryptBytes(text.codeUnits).base64;

    return encryptedMessage;
  }

  @override
  String decrypt({
    required String message,
    required RSAPublicKey publicKey,
    required RSAPrivateKey privateKey,
  }) {
    final recipientEncrypter = enc.Encrypter(
      enc.RSA(publicKey: publicKey, privateKey: privateKey),
    );
    final decryptedMessage =
        recipientEncrypter.decrypt(enc.Encrypted.fromBase64(message));

    return decryptedMessage;
  }

  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAKeys() {
    return generateRSAkeyPair(generateSecureRandom());
  }

  /// Gets the user private key from internal storage.
  /// If there is no private key in storage, the public and private key do not
  /// decrypt a test message or te public key is null, a new RSA key pair
  /// is generated and set for the user.
  /// The new public key is written into cloud storage and the new private
  /// key is saved locally.
  Future<RSAPrivateKey> getOrSetKey(String email,
      [String? publicKeyString]) async {
    var pref = await SharedPreferences.getInstance();
    String? privateKeyString = pref.getString("key");
    var newKeys = generateRSAKeys();

    if (privateKeyString != null && publicKeyString != null) {
      String test = "test";
      RSAPublicKey? publicKey =
          stringToRSAKey(publicKeyString, isPrivate: false);
      RSAPrivateKey? privateKey =
          stringToRSAKey(privateKeyString, isPrivate: true);

      if (publicKey == null || privateKey == null) {
        return await _assignNewKeys(newKeys, pref, email);
      }

      try {
        String encryptedMessage = encrypt(
          text: test,
          publicKey: publicKey,
          privateKey: newKeys.privateKey,
        );
        String decryptedMessage = decrypt(
          message: encryptedMessage,
          publicKey: newKeys.publicKey,
          privateKey: privateKey,
        );
        if (decryptedMessage == test) return privateKey;
      } catch (e) {
        return await _assignNewKeys(newKeys, pref, email);
      }
    }
    return await _assignNewKeys(newKeys, pref, email);
  }

  Future<RSAPrivateKey> _assignNewKeys(
    AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keys,
    SharedPreferences pref,
    String email,
  ) async {
    pref.setString("key", rsaKeyToString(keys.privateKey));
    await UserApi()
        .updateKey(email: email, key: rsaKeyToString(keys.publicKey));
    return keys.privateKey;
  }

  /* Key Parsing */

  dynamic stringToRSAKey(String key, {required bool isPrivate}) {
    List<String> parts = key.split(':');

    if (parts.length == 1) return null;

    String modulus = parts[0];
    String exponent = parts[1];
    BigInt modulusBigInt = BigInt.parse(modulus, radix: 16);
    BigInt exponentBigInt = BigInt.parse(exponent, radix: 16);

    if (isPrivate) {
      String p = parts[2];
      String q = parts[3];
      BigInt pBigInt = BigInt.parse(p, radix: 16);
      BigInt qBigInt = BigInt.parse(q, radix: 16);

      return RSAPrivateKey(modulusBigInt, exponentBigInt, pBigInt, qBigInt);
    }
    return RSAPublicKey(modulusBigInt, exponentBigInt);
  }

  String rsaKeyToString(dynamic key) {
    if (key is! RSAPrivateKey && key is! RSAPublicKey) {
      throw Exception("Not a RSAKey: $key");
    }
    String modulus = key.modulus!.toRadixString(16);
    String exponent = key.exponent!.toRadixString(16);

    if (key is RSAPrivateKey) {
      String p = key.p!.toRadixString(16);
      String q = key.q!.toRadixString(16);
      return '$modulus:$exponent:$p:$q';
    }
    return '$modulus:$exponent';
  }
}
