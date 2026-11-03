import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/categories.dart';
import '../../../core/theme/neo_palette.dart';
import '../../../core/widgets/neobrutal.dart';
import '../../../core/utils/password_generator.dart';
import '../../../core/widgets/password_field.dart';
import '../../../core/widgets/strength_meter.dart';
import '../domain/credential.dart';
import '../providers/vault_provider.dart';
import 'widgets/category_style.dart';

class CredentialEditScreen extends StatefulWidget {
  const CredentialEditScreen({super.key, this.credential});

  final Credential? credential;

  bool get isEditing => credential != null;

  @override
  State<CredentialEditScreen> createState() => _CredentialEditScreenState();
}

class _CredentialEditScreenState extends State<CredentialEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Credential _base;
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _urlController;
  late final TextEditingController _tagsController;
  late final TextEditingController _notesController;
  late String _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _base = widget.credential ?? Credential.empty();
    _nameController = TextEditingController(text: _base.name);
    _usernameController = TextEditingController(text: _base.username);
    _passwordController = TextEditingController(text: _base.password);
    _urlController = TextEditingController(text: _base.url);
    _tagsController = TextEditingController(text: _base.tags.join(', '));
    _notesController = TextEditingController(text: _base.notes);
    _category = VaultCategories.values.contains(_base.category)
        ? _base.category
        : VaultCategories.other;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    final credential = _base.copyWith(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      url: _urlController.text.trim(),
      category: _category,
      tags: tags,
      notes: _notesController.text.trim(),
    );

    setState(() => _saving = true);
    final error = await context.read<VaultProvider>().save(credential);
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _openGenerator() async {
    final generated = await showDialog<String>(
      context: context,
      builder: (_) => const _GeneratorDialog(),
    );
    if (generated == null) return;
    setState(() => _passwordController.text = generated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'EDIT KREDENSIAL' : 'KREDENSIAL BARU',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('SIMPAN'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            _SectionLabel('Informasi Akun'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nama Layanan / Aplikasi',
                prefixIcon: Icon(Icons.apps),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama layanan wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Username / Email',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: VaultCategories.values.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        CategoryStyle.iconFor(category),
                        size: 18,
                        color: CategoryStyle.colorFor(category),
                      ),
                      const SizedBox(width: 10),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 24),
            _SectionLabel('Keamanan'),
            const SizedBox(height: 10),
            PasswordField(
              controller: _passwordController,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            StrengthMeter(password: _passwordController.text),
            const SizedBox(height: 10),
            NeobrutalButton(
              onPressed: _openGenerator,
              icon: Icons.auto_awesome,
              backgroundColor: NeoPalette.of(context).card,
              label: 'Buat Password Kuat',
            ),
            const SizedBox(height: 24),
            _SectionLabel('Detail Lainnya'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'URL / Situs Web',
                hintText: 'https://contoh.com',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tagsController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Tag',
                hintText: 'kerja, penting, pribadi',
                helperText: 'Pisahkan beberapa tag dengan koma',
                prefixIcon: Icon(Icons.sell_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Catatan tambahan',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 28),
            NeobrutalButton(
              onPressed: _save,
              loading: _saving,
              icon: Icons.save_outlined,
              label: _saving ? 'Menyimpan...' : 'Simpan Kredensial',
            ),
            if (widget.isEditing) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                'Riwayat password lama akan disimpan otomatis saat password '
                'diubah (maksimal ${AppConstants.maxHistoryEntries} entri).',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = NeoPalette.of(context);
    return Row(
      children: <Widget>[
        Container(
          width: 6,
          height: 18,
          decoration: BoxDecoration(
            color: palette.purple,
            border: Border.all(color: palette.border, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            letterSpacing: 1.4,
            fontWeight: FontWeight.w900,
            color: palette.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _GeneratorDialog extends StatefulWidget {
  const _GeneratorDialog();

  @override
  State<_GeneratorDialog> createState() => _GeneratorDialogState();
}

class _GeneratorDialogState extends State<_GeneratorDialog> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Password Generator'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              NeobrutalContainer(
                backgroundColor: NeoPalette.of(context).muted,
                padding: const EdgeInsets.all(14),
                shadowOffset: const Offset(3, 3),
                child: SelectableText(
                  _password,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              StrengthMeter(password: _password),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Panjang'),
                  Text('$_length karakter'),
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
              SwitchListTile(
                value: _uppercase,
                contentPadding: EdgeInsets.zero,
                title: const Text('Huruf kapital (A-Z)'),
                onChanged: _activePools == 1 && _uppercase
                    ? null
                    : (value) {
                        setState(() => _uppercase = value);
                        _regenerate();
                      },
              ),
              SwitchListTile(
                value: _lowercase,
                contentPadding: EdgeInsets.zero,
                title: const Text('Huruf kecil (a-z)'),
                onChanged: _activePools == 1 && _lowercase
                    ? null
                    : (value) {
                        setState(() => _lowercase = value);
                        _regenerate();
                      },
              ),
              SwitchListTile(
                value: _digits,
                contentPadding: EdgeInsets.zero,
                title: const Text('Angka (0-9)'),
                onChanged: _activePools == 1 && _digits
                    ? null
                    : (value) {
                        setState(() => _digits = value);
                        _regenerate();
                      },
              ),
              SwitchListTile(
                value: _symbols,
                contentPadding: EdgeInsets.zero,
                title: const Text('Simbol (!@#...)'),
                onChanged: _activePools == 1 && _symbols
                    ? null
                    : (value) {
                        setState(() => _symbols = value);
                        _regenerate();
                      },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _regenerate,
          child: const Text('ACAK ULANG'),
        ),
        NeobrutalButton(
          expand: false,
          height: 44,
          onPressed: () => Navigator.of(context).pop(_password),
          label: 'Gunakan',
        ),
      ],
    );
  }
}
