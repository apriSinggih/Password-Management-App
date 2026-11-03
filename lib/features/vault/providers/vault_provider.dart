import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/categories.dart';
import '../data/vault_repository.dart';
import '../domain/credential.dart';

class VaultProvider extends ChangeNotifier {
  VaultProvider({required this._repository});

  final VaultRepository _repository;

  SecretKey? _key;
  List<Credential> _credentials = <Credential>[];
  bool _loading = false;
  String? _error;
  String _search = '';
  String _category = VaultCategories.all;

  bool get isLoading => _loading;
  String? get error => _error;
  String get search => _search;
  String get selectedCategory => _category;
  List<Credential> get credentials => List.unmodifiable(_credentials);
  List<String> get categories => <String>[
    VaultCategories.all,
    ...VaultCategories.values,
  ];

  List<Credential> get filteredCredentials {
    final query = _search.trim();
    return _credentials.where((credential) {
      final inCategory =
          _category == VaultCategories.all ||
          credential.category == _category;
      return inCategory && credential.matches(query);
    }).toList();
  }

  int countForCategory(String category) {
    if (category == VaultCategories.all) return _credentials.length;
    return _credentials.where((item) => item.category == category).length;
  }

  Future<void> bindKey(SecretKey? key) async {
    if (key == null) {
      _key = null;
      _credentials = <Credential>[];
      _loading = false;
      _error = null;
      notifyListeners();
      return;
    }
    if (identical(_key, key)) return;
    _key = key;
    await load();
  }

  Future<void> load() async {
    final key = _key;
    if (key == null) return;
    _loading = true;
    notifyListeners();
    try {
      _credentials = await _repository.loadAll(key);
      _error = null;
    } catch (error) {
      _error = 'Gagal memuat brankas: $error';
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> save(Credential credential) async {
    final key = _key;
    if (key == null) return 'Brankas terkunci';

    try {
      final index = _credentials.indexWhere(
        (item) => item.id == credential.id,
      );
      Credential toSave = credential;

      if (index >= 0) {
        final old = _credentials[index];
        if (old.password != credential.password) {
          final history = <PasswordHistoryEntry>[
            PasswordHistoryEntry(
              password: old.password,
              changedAt: old.updatedAt,
            ),
            ...old.history,
          ];
          if (history.length > AppConstants.maxHistoryEntries) {
            history.removeRange(
              AppConstants.maxHistoryEntries,
              history.length,
            );
          }
          toSave = credential.copyWith(
            history: history,
            createdAt: old.createdAt,
            updatedAt: DateTime.now(),
          );
        } else {
          toSave = credential.copyWith(
            createdAt: old.createdAt,
            updatedAt: DateTime.now(),
          );
        }
      } else {
        toSave = credential.copyWith(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      await _repository.save(toSave, key);

      final savedIndex = _credentials.indexWhere(
        (item) => item.id == toSave.id,
      );
      if (savedIndex >= 0) {
        _credentials[savedIndex] = toSave;
      } else {
        _credentials.add(toSave);
      }
      _sort();
      notifyListeners();
      return null;
    } catch (error) {
      return 'Gagal menyimpan kredensial: $error';
    }
  }

  Future<String?> delete(String id) async {
    try {
      await _repository.delete(id);
      _credentials.removeWhere((item) => item.id == id);
      notifyListeners();
      return null;
    } catch (error) {
      return 'Gagal menghapus kredensial: $error';
    }
  }

  void setSearch(String value) {
    if (_search == value) return;
    _search = value;
    notifyListeners();
  }

  void setCategory(String category) {
    if (_category == category) return;
    _category = category;
    notifyListeners();
  }

  void _sort() {
    _credentials.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
  }
}
