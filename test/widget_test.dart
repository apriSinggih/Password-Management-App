import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/core/security/crypto_service.dart';
import 'package:secure_vault/core/security/totp_service.dart';
import 'package:secure_vault/core/utils/password_generator.dart';
import 'package:secure_vault/features/vault/domain/credential.dart';

void main() {
  group('PasswordGenerator', () {
    test('menghasilkan password sesuai panjang dan jenis karakter', () {
      final password = PasswordGenerator.generate(length: 24);
      expect(password.length, 24);
      expect(password.contains(RegExp(r'[A-Z]')), isTrue);
      expect(password.contains(RegExp(r'[a-z]')), isTrue);
      expect(password.contains(RegExp(r'[0-9]')), isTrue);
    });

    test('menolak jika semua jenis karakter dimatikan', () {
      expect(
        () => PasswordGenerator.generate(
          useUppercase: false,
          useLowercase: false,
          useDigits: false,
          useSymbols: false,
        ),
        throwsArgumentError,
      );
    });

    test('menilai password lemah dan kuat', () {
      expect(PasswordGenerator.analyze('123456').score, 0);
      expect(
        PasswordGenerator.analyze('Tr0ub4dor&3-Correct-Horse').score,
        greaterThanOrEqualTo(3),
      );
    });
  });

  group('TotpService', () {
    test('menghasilkan kode yang sesuai test vector RFC 6238', () {
      final secret = TotpService.encodeBase32(
        '12345678901234567890'.codeUnits,
      );
      final code = TotpService.codeFor(
        secret,
        at: DateTime.fromMillisecondsSinceEpoch(59000, isUtc: true),
      );
      expect(code, '287082');
    });

    test('memverifikasi kode yang baru dibuat', () {
      final secret = TotpService.generateSecret();
      final code = TotpService.codeFor(secret);
      expect(TotpService.verify(secret, code), isTrue);
      expect(TotpService.verify(secret, '000000'), isFalse);
    });
  });

  group('CryptoService', () {
    test('enkripsi dan dekripsi AES-256-GCM berjalan bolak-balik', () async {
      final crypto = CryptoService();
      final key = SecretKey(List<int>.generate(32, (index) => index));
      final encrypted = await crypto.encryptMap(
        <String, dynamic>{'secret': 'rahasia'},
        key,
      );
      final decrypted = await crypto.decryptMap(encrypted, key);
      expect(decrypted['secret'], 'rahasia');
    });
  });

  group('Credential', () {
    test('serialisasi JSON bolak-balik mempertahankan data', () {
      final now = DateTime.now();
      final credential = Credential(
        id: 'abc',
        name: 'Contoh',
        username: 'user@example.com',
        password: 'p@ssw0rd',
        category: 'Email',
        tags: <String>['kerja'],
        notes: 'catatan',
        createdAt: now,
        updatedAt: now,
        history: <PasswordHistoryEntry>[
          PasswordHistoryEntry(password: 'lama', changedAt: now),
        ],
      );

      final restored = Credential.fromJson(credential.toJson());
      expect(restored.name, credential.name);
      expect(restored.tags, credential.tags);
      expect(restored.history.length, 1);
    });
  });
}
