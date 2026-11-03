import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/security/crypto_service.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../vault/data/vault_repository.dart';

class BackupService {
  BackupService({
    required this._storage,
    required this._crypto,
    required this._repository,
  });

  static const String appId = 'secure_vault';
  static const int formatVersion = 1;

  final SecureStorageService _storage;
  final CryptoService _crypto;
  final VaultRepository _repository;

  Future<File> createBackup() async {
    final salt = await _storage.read(AppConstants.keySalt);
    final verifier = await _storage.read(AppConstants.keyVerifier);
    if (salt == null || verifier == null) {
      throw StateError('Brankas belum dikonfigurasi');
    }

    final entries = await _repository.exportEntriesRaw();
    final payload = <String, dynamic>{
      'app': appId,
      'version': formatVersion,
      'created_at': DateTime.now().toIso8601String(),
      'salt': salt,
      'verifier': verifier,
      'entries': entries,
    };

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final file = File(
      p.join(directory.path, 'securevault_backup_$timestamp.svbackup'),
    );
    await file.writeAsString(jsonEncode(payload));
    return file;
  }

  Future<int> restoreBackup({
    required String filePath,
    required String backupPassword,
    required SecretKey currentKey,
  }) async {
    final content = await File(filePath).readAsString();
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Format backup tidak dikenali');
    }
    if (decoded['app'] != appId) {
      throw const FormatException('File ini bukan backup SecureVault');
    }

    final saltValue = decoded['salt'] as String?;
    final verifier = decoded['verifier'] as String?;
    final entries = decoded['entries'];
    if (saltValue == null || verifier == null || entries is! List) {
      throw const FormatException('Isi backup tidak lengkap');
    }

    final backupKey = await _crypto.deriveKey(
      backupPassword,
      base64Decode(saltValue),
    );
    final plaintext = await _crypto.decryptString(verifier, backupKey);
    if (plaintext != AppConstants.verifierPlaintext) {
      throw const FormatException('Master password backup salah');
    }

    await _repository.importEntriesRaw(
      entries.whereType<Map<String, dynamic>>().toList(),
      backupKey: backupKey,
      currentKey: currentKey,
    );
    return entries.length;
  }
}
