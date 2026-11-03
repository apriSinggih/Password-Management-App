import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/neo_palette.dart';
import '../../../core/security/totp_service.dart';
import '../../../core/widgets/neobrutal.dart';
import '../../../core/widgets/password_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../vault/providers/vault_provider.dart';
import '../providers/settings_provider.dart';
import '../services/backup_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _setBusy(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickAutoLock() async {
    final auth = context.read<AuthProvider>();
    final selected = await _showChoiceDialog<int>(
      title: 'Auto-lock',
      options: AppConstants.autoLockOptions,
      current: auth.autoLockSeconds,
    );
    if (selected == null) return;
    await auth.setAutoLockSeconds(selected);
  }

  Future<void> _pickClipboard() async {
    final settings = context.read<SettingsProvider>();
    final selected = await _showChoiceDialog<int>(
      title: 'Bersihkan clipboard',
      options: AppConstants.clipboardOptions,
      current: settings.clipboardSeconds,
    );
    if (selected == null) return;
    await settings.setClipboardSeconds(selected);
  }

  Future<T?> _showChoiceDialog<T>({
    required String title,
    required Map<T, String> options,
    required T current,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: options.entries.map((entry) {
          final selected = entry.key == current;
          return SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(entry.key),
            child: Row(
              children: <Widget>[
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(entry.value)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _toggleBiometric(bool value) async {
    final auth = context.read<AuthProvider>();
    if (value) {
      final enabled = await auth.enableBiometric();
      if (!mounted) return;
      _message(
        enabled
            ? 'Biometrik berhasil diaktifkan'
            : 'Gagal mengaktifkan biometrik',
      );
    } else {
      await auth.disableBiometric();
      if (!mounted) return;
      _message('Biometrik dinonaktifkan');
    }
  }

  Future<void> _enableTotp() async {
    final auth = context.read<AuthProvider>();
    final secret = auth.startTotpSetup();
    final enabled = await showDialog<bool>(
      context: context,
      builder: (context) => _TotpSetupDialog(
        secret: secret,
        verify: (code) => auth.confirmTotpSetup(secret, code),
      ),
    );
    if (!mounted || enabled != true) return;
    _message('Autentikasi dua faktor diaktifkan');
  }

  Future<void> _disableTotp() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nonaktifkan 2FA?'),
        content: const Text(
          'Login berikutnya tidak lagi meminta kode authenticator.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('BATAL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Nonaktifkan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AuthProvider>().disableTotp();
    if (!mounted) return;
    _message('2FA dinonaktifkan');
  }

  Future<void> _changeMasterPassword() async {
    final auth = context.read<AuthProvider>();
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => _ChangePasswordDialog(
        onSubmit: (current, next) => auth.changeMasterPassword(
          currentPassword: current,
          newPassword: next,
        ),
      ),
    );
    if (!mounted || changed != true) return;
    _message('Master password berhasil diganti');
  }

  Future<void> _exportBackup() async {
    final auth = context.read<AuthProvider>();
    if (auth.key == null) {
      _message('Brankas terkunci');
      return;
    }

    await _setBusy(() async {
      try {
        final file = await context.read<BackupService>().createBackup();
        await SharePlus.instance.share(
          ShareParams(
            files: <XFile>[
              XFile(file.path, mimeType: 'application/octet-stream'),
            ],
            subject: 'SecureVault Backup',
            text: 'Backup terenkripsi SecureVault',
          ),
        );
        if (!mounted) return;
        _message('Backup terenkripsi dibuat dan siap dibagikan');
      } catch (error) {
        if (!mounted) return;
        _message('Gagal membuat backup: $error');
      }
    });
  }

  Future<void> _importBackup() async {
    final auth = context.read<AuthProvider>();
    final key = auth.key;
    if (key == null) {
      _message('Brankas terkunci');
      return;
    }

    PlatformFile? picked;
    try {
      picked = await FilePicker.pickFile(type: FileType.any);
    } catch (error) {
      _message('Gagal memilih file: $error');
      return;
    }
    if (picked?.path == null) return;

    if (!mounted) return;
    final backupService = context.read<BackupService>();
    final vaultProvider = context.read<VaultProvider>();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => const _PasswordPromptDialog(),
    );
    if (password == null || password.isEmpty) return;

    await _setBusy(() async {
      try {
        final count = await backupService.restoreBackup(
          filePath: picked!.path!,
          backupPassword: password,
          currentKey: key,
        );
        await vaultProvider.load();
        if (!mounted) return;
        _message('$count kredensial berhasil diimpor');
      } catch (error) {
        if (!mounted) return;
        _message('Gagal mengimpor backup: $error');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('PENGATURAN')),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: <Widget>[
              _SettingsCard(
                title: 'Keamanan',
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: const Text('Auto-lock'),
                    subtitle: Text(
                      AppConstants.autoLockOptions[auth.autoLockSeconds] ??
                          '${auth.autoLockSeconds} detik',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _pickAutoLock,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint),
                    title: const Text('Autentikasi biometrik'),
                    subtitle: Text(
                      auth.biometricAvailable
                          ? 'Gunakan sidik jari / wajah untuk membuka brankas'
                          : 'Tidak tersedia di perangkat ini',
                    ),
                    value: auth.biometricEnabled,
                    onChanged: auth.biometricAvailable
                        ? _toggleBiometric
                        : null,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.security),
                    title: const Text('Autentikasi dua faktor (2FA)'),
                    subtitle: const Text(
                      'Minta kode TOTP dari aplikasi authenticator',
                    ),
                    value: auth.totpEnabled,
                    onChanged: auth.isUnlocked
                        ? (value) {
                            if (value) {
                              _enableTotp();
                            } else {
                              _disableTotp();
                            }
                          }
                        : null,
                  ),
                  ListTile(
                    leading: const Icon(Icons.password_outlined),
                    title: const Text('Ganti master password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _changeMasterPassword,
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Kunci brankas sekarang'),
                    onTap: auth.lock,
                  ),
                ],
              ),
              _SettingsCard(
                title: 'Clipboard',
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.content_paste_off_outlined),
                    title: const Text('Bersihkan clipboard otomatis'),
                    subtitle: Text(
                      AppConstants.clipboardOptions[settings
                              .clipboardSeconds] ??
                          '${settings.clipboardSeconds} detik',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _pickClipboard,
                  ),
                ],
              ),
              _SettingsCard(
                title: 'Data & Backup',
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.upload_file_outlined),
                    title: const Text('Ekspor backup terenkripsi'),
                    subtitle: const Text(
                      'Bagikan file backup yang dilindungi master password',
                    ),
                    onTap: _busy ? null : _exportBackup,
                  ),
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: const Text('Impor backup'),
                    subtitle: const Text(
                      'Pulihkan kredensial dari file backup SecureVault',
                    ),
                    onTap: _busy ? null : _importBackup,
                  ),
                ],
              ),
              _SettingsCard(
                title: 'Tentang',
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.shield_outlined),
                    title: const Text(AppConstants.appName),
                    subtitle: const Text('Versi 1.0.0'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Text(
                      'Semua data dienkripsi di perangkat dengan '
                      'AES-256-GCM. Kunci diturunkan dari master password '
                      'menggunakan PBKDF2-HMAC-SHA256 '
                      '(${AppConstants.pbkdf2Iterations} iterasi). '
                      'Tidak ada master password atau data yang dikirim ke '
                      'server.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Offline-first • Zero-knowledge • AES-256',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (_busy)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black45,
                child: Center(
                  child: NeobrutalContainer(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'MEMPROSES...',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = NeoPalette.of(context);
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(const Divider(height: 2, indent: 16, endIndent: 16));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 6,
                  height: 18,
                  decoration: BoxDecoration(
                    color: palette.purple,
                    border: Border.all(
                      color: palette.border,
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w900,
                    color: palette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          NeobrutalContainer(
            padding: EdgeInsets.zero,
            child: Column(children: items),
          ),
        ],
      ),
    );
  }
}

class _TotpSetupDialog extends StatefulWidget {
  const _TotpSetupDialog({required this.secret, required this.verify});

  final String secret;
  final Future<bool> Function(String code) verify;

  @override
  State<_TotpSetupDialog> createState() => _TotpSetupDialogState();
}

class _TotpSetupDialogState extends State<_TotpSetupDialog> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _copySecret() async {
    await Clipboard.setData(ClipboardData(text: widget.secret));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Secret 2FA disalin')),
    );
  }

  Future<void> _copyUri() async {
    await Clipboard.setData(
      ClipboardData(
        text: TotpService.otpauthUri(
          secret: widget.secret,
          account: 'SecureVault',
        ),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URI otpauth disalin')),
    );
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Masukkan 6 digit kode');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final success = await widget.verify(code);
    if (!mounted) return;
    setState(() => _loading = false);
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = 'Kode tidak valid, coba lagi');
      _codeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Aktifkan 2FA'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Tambahkan secret berikut ke aplikasi authenticator '
                '(Google Authenticator, Authy, dll), lalu masukkan kode '
                '6 digit yang dihasilkan.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              NeobrutalContainer(
                backgroundColor: NeoPalette.of(context).muted,
                padding: const EdgeInsets.all(14),
                shadowOffset: const Offset(3, 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'SECRET KEY',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: NeoPalette.of(context).textSecondary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: SelectableText(
                            widget.secret,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'JetBrainsMono',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Salin secret',
                          icon: const Icon(Icons.copy_outlined),
                          onPressed: _copySecret,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _copyUri,
                  icon: const Icon(Icons.qr_code_2, size: 18),
                  label: const Text('Salin URI otpauth'),
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: theme.textTheme.titleLarge?.copyWith(
                  letterSpacing: 8,
                  fontFamily: 'JetBrainsMono',
                  fontWeight: FontWeight.w900,
                ),
                decoration: const InputDecoration(
                  labelText: 'Kode verifikasi',
                  counterText: '',
                  hintText: '000000',
                ),
                onSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Kode saat ini: ${TotpService.codeFor(widget.secret)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('BATAL'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Aktifkan'),
        ),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({required this.onSubmit});

  final Future<String?> Function(String current, String next) onSubmit;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _nextController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _nextController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentController.text;
    final next = _nextController.text;
    if (current.isEmpty) {
      setState(() => _error = 'Masukkan master password saat ini');
      return;
    }
    if (next.length < AppConstants.minMasterPasswordLength) {
      setState(() => _error = 'Master password baru minimal '
          '${AppConstants.minMasterPasswordLength} karakter');
      return;
    }
    if (next != _confirmController.text) {
      setState(() => _error = 'Konfirmasi password tidak sama');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await widget.onSubmit(current, next);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Ganti Master Password'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              PasswordField(
                controller: _currentController,
                label: 'Master password saat ini',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _nextController,
                label: 'Master password baru',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _confirmController,
                label: 'Ulangi master password baru',
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                'Seluruh data akan dienkripsi ulang dengan kunci baru. '
                'Proses ini tidak dapat dibatalkan.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('BATAL'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Ganti Password'),
        ),
      ],
    );
  }
}

class _PasswordPromptDialog extends StatefulWidget {
  const _PasswordPromptDialog();

  @override
  State<_PasswordPromptDialog> createState() => _PasswordPromptDialogState();
}

class _PasswordPromptDialogState extends State<_PasswordPromptDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Master password backup'),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Masukkan master password yang digunakan saat backup dibuat.',
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _controller,
              label: 'Master password backup',
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) =>
                  Navigator.of(context).pop(value),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('BATAL'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(_controller.text),
          child: const Text('IMPOR'),
        ),
      ],
    );
  }
}
