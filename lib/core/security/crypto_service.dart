import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../constants/app_constants.dart';

class CryptoService {
  Uint8List randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  Uint8List newSalt() => randomBytes(AppConstants.saltLength);

  Future<SecretKey> deriveKey(String password, Uint8List salt) {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: AppConstants.pbkdf2Iterations,
      bits: 256,
    );
    return pbkdf2.deriveKeyFromPassword(password: password, nonce: salt);
  }

  Future<String> encryptString(String plaintext, SecretKey key) async {
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();
    final box = await algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
    );
    return jsonEncode(<String, String>{
      'n': base64Encode(nonce),
      'c': base64Encode(box.cipherText),
      'm': base64Encode(box.mac.bytes),
    });
  }

  Future<String> decryptString(String payload, SecretKey key) async {
    final map = jsonDecode(payload) as Map<String, dynamic>;
    final algorithm = AesGcm.with256bits();
    final box = SecretBox(
      base64Decode(map['c'] as String),
      nonce: base64Decode(map['n'] as String),
      mac: Mac(base64Decode(map['m'] as String)),
    );
    final clear = await algorithm.decrypt(box, secretKey: key);
    return utf8.decode(clear);
  }

  Future<String> encryptMap(Map<String, dynamic> value, SecretKey key) =>
      encryptString(jsonEncode(value), key);

  Future<Map<String, dynamic>> decryptMap(String payload, SecretKey key) async {
    final decoded = jsonDecode(await decryptString(payload, key));
    return decoded as Map<String, dynamic>;
  }

  Future<String> encodeKey(SecretKey key) async {
    final bytes = await key.extractBytes();
    return base64Encode(bytes);
  }

  SecretKey keyFromString(String encoded) =>
      SecretKey(base64Decode(encoded));
}
