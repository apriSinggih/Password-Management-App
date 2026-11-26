import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/features/vault/services/credential_json_importer.dart';

void main() {
  final importer = CredentialJsonImporter();

  group('CredentialJsonImporter', () {
    test('membaca array kredensial lengkap', () {
      final result = importer.parse('''
[
  {
    "name": "Gmail",
    "username": "user@gmail.com",
    "password": "rahasia",
    "url": "https://mail.google.com",
    "category": "email",
    "tags": ["pribadi", "kerja"],
    "notes": "akun utama"
  }
]
''');

      expect(result.credentials, hasLength(1));
      final credential = result.credentials.single;
      expect(credential.name, 'Gmail');
      expect(credential.username, 'user@gmail.com');
      expect(credential.password, 'rahasia');
      expect(credential.url, 'https://mail.google.com');
      expect(credential.category, 'Email');
      expect(credential.tags, <String>['pribadi', 'kerja']);
      expect(credential.notes, 'akun utama');
      expect(result.skipped, 0);
    });

    test('membaca wrapper dan alias field', () {
      final result = importer.parse('''
{
  "credentials": [
    {
      "title": "Instagram",
      "user": "user_ig",
      "pass": "rahasia",
      "website": "https://instagram.com",
      "folder": "Media Sosial",
      "tag": "sosial, pribadi, sosial"
    }
  ]
}
''');

      expect(result.credentials, hasLength(1));
      final credential = result.credentials.single;
      expect(credential.name, 'Instagram');
      expect(credential.username, 'user_ig');
      expect(credential.category, 'Media Sosial');
      expect(credential.tags, <String>['sosial', 'pribadi']);
    });

    test('membaca objek tunggal di root', () {
      final result = importer.parse('{"title":"GitHub","password":"rahasia"}');

      expect(result.credentials, hasLength(1));
      expect(result.credentials.single.name, 'GitHub');
    });

    test('kategori tak dikenal menjadi Lainnya', () {
      final result = importer.parse(
        '[{"name":"X","username":"u","category":"Streaming"}]',
      );

      expect(result.credentials.single.category, 'Lainnya');
    });

    test('melewati entri invalid dan duplikat', () {
      final result = importer.parse(
        '''
[
  {"name": "A", "username": "a"},
  {"name": "A", "username": "a"},
  {"name": "B", "username": "b"},
  "bukan objek",
  {}
]
''',
        existingKeys: <String>{'b|b'},
      );

      expect(result.credentials, hasLength(1));
      expect(result.credentials.single.name, 'A');
      expect(result.skipped, 4);
      expect(result.warnings, isNotEmpty);
    });

    test('menggunakan username sebagai nama jika name kosong', () {
      final result = importer.parse(
        '[{"username":"user@example.com","password":"x"}]',
      );

      expect(result.credentials.single.name, 'user@example.com');
    });

    test('menolak JSON rusak dan format tidak dikenali', () {
      expect(() => importer.parse('{bukan json'), throwsFormatException);
      expect(() => importer.parse('{"foo":"bar"}'), throwsFormatException);
      expect(() => importer.parse(''), throwsFormatException);
    });
  });
}
