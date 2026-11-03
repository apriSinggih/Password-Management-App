import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/neo_palette.dart';
import '../../../core/widgets/neobrutal.dart';
import '../../../core/widgets/password_field.dart';
import '../providers/auth_provider.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _passwordController = TextEditingController();
  final _totpController = TextEditingController();
  bool _loading = false;
  bool _biometricLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _totpController.dispose();
    super.dispose();
  }

  Future<void> _unlockWithPassword() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      _message('Masukkan master password');
      return;
    }

    setState(() => _loading = true);
    await context.read<AuthProvider>().unlockWithPassword(password);
    if (!mounted) return;
    setState(() => _loading = false);
    _passwordController.clear();
  }

  Future<void> _submitTotp() async {
    final code = _totpController.text.trim();
    if (code.length != 6) {
      _message('Kode 2FA terdiri dari 6 digit');
      return;
    }

    setState(() => _loading = true);
    final success = await context.read<AuthProvider>().submitTotpCode(code);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!success) {
      _totpController.clear();
    }
  }

  Future<void> _unlockWithBiometrics() async {
    setState(() => _biometricLoading = true);
    final success = await context
        .read<AuthProvider>()
        .unlockWithBiometrics();
    if (!mounted) return;
    setState(() => _biometricLoading = false);
    if (!success) {
      _message('Autentikasi biometrik gagal atau dibatalkan');
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final palette = NeoPalette.of(context);
    final waitingTotp = auth.awaitingTotp;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      NeobrutalContainer(
                        backgroundColor: waitingTotp
                            ? palette.cyan
                            : palette.yellow,
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          waitingTotp
                              ? Icons.security
                              : Icons.lock_outline,
                          size: 34,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'SECUREVAULT',
                              style: theme.textTheme.labelMedium?.copyWith(
                                letterSpacing: 2.4,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              waitingTotp ? 'Verifikasi dua faktor' : 'Vault',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: palette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    waitingTotp ? 'VERIFIKASI 2FA' : 'BRANKAS TERKUNCI',
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    waitingTotp
                        ? 'Masukkan 6 digit kode dari aplikasi authenticator Anda.'
                        : 'Masukkan master password atau gunakan biometrik '
                              'untuk membuka brankas.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 26),
                  NeobrutalContainer(
                    padding: const EdgeInsets.all(18),
                    child: waitingTotp
                        ? _buildTotpForm(auth, theme, palette)
                        : _buildPasswordForm(auth, theme, palette),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordForm(
    AuthProvider auth,
    ThemeData theme,
    NeoPalette palette,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PasswordField(
          controller: _passwordController,
          label: 'MASTER PASSWORD',
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _unlockWithPassword(),
        ),
        if (auth.errorMessage != null) ...<Widget>[
          const SizedBox(height: 14),
          NeobrutalContainer(
            backgroundColor: palette.coral,
            padding: const EdgeInsets.all(12),
            shadowOffset: const Offset(3, 3),
            child: Text(
              auth.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        NeobrutalButton(
          onPressed: _unlockWithPassword,
          loading: _loading,
          icon: Icons.lock_open,
          label: _loading ? 'Membuka...' : 'Buka Brankas',
        ),
        if (auth.biometricEnabled && auth.biometricAvailable) ...<Widget>[
          const SizedBox(height: 12),
          NeobrutalButton(
            onPressed: _unlockWithBiometrics,
            loading: _biometricLoading,
            icon: Icons.fingerprint,
            backgroundColor: palette.card,
            label: 'Buka dengan Biometrik',
          ),
        ],
      ],
    );
  }

  Widget _buildTotpForm(
    AuthProvider auth,
    ThemeData theme,
    NeoPalette palette,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _totpController,
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: theme.textTheme.headlineSmall?.copyWith(
            letterSpacing: 10,
            fontWeight: FontWeight.w900,
            fontFamily: 'JetBrainsMono',
          ),
          decoration: const InputDecoration(
            labelText: 'KODE 2FA',
            counterText: '',
            hintText: '000000',
          ),
          onSubmitted: (_) => _submitTotp(),
        ),
        if (auth.errorMessage != null) ...<Widget>[
          const SizedBox(height: 14),
          NeobrutalContainer(
            backgroundColor: palette.coral,
            padding: const EdgeInsets.all(12),
            shadowOffset: const Offset(3, 3),
            child: Text(
              auth.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        NeobrutalButton(
          onPressed: _submitTotp,
          loading: _loading,
          icon: Icons.verified_user_outlined,
          label: _loading ? 'Memverifikasi...' : 'Verifikasi & Buka',
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: _loading
              ? null
              : () {
                  context.read<AuthProvider>().cancelTotp();
                  _totpController.clear();
                },
          child: const Text('Kembali ke master password'),
        ),
      ],
    );
  }
}
