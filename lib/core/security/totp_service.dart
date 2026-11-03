import 'dart:math';

import 'package:crypto/crypto.dart';

class TotpService {
  static const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  static const int period = 30;
  static const int digits = 6;

  static String generateSecret({int bytes = 20}) {
    final random = Random.secure();
    final data = List<int>.generate(bytes, (_) => random.nextInt(256));
    return encodeBase32(data);
  }

  static String encodeBase32(List<int> data) {
    final buffer = StringBuffer();
    var bits = 0;
    var value = 0;
    for (final byte in data) {
      value = (value << 8) | byte;
      bits += 8;
      while (bits >= 5) {
        buffer.write(_alphabet[(value >> (bits - 5)) & 0x1f]);
        bits -= 5;
      }
    }
    if (bits > 0) {
      buffer.write(_alphabet[(value << (5 - bits)) & 0x1f]);
    }
    return buffer.toString();
  }

  static List<int> decodeBase32(String input) {
    final clean = input.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
    final result = <int>[];
    var bits = 0;
    var value = 0;
    for (final char in clean.split('')) {
      final index = _alphabet.indexOf(char);
      if (index < 0) continue;
      value = (value << 5) | index;
      bits += 5;
      if (bits >= 8) {
        result.add((value >> (bits - 8)) & 0xff);
        bits -= 8;
      }
    }
    return result;
  }

  static String codeFor(String secret, {DateTime? at}) {
    final key = decodeBase32(secret);
    final seconds =
        (at ?? DateTime.now()).toUtc().millisecondsSinceEpoch ~/ 1000;
    final counter = seconds ~/ period;
    final counterBytes = List<int>.generate(8, (index) {
      return (counter >> (56 - index * 8)) & 0xff;
    });
    final digest = Hmac(sha1, key).convert(counterBytes).bytes;
    final offset = digest[digest.length - 1] & 0x0f;
    final binary =
        ((digest[offset] & 0x7f) << 24) |
        ((digest[offset + 1] & 0xff) << 16) |
        ((digest[offset + 2] & 0xff) << 8) |
        (digest[offset + 3] & 0xff);
    final code = binary % pow(10, digits);
    return code.toString().padLeft(digits, '0');
  }

  static bool verify(String secret, String code, {int window = 1}) {
    final normalized = code.replaceAll(RegExp(r'\s'), '');
    if (normalized.length != digits) return false;
    final now = DateTime.now();
    for (var offset = -window; offset <= window; offset++) {
      final candidate = codeFor(
        secret,
        at: now.add(Duration(seconds: offset * period)),
      );
      if (candidate == normalized) return true;
    }
    return false;
  }

  static int secondsRemaining({DateTime? at}) {
    final seconds = (at ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
    return period - (seconds % period);
  }

  static String otpauthUri({
    required String secret,
    required String account,
    String issuer = 'SecureVault',
  }) {
    final label = Uri.encodeComponent('$issuer:$account');
    return 'otpauth://totp/$label?secret=$secret&issuer='
        '${Uri.encodeComponent(issuer)}&digits=$digits&period=$period';
  }
}
