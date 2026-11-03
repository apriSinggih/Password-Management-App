import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/neo_palette.dart';
import '../../../core/utils/password_generator.dart';
import '../../../core/widgets/neobrutal.dart';
import '../../../core/widgets/password_field.dart';
import '../../../core/widgets/strength_meter.dart';
import '../providers/auth_provider.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  bool _acknowledged = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acknowledged) {
      _showMessage(
        'Centang pernyataan bahwa master password tidak dapat dipulihkan',
      );
      return;
    }

    final password = _passwordController.text;
    if (password != _confirmController.text) {
      _showMessage('Konfirmasi master password tidak sama');
      return;
    }
    if (PasswordGenerator.analyze(password).score < 2) {
      _showMessage('Gunakan master password yang lebih kuat');
      return;
    }

    setState(() => _loading = true);
    final error = await context
        .read<AuthProvider>()
        .setupMasterPassword(password);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      _showMessage(error);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = NeoPalette.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      NeobrutalContainer(
                        backgroundColor: palette.yellow,
                        borderRadius: 16,
                        padding: const EdgeInsets.all(18),
                        child: const Icon(
                          Icons.shield_outlined,
                          size: 40,
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
                              'Brankas digital offline',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'BUAT BRANKAS ANDA',
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Satu master password melindungi semua kredensial Anda. '
                    'Password ini tidak disimpan di mana pun.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        PasswordField(
                          controller: _passwordController,
                          label: 'MASTER PASSWORD',
                          hint: 'Minimal 8 karakter',
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Master password wajib diisi';
                            }
                            if (value.length <
                                AppConstants.minMasterPasswordLength) {
                              return 'Minimal ${AppConstants.minMasterPasswordLength} karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        if (_passwordController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: StrengthMeter(
                              password: _passwordController.text,
                            ),
                          ),
                        PasswordField(
                          controller: _confirmController,
                          label: 'KONFIRMASI PASSWORD',
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi wajib diisi';
                            }
                            if (value != _passwordController.text) {
                              return 'Password tidak sama';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  NeobrutalContainer(
                    backgroundColor: palette.coral,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Jika master password lupa, data TIDAK dapat '
                            'dipulihkan. Tidak ada server yang menyimpan '
                            'salinan password Anda.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  NeobrutalContainer(
                    backgroundColor: palette.card,
                    padding: EdgeInsets.zero,
                    child: CheckboxListTile(
                      value: _acknowledged,
                      onChanged: (value) =>
                          setState(() => _acknowledged = value ?? false),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        'Saya memahami dan menyimpan master password dengan aman',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  NeobrutalButton(
                    onPressed: _submit,
                    loading: _loading,
                    icon: Icons.lock_outline,
                    label: _loading ? 'Membuat...' : 'Buat Brankas',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
