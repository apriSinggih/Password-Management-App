import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/security/crypto_service.dart';
import '../domain/credential.dart';

class VaultRepository {
  VaultRepository({required this._crypto});

  final CryptoService _crypto;
  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), AppConstants.dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE credentials (
            id TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE meta (
            key TEXT PRIMARY KEY,
            payload TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> open() async {
    await _database;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<List<Credential>> loadAll(SecretKey key) async {
    final db = await _database;
    final rows = await db.query('credentials');
    final credentials = <Credential>[];
    for (final row in rows) {
      final payload = row['payload'] as String?;
      if (payload == null) continue;
      try {
        final map = await _crypto.decryptMap(payload, key);
        credentials.add(Credential.fromJson(map));
      } catch (_) {
        continue;
      }
    }
    credentials.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return credentials;
  }

  Future<void> save(Credential credential, SecretKey key) async {
    final db = await _database;
    final payload = await _crypto.encryptMap(credential.toJson(), key);
    await db.insert(
      'credentials',
      <String, Object?>{
        'id': credential.id,
        'payload': payload,
        'updated_at': credential.updatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    final db = await _database;
    await db.delete('credentials', where: 'id = ?', whereArgs: <Object>[id]);
  }

  Future<bool> metaExists(String key) async {
    final db = await _database;
    final rows = await db.query(
      'meta',
      columns: <String>['key'],
      where: 'key = ?',
      whereArgs: <Object>[key],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<Map<String, dynamic>?> readMeta(
    String key,
    SecretKey vaultKey,
  ) async {
    final db = await _database;
    final rows = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: <Object>[key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    try {
      return await _crypto.decryptMap(rows.first['payload'] as String, vaultKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeMeta(
    String key,
    Map<String, dynamic> value,
    SecretKey vaultKey,
  ) async {
    final db = await _database;
    final payload = await _crypto.encryptMap(value, vaultKey);
    await db.insert(
      'meta',
      <String, Object?>{'key': key, 'payload': payload},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMeta(String key) async {
    final db = await _database;
    await db.delete('meta', where: 'key = ?', whereArgs: <Object>[key]);
  }

  Future<List<Map<String, String>>> exportEntriesRaw() async {
    final db = await _database;
    final rows = await db.query('credentials');
    return rows
        .map(
          (row) => <String, String>{
            'id': row['id'] as String,
            'payload': row['payload'] as String,
          },
        )
        .toList();
  }

  Future<void> importEntriesRaw(
    List<Map<String, dynamic>> entries, {
    required SecretKey backupKey,
    required SecretKey currentKey,
  }) async {
    final db = await _database;
    for (final entry in entries) {
      final id = entry['id'] as String?;
      final payload = entry['payload'] as String?;
      if (id == null || payload == null) continue;
      final json = await _crypto.decryptMap(payload, backupKey);
      final credential = Credential.fromJson(json);
      final updatedAt = credential.updatedAt.millisecondsSinceEpoch;
      final reencrypted = await _crypto.encryptMap(json, currentKey);
      await db.insert(
        'credentials',
        <String, Object?>{
          'id': id,
          'payload': reencrypted,
          'updated_at': updatedAt,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> reencryptAll({
    required SecretKey oldKey,
    required SecretKey newKey,
  }) async {
    final db = await _database;
    final credentialRows = await db.query('credentials');
    final plaintextCredentials = <String, String>{};
    for (final row in credentialRows) {
      final id = row['id'] as String;
      final payload = row['payload'] as String;
      plaintextCredentials[id] = await _crypto.decryptString(payload, oldKey);
    }

    final metaRows = await db.query('meta');
    final plaintextMeta = <String, String>{};
    for (final row in metaRows) {
      final key = row['key'] as String;
      final payload = row['payload'] as String;
      plaintextMeta[key] = await _crypto.decryptString(payload, oldKey);
    }

    await db.transaction((txn) async {
      for (final entry in plaintextCredentials.entries) {
        final encrypted = await _crypto.encryptString(entry.value, newKey);
        await txn.update(
          'credentials',
          <String, Object?>{'payload': encrypted},
          where: 'id = ?',
          whereArgs: <Object>[entry.key],
        );
      }
      for (final entry in plaintextMeta.entries) {
        final encrypted = await _crypto.encryptString(entry.value, newKey);
        await txn.update(
          'meta',
          <String, Object?>{'payload': encrypted},
          where: 'key = ?',
          whereArgs: <Object>[entry.key],
        );
      }
    });
  }
}
