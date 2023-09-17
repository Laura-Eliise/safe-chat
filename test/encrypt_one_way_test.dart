import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart';
import 'package:secure_messenger/chat_encrypter/chat_encrypter_service.dart';
import 'package:secure_messenger/chat_encrypter/generate_rsa_key_pair.dart';
import 'package:secure_messenger/chat_encrypter/generate_secure_random.dart';

void main() {
  late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> senderKeyPair;
  late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> recipientKeyPair;

  setUp(() {
    senderKeyPair = generateRSAkeyPair(generateSecureRandom());
    recipientKeyPair = generateRSAkeyPair(generateSecureRandom());
  });

  test("recipient can decrypt a message sent to them", () {
    const text = "My secret message.";

    String encryptedMessage = ChatEncrypterService().encrypt(
      text: text,
      publicKey: recipientKeyPair.publicKey,
      privateKey: senderKeyPair.privateKey,
    );

    // sending message to recipient...

    String decryptedMessage = ChatEncrypterService().decrypt(
      message: encryptedMessage,
      publicKey: senderKeyPair.publicKey,
      privateKey: recipientKeyPair.privateKey,
    );

    expect(decryptedMessage, text);
  });

  test("sender can't decrypt messages they sent", () {
    const text = "My secret message.";

    String encryptedMessage = ChatEncrypterService().encrypt(
      text: text,
      publicKey: recipientKeyPair.publicKey,
      privateKey: senderKeyPair.privateKey,
    );

    // getting senders message...

    String decryptedMessage;
    try {
      decryptedMessage = ChatEncrypterService().decrypt(
        message: encryptedMessage,
        publicKey: recipientKeyPair.publicKey,
        privateKey: senderKeyPair.privateKey,
      );
    } catch (e) {
      expect(true, true);
      return;
    }

    expect(decryptedMessage == text, false);
  });
}
