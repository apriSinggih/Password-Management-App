import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/security/secure_storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({required this._storage});

  final SecureStorageService _storage;

  int _clipboardSeconds = AppConstants.defaultClipboardSeconds;

  int get clipboardSeconds => _clipboardSeconds;

  Future<void> init() async {
    final stored = await _storage.read(AppConstants.keyClipboardSeconds);
    _clipboardSeconds =
        int.tryParse(stored ?? '') ?? AppConstants.defaultClipboardSeconds;
    notifyListeners();
  }

  Future<void> setClipboardSeconds(int seconds) async {
    _clipboardSeconds = seconds;
    await _storage.write(
      AppConstants.keyClipboardSeconds,
      seconds.toString(),
    );
    notifyListeners();
  }
}
