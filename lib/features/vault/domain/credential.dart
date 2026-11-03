import 'package:uuid/uuid.dart';

class PasswordHistoryEntry {
  const PasswordHistoryEntry({
    required this.password,
    required this.changedAt,
  });

  final String password;
  final DateTime changedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'password': password,
    'changed_at': changedAt.toIso8601String(),
  };

  factory PasswordHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PasswordHistoryEntry(
      password: json['password'] as String? ?? '',
      changedAt:
          DateTime.tryParse(json['changed_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class Credential {
  const Credential({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    this.url = '',
    this.category = 'Lainnya',
    this.tags = const <String>[],
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
    this.history = const <PasswordHistoryEntry>[],
  });

  final String id;
  final String name;
  final String username;
  final String password;
  final String url;
  final String category;
  final List<String> tags;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PasswordHistoryEntry> history;

  factory Credential.empty() {
    final now = DateTime.now();
    return Credential(
      id: const Uuid().v4(),
      name: '',
      username: '',
      password: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  Credential copyWith({
    String? name,
    String? username,
    String? password,
    String? url,
    String? category,
    List<String>? tags,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PasswordHistoryEntry>? history,
  }) {
    return Credential(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'username': username,
    'password': password,
    'url': url,
    'category': category,
    'tags': tags,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'history': history.map((entry) => entry.toJson()).toList(),
  };

  factory Credential.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Credential(
      id: json['id'] as String? ?? const Uuid().v4(),
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      url: json['url'] as String? ?? '',
      category: json['category'] as String? ?? 'Lainnya',
      tags: (json['tags'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      notes: json['notes'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ?? now,
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ?? now,
      history: (json['history'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(PasswordHistoryEntry.fromJson)
          .toList(),
    );
  }

  String get primaryInitial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
  }

  bool matches(String query) {
    if (query.isEmpty) return true;
    final needle = query.toLowerCase();
    return name.toLowerCase().contains(needle) ||
        username.toLowerCase().contains(needle) ||
        url.toLowerCase().contains(needle) ||
        category.toLowerCase().contains(needle) ||
        notes.toLowerCase().contains(needle) ||
        tags.any((tag) => tag.toLowerCase().contains(needle));
  }
}
