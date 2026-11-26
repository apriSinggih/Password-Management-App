import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../core/constants/categories.dart';
import '../domain/credential.dart';

class JsonImportResult {
  const JsonImportResult({
    required this.credentials,
    required this.skipped,
    this.warnings = const <String>[],
  });

  final List<Credential> credentials;
  final int skipped;
  final List<String> warnings;
}

class CredentialJsonImporter {
  static const int maxWarnings = 5;

  static const List<String> _wrapperKeys = <String>[
    'credentials',
    'items',
    'entries',
    'data',
  ];

  static const List<String> _nameKeys = <String>[
    'name',
    'title',
    'service',
    'app',
  ];

  static const List<String> _usernameKeys = <String>[
    'username',
    'user',
    'login',
    'email',
    'account',
  ];

  static const List<String> _passwordKeys = <String>[
    'password',
    'pass',
    'secret',
  ];

  static const List<String> _urlKeys = <String>[
    'url',
    'website',
    'site',
    'uri',
  ];

  static const List<String> _categoryKeys = <String>[
    'category',
    'folder',
    'group',
  ];

  static const List<String> _notesKeys = <String>[
    'notes',
    'note',
    'description',
  ];

  JsonImportResult parse(
    String content, {
    Set<String> existingKeys = const <String>{},
  }) {
    final items = _extractItems(_decode(content));
    if (items == null) {
      throw const FormatException(
        'Format JSON tidak dikenali. Gunakan array kredensial atau objek '
        'dengan key credentials/items/entries/data.',
      );
    }

    final credentials = <Credential>[];
    final warnings = <String>[];
    final seenKeys = <String>{...existingKeys};
    var skipped = 0;

    void skip(String message) {
      skipped++;
      if (warnings.length < maxWarnings) {
        warnings.add(message);
      }
    }

    for (var index = 0; index < items.length; index++) {
      final position = index + 1;
      final item = items[index];
      if (item is! Map) {
        skip('Entri $position bukan objek JSON');
        continue;
      }

      final map = Map<String, dynamic>.from(item);
      final username = _pickText(map, _usernameKeys) ?? '';
      final url = _pickText(map, _urlKeys) ?? '';
      final name =
          _pickText(map, _nameKeys) ?? (username.isNotEmpty ? username : url);
      if (name.isEmpty) {
        skip('Entri $position tidak memiliki name, username, atau url');
        continue;
      }

      final duplicateKey = '${name.toLowerCase()}|${username.toLowerCase()}';
      if (seenKeys.contains(duplicateKey)) {
        skip('Duplikat dilewati: $name');
        continue;
      }
      seenKeys.add(duplicateKey);

      final now = DateTime.now();
      credentials.add(
        Credential(
          id: const Uuid().v4(),
          name: name,
          username: username,
          password: _pickText(map, _passwordKeys) ?? '',
          url: url,
          category: _normalizeCategory(_pickText(map, _categoryKeys)),
          tags: _parseTags(map),
          notes: _pickText(map, _notesKeys) ?? '',
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    return JsonImportResult(
      credentials: credentials,
      skipped: skipped,
      warnings: warnings,
    );
  }

  dynamic _decode(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('File JSON kosong');
    }
    try {
      return jsonDecode(trimmed);
    } on FormatException {
      throw const FormatException('Isi file bukan JSON yang valid');
    }
  }

  List<dynamic>? _extractItems(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is! Map) return null;

    for (final key in _wrapperKeys) {
      final value = decoded[key];
      if (value is List) return value;
    }

    if (_looksLikeCredential(decoded)) {
      return <dynamic>[decoded];
    }
    return null;
  }

  bool _looksLikeCredential(Map<dynamic, dynamic> map) {
    final keys = <String>{
      ..._nameKeys,
      ..._usernameKeys,
      ..._passwordKeys,
      ..._urlKeys,
    };
    return map.keys.any((key) => key is String && keys.contains(key));
  }

  String? _pickText(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final text = _asText(map[key]);
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  String? _asText(dynamic value) {
    if (value is String) return value.trim();
    if (value is num) return value.toString();
    return null;
  }

  List<String> _parseTags(Map<String, dynamic> map) {
    final value = map['tags'] ?? map['tag'];
    final tags = <String>[];

    void add(String? text) {
      final trimmed = text?.trim() ?? '';
      if (trimmed.isEmpty || tags.contains(trimmed)) return;
      tags.add(trimmed);
    }

    if (value is List) {
      for (final item in value) {
        add(_asText(item));
      }
    } else if (value is String) {
      for (final part in value.split(',')) {
        add(part);
      }
    } else {
      add(_asText(value));
    }
    return tags;
  }

  String _normalizeCategory(String? raw) {
    if (raw == null || raw.isEmpty) return VaultCategories.other;
    final needle = raw.toLowerCase();
    for (final category in VaultCategories.values) {
      if (category.toLowerCase() == needle) return category;
    }
    return VaultCategories.other;
  }
}
