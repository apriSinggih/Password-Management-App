import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/neo_palette.dart';
import '../../../core/utils/clipboard_helper.dart';
import '../../../core/utils/password_generator.dart';
import '../../../core/widgets/neobrutal.dart';
import '../../../core/widgets/strength_meter.dart';
import '../../settings/providers/settings_provider.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  int _length = 20;
  bool _uppercase = true;
  bool _lowercase = true;
  bool _digits = true;
  bool _symbols = true;
  late String _password;

  @override
  void initState() {
    super.initState();
    _password = _generate();
  }

  String _generate() {
    return PasswordGenerator.generate(
      length: _length,
      useUppercase: _uppercase,
      useLowercase: _lowercase,
      useDigits: _digits,
      useSymbols: _symbols,
    );
  }

  void _regenerate() {
    setState(() => _password = _generate());
  }

  int get _activePools {
    return <bool>[_uppercase, _lowercase, _digits, _symbols]
        .where((item) => item)
        .length;
  }

  Future<void> _copy() async {
    final seconds = context.read<SettingsProvider>().clipboardSeconds;
    await ClipboardHelper.copy(_password, clearAfterSeconds: seconds);
    if (!mounted) return;
    final suffix = seconds > 0
        ? ' Dihapus otomatis dalam $seconds detik.'
        : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password disalin ke clipboard.$suffix')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = NeoPalette.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('GENERATOR')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          NeobrutalContainer(
            backgroundColor: palette.purple,
            padding: const EdgeInsets.all(20),
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'PASSWORD BARU',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  _password,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: NeobrutalButton(
                        onPressed: _copy,
                        icon: Icons.copy_outlined,
                        height: 48,
                        label: 'Salin',
                      ),
                    ),
                    const SizedBox(width: 10),
                    NeobrutalIconButton(
                      icon: Icons.refresh,
                      tooltip: 'Acak ulang',
                      size: 48,
                      onPressed: _regenerate,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          NeobrutalContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                StrengthMeter(password: _password),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'PANJANG PASSWORD',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      '$_length KARAKTER',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: palette.textSecondary,
                        fontFamily: 'JetBrainsMono',
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _length.toDouble(),
                  min: 8,
                  max: 64,
                  divisions: 56,
                  label: '$_length',
                  onChanged: (value) =>
                      setState(() => _length = value.round()),
                  onChangeEnd: (_) => _regenerate(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          NeobrutalContainer(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                _OptionTile(
                  value: _uppercase,
                  title: 'Huruf kapital (A-Z)',
                  subtitle: '26 karakter',
                  icon: Icons.text_fields,
                  onChange: _activePools == 1 && _uppercase
                      ? null
                      : (value) {
                          setState(() => _uppercase = value);
                          _regenerate();
                        },
                ),
                const Divider(height: 2),
                _OptionTile(
                  value: _lowercase,
                  title: 'Huruf kecil (a-z)',
                  subtitle: '26 karakter',
                  icon: Icons.text_format,
                  onChange: _activePools == 1 && _lowercase
                      ? null
                      : (value) {
                          setState(() => _lowercase = value);
                          _regenerate();
                        },
                ),
                const Divider(height: 2),
                _OptionTile(
                  value: _digits,
                  title: 'Angka (0-9)',
                  subtitle: '10 karakter',
                  icon: Icons.pin_outlined,
                  onChange: _activePools == 1 && _digits
                      ? null
                      : (value) {
                          setState(() => _digits = value);
                          _regenerate();
                        },
                ),
                const Divider(height: 2),
                _OptionTile(
                  value: _symbols,
                  title: 'Simbol (!@#\$)',
                  subtitle: 'Karakter khusus',
                  icon: Icons.data_object,
                  onChange: _activePools == 1 && _symbols
                      ? null
                      : (value) {
                          setState(() => _symbols = value);
                          _regenerate();
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          NeobrutalButton(
            onPressed: _regenerate,
            icon: Icons.auto_awesome,
            label: 'Buat Password Baru',
          ),
          const SizedBox(height: 16),
          Text(
            'Password dibuat sepenuhnya di perangkat menggunakan generator '
            'acak kriptografis. Tidak ada data yang dikirim ke server.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onChange,
  });

  final bool value;
  final String title;
  final String subtitle;
  final IconData icon;
  final ValueChanged<bool>? onChange;

  @override
  Widget build(BuildContext context) {
    final palette = NeoPalette.of(context);
    return SwitchListTile(
      value: value,
      onChanged: onChange,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: palette.textSecondary,
        ),
      ),
      secondary: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: palette.muted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: palette.border, width: 2),
        ),
        child: Icon(icon, size: 19, color: palette.textPrimary),
      ),
    );
  }
}
