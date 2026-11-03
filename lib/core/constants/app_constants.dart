class AppConstants {
  static const String appName = 'SecureVault';
  static const String dbName = 'secure_vault.db';

  static const String keySalt = 'vault_salt';
  static const String keyVerifier = 'vault_verifier';
  static const String keyBiometricKey = 'vault_biometric_key';
  static const String keyBiometricEnabled = 'settings_biometric_enabled';
  static const String keyAutoLockSeconds = 'settings_auto_lock_seconds';
  static const String keyClipboardSeconds = 'settings_clipboard_seconds';

  static const String metaTotpSecret = 'totp_secret';
  static const String verifierPlaintext = 'securevault.verifier.v1';

  static const int pbkdf2Iterations = 120000;
  static const int saltLength = 16;
  static const int defaultAutoLockSeconds = 60;
  static const int defaultClipboardSeconds = 30;
  static const int maxHistoryEntries = 10;
  static const int minMasterPasswordLength = 8;

  static const Map<int, String> autoLockOptions = <int, String>{
    0: 'Segera saat aplikasi ke background',
    60: 'Setelah 1 menit',
    120: 'Setelah 2 menit',
    300: 'Setelah 5 menit',
  };

  static const Map<int, String> clipboardOptions = <int, String>{
    0: 'Jangan bersihkan',
    15: 'Setelah 15 detik',
    30: 'Setelah 30 detik',
    60: 'Setelah 60 detik',
  };
}
