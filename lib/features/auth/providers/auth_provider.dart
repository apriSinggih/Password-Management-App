import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/security/biometric_service.dart';
import '../../../core/security/crypto_service.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/security/totp_service.dart';
import '../../vault/data/vault_repository.dart';

enum AuthStatus { initializing, needsSetup, locked, unlocked }

enum UnlockResult { success, invalidPassword, totpRequired, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required this._storage,
    required this._crypto,
    required this._repository,
    required this._biometrics,
  });

  final SecureStorageService _storage;
  final CryptoService _crypto;
  final VaultRepository _repository;
  final BiometricService _biometrics;

  AuthStatus _status = AuthStatus.initializing;
  Uint8List? _salt;
  SecretKey? _key;
  SecretKey? _pendingKey;
  bool _awaitingTotp = false;
  bool _totpEnabled = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  int _autoLockSeconds = AppConstants.defaultAutoLockSeconds;
  String? _errorMessage;

  AuthStatus get status => _status;
  SecretKey? get key => _key;
  bool get isUnlocked => _status == AuthStatus.unlocked;
  bool get awaitingTotp => _awaitingTotp;
  bool get totpEnabled => _totpEnabled;
  bool get biometricEnabled => _biometricEnabled;
  bool get biometricAvailable => _biometricAvailable;
  int get autoLockSeconds => _autoLockSeconds;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    try {
      await _repository.open();
      final saltValue = await _storage.read(AppConstants.keySalt);
      _salt = saltValue == null ? null : base64Decode(saltValue);
      _totpEnabled = await _repository.metaExists(
        AppConstants.metaTotpSecret,
      );
      _biometricEnabled =
          await _storage.read(AppConstants.keyBiometricEnabled) == 'true';
      _biometricAvailable = await _biometrics.isAvailable();
      _autoLockSeconds =
          int.tryParse(
            await _storage.read(AppConstants.keyAutoLockSeconds) ?? '',
          ) ??
          AppConstants.defaultAutoLockSeconds;
      _status = _salt == null ? AuthStatus.needsSetup : AuthStatus.locked;
    } catch (error) {
      _errorMessage = 'Gagal menyiapkan brankas: $error';
      _status = _salt == null ? AuthStatus.needsSetup : AuthStatus.locked;
    }
    notifyListeners();
  }

  Future<String?> setupMasterPassword(String password) async {
    if (password.length < AppConstants.minMasterPasswordLength) {
      return 'Master password minimal '
          '${AppConstants.minMasterPasswordLength} karakter';
    }

    try {
      final salt = _crypto.newSalt();
      final key = await _crypto.deriveKey(password, salt);
      final verifier = await _crypto.encryptString(
        AppConstants.verifierPlaintext,
        key,
      );
      await _storage.write(AppConstants.keyVerifier, verifier);
      await _storage.write(AppConstants.keySalt, base64Encode(salt));
      await _storage.write(AppConstants.keyBiometricEnabled, 'false');
      _salt = salt;
      _key = key;
      _status = AuthStatus.unlocked;
      _errorMessage = null;
      _awaitingTotp = false;
      _pendingKey = null;
      notifyListeners();
      return null;
    } catch (error) {
      return 'Gagal membuat master password: $error';
    }
  }

  Future<UnlockResult> unlockWithPassword(String password) async {
    final salt = _salt;
    if (salt == null) return UnlockResult.error;

    try {
      final key = await _crypto.deriveKey(password, salt);
      if (!await _isKeyValid(key)) {
        _errorMessage = 'Master password salah';
        notifyListeners();
        return UnlockResult.invalidPassword;
      }

      if (_totpEnabled) {
        _pendingKey = key;
        _awaitingTotp = true;
        _errorMessage = null;
        notifyListeners();
        return UnlockResult.totpRequired;
      }

      await _completeUnlock(key);
      return UnlockResult.success;
    } catch (error) {
      _errorMessage = 'Gagal membuka brankas: $error';
      notifyListeners();
      return UnlockResult.error;
    }
  }

  Future<bool> submitTotpCode(String code) async {
    final key = _pendingKey;
    if (key == null) return false;

    try {
      final meta = await _repository.readMeta(
        AppConstants.metaTotpSecret,
        key,
      );
      final secret = meta?['secret'] as String?;
      if (secret == null) {
        _errorMessage = 'Konfigurasi 2FA tidak ditemukan';
        notifyListeners();
        return false;
      }
      if (!TotpService.verify(secret, code)) {
        _errorMessage = 'Kode 2FA tidak valid';
        notifyListeners();
        return false;
      }
      await _completeUnlock(key);
      return true;
    } catch (error) {
      _errorMessage = 'Gagal memverifikasi 2FA: $error';
      notifyListeners();
      return false;
    }
  }

  void cancelTotp() {
    _pendingKey = null;
    _awaitingTotp = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> unlockWithBiometrics() async {
    if (!_biometricEnabled || !_biometricAvailable) return false;

    try {
      final authenticated = await _biometrics.authenticate();
      if (!authenticated) return false;

      final encoded = await _storage.read(AppConstants.keyBiometricKey);
      if (encoded == null) return false;

      final key = _crypto.keyFromString(encoded);
      if (!await _isKeyValid(key)) return false;

      if (_totpEnabled) {
        _pendingKey = key;
        _awaitingTotp = true;
        _errorMessage = null;
        notifyListeners();
        return true;
      }

      await _completeUnlock(key);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> enableBiometric() async {
    final key = _key;
    if (key == null || !_biometricAvailable) return false;

    final authenticated = await _biometrics.authenticate();
    if (!authenticated) return false;

    await _storage.write(
      AppConstants.keyBiometricKey,
      await _crypto.encodeKey(key),
    );
    await _storage.write(AppConstants.keyBiometricEnabled, 'true');
    _biometricEnabled = true;
    notifyListeners();
    return true;
  }

  Future<void> disableBiometric() async {
    await _storage.delete(AppConstants.keyBiometricKey);
    await _storage.write(AppConstants.keyBiometricEnabled, 'false');
    _biometricEnabled = false;
    notifyListeners();
  }

  String startTotpSetup() => TotpService.generateSecret();

  Future<bool> confirmTotpSetup(String secret, String code) async {
    final key = _key;
    if (key == null) return false;

    if (!TotpService.verify(secret, code)) {
      _errorMessage = 'Kode verifikasi salah. Coba lagi.';
      notifyListeners();
      return false;
    }

    await _repository.writeMeta(
      AppConstants.metaTotpSecret,
      <String, dynamic>{
        'secret': secret,
        'created_at': DateTime.now().toIso8601String(),
      },
      key,
    );
    _totpEnabled = true;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  Future<void> disableTotp() async {
    await _repository.deleteMeta(AppConstants.metaTotpSecret);
    _totpEnabled = false;
    notifyListeners();
  }

  Future<void> setAutoLockSeconds(int seconds) async {
    _autoLockSeconds = seconds;
    await _storage.write(
      AppConstants.keyAutoLockSeconds,
      seconds.toString(),
    );
    notifyListeners();
  }

  Future<String?> changeMasterPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final currentKey = _key;
    final salt = _salt;
    if (currentKey == null || salt == null) {
      return 'Brankas sedang terkunci';
    }
    if (newPassword.length < AppConstants.minMasterPasswordLength) {
      return 'Master password baru minimal '
          '${AppConstants.minMasterPasswordLength} karakter';
    }
    if (newPassword == currentPassword) {
      return 'Master password baru harus berbeda dari yang lama';
    }

    try {
      final verificationKey = await _crypto.deriveKey(
        currentPassword,
        salt,
      );
      if (!await _isKeyValid(verificationKey)) {
        return 'Master password saat ini salah';
      }

      final newSalt = _crypto.newSalt();
      final newKey = await _crypto.deriveKey(newPassword, newSalt);
      await _repository.reencryptAll(
        oldKey: currentKey,
        newKey: newKey,
      );

      final verifier = await _crypto.encryptString(
        AppConstants.verifierPlaintext,
        newKey,
      );
      await _storage.write(AppConstants.keyVerifier, verifier);
      await _storage.write(AppConstants.keySalt, base64Encode(newSalt));

      if (_biometricEnabled) {
        await _storage.write(
          AppConstants.keyBiometricKey,
          await _crypto.encodeKey(newKey),
        );
      }

      _salt = newSalt;
      _key = newKey;
      _errorMessage = null;
      notifyListeners();
      return null;
    } catch (error) {
      return 'Gagal mengganti master password: $error';
    }
  }

  void lock() {
    if (_status != AuthStatus.unlocked) return;
    _key = null;
    _pendingKey = null;
    _awaitingTotp = false;
    _status = AuthStatus.locked;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _completeUnlock(SecretKey key) async {
    _key = key;
    _pendingKey = null;
    _awaitingTotp = false;
    _status = AuthStatus.unlocked;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _isKeyValid(SecretKey key) async {
    final verifier = await _storage.read(AppConstants.keyVerifier);
    if (verifier == null) return false;
    try {
      final plaintext = await _crypto.decryptString(verifier, key);
      return plaintext == AppConstants.verifierPlaintext;
    } catch (_) {
      return false;
    }
  }
}
