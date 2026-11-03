import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/security/biometric_service.dart';
import 'core/security/crypto_service.dart';
import 'core/security/secure_storage_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/settings/services/backup_service.dart';
import 'features/vault/data/vault_repository.dart';
import 'features/vault/providers/vault_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = SecureStorageService();
  final crypto = CryptoService();
  final repository = VaultRepository(crypto: crypto);
  final biometrics = BiometricService();

  final authProvider = AuthProvider(
    storage: storage,
    crypto: crypto,
    repository: repository,
    biometrics: biometrics,
  );
  final settingsProvider = SettingsProvider(storage: storage);
  final backupService = BackupService(
    storage: storage,
    crypto: crypto,
    repository: repository,
  );

  await Future.wait<void>(<Future<void>>[
    authProvider.init(),
    settingsProvider.init(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        Provider<BackupService>.value(value: backupService),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
        ),
        ChangeNotifierProxyProvider<AuthProvider, VaultProvider>(
          create: (_) => VaultProvider(repository: repository),
          update: (_, auth, vault) {
            final provider = vault!;
            final key = auth.key;
            Future<void>.microtask(() => provider.bindKey(key));
            return provider;
          },
        ),
      ],
      child: const SecureVaultApp(),
    ),
  );
}
