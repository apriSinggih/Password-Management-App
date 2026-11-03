import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/neo_palette.dart';
import '../../../core/utils/clipboard_helper.dart';
import '../../../core/widgets/neobrutal.dart';
import '../../settings/providers/settings_provider.dart';
import '../domain/credential.dart';
import '../providers/vault_provider.dart';
import 'credential_edit_screen.dart';
import 'widgets/category_style.dart';

class CredentialDetailScreen extends StatefulWidget {
  const CredentialDetailScreen({super.key, required this.credentialId});

  final String credentialId;

  @override
  State<CredentialDetailScreen> createState() =>
      _CredentialDetailScreenState();
}

class _CredentialDetailScreenState extends State<CredentialDetailScreen> {
  bool _revealPassword = false;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy • HH:mm');

  Future<void> _copy(String label, String value) async {
    final seconds = context.read<SettingsProvider>().clipboardSeconds;
    await ClipboardHelper.copy(value, clearAfterSeconds: seconds);
    if (!mounted) return;
    final suffix = seconds > 0
        ? ' Dihapus otomatis dalam $seconds detik.'
        : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label disalin ke clipboard.$suffix')),
    );
  }

  Future<void> _openUrl(String rawUrl) async {
    var uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) {
      _showMessage('URL tidak valid');
      return;
    }
    if (!uri.hasScheme) {
      uri = Uri.tryParse('https://${rawUrl.trim()}');
    }
    if (uri == null) {
      _showMessage('URL tidak valid');
      return;
    }
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) _showMessage('Tidak dapat membuka URL');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _edit(Credential credential) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CredentialEditScreen(credential: credential),
      ),
    );
  }

  Future<void> _delete(Credential credential) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('HAPUS KREDENSIAL?'),
        content: Text(
          '${credential.name} akan dihapus permanen dari brankas.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('BATAL'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: NeoPalette.of(context).coral,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final error = await context.read<VaultProvider>().delete(credential.id);
    if (!mounted) return;
    if (error != null) {
      _showMessage(error);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultProvider>();
    final palette = NeoPalette.of(context);
    final theme = Theme.of(context);
    final index = vault.credentials.indexWhere(
      (item) => item.id == widget.credentialId,
    );
    if (index < 0) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Kredensial tidak ditemukan')),
      );
    }

    final credential = vault.credentials[index];
    final color = CategoryStyle.colorFor(credential.category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DETAIL'),
        actions: <Widget>[
          NeobrutalIconButton(
            icon: Icons.edit_outlined,
            tooltip: 'Edit',
            size: 40,
            iconSize: 19,
            onPressed: () => _edit(credential),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: NeobrutalIconButton(
              icon: Icons.delete_outline,
              tooltip: 'Hapus',
              size: 40,
              iconSize: 19,
              backgroundColor: palette.coral,
              onPressed: () => _delete(credential),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          NeobrutalContainer(
            backgroundColor: color,
            padding: const EdgeInsets.all(18),
            borderRadius: 16,
            child: Row(
              children: <Widget>[
                NeobrutalContainer(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(13),
                  borderRadius: 12,
                  shadowOffset: const Offset(3, 3),
                  child: Text(
                    credential.primaryInitial,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        credential.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              CategoryStyle.iconFor(credential.category),
                              size: 13,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              credential.category.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          NeobrutalContainer(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'USERNAME / EMAIL',
                  value: credential.username.isEmpty
                      ? 'Belum diisi'
                      : credential.username,
                  trailing: credential.username.isEmpty
                      ? null
                      : NeobrutalIconButton(
                          icon: Icons.copy_outlined,
                          tooltip: 'Salin username',
                          size: 36,
                          iconSize: 17,
                          onPressed: () =>
                              _copy('Username', credential.username),
                        ),
                ),
                const Divider(height: 2),
                _InfoRow(
                  icon: Icons.key_outlined,
                  label: 'PASSWORD',
                  value: _revealPassword
                      ? credential.password
                      : List.filled(
                          credential.password.length.clamp(8, 16).toInt(),
                          '•',
                        ).join(),
                  monospace: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      NeobrutalIconButton(
                        icon: _revealPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        tooltip: _revealPassword
                            ? 'Sembunyikan'
                            : 'Tampilkan',
                        size: 36,
                        iconSize: 17,
                        onPressed: () => setState(
                          () => _revealPassword = !_revealPassword,
                        ),
                      ),
                      const SizedBox(width: 6),
                      NeobrutalIconButton(
                        icon: Icons.copy_outlined,
                        tooltip: 'Salin password',
                        size: 36,
                        iconSize: 17,
                        backgroundColor: palette.cyan,
                        onPressed: () =>
                            _copy('Password', credential.password),
                      ),
                    ],
                  ),
                ),
                if (credential.url.isNotEmpty) ...<Widget>[
                  const Divider(height: 2),
                  _InfoRow(
                    icon: Icons.link,
                    label: 'URL / SITUS WEB',
                    value: credential.url,
                    onTap: () => _openUrl(credential.url),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        NeobrutalIconButton(
                          icon: Icons.open_in_new,
                          tooltip: 'Buka URL',
                          size: 36,
                          iconSize: 17,
                          onPressed: () => _openUrl(credential.url),
                        ),
                        const SizedBox(width: 6),
                        NeobrutalIconButton(
                          icon: Icons.copy_outlined,
                          tooltip: 'Salin URL',
                          size: 36,
                          iconSize: 17,
                          onPressed: () => _copy('URL', credential.url),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (credential.tags.isNotEmpty) ...<Widget>[
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: credential.tags.map((tag) {
                return Chip(
                  avatar: const Icon(Icons.sell_outlined, size: 16),
                  label: Text(tag.toUpperCase()),
                );
              }).toList(),
            ),
          ],
          if (credential.notes.isNotEmpty) ...<Widget>[
            const SizedBox(height: 18),
            NeobrutalContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'CATATAN',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(credential.notes),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          Row(
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
                'RIWAYAT PASSWORD (${credential.history.length})',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (credential.history.isEmpty)
            NeobrutalContainer(
              child: Text(
                'Belum ada perubahan password yang tercatat.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            )
          else
            NeobrutalContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  for (var i = 0; i < credential.history.length; i++)
                    ...<Widget>[
                      _HistoryTile(
                        entry: credential.history[i],
                        dateFormat: _dateFormat,
                        onCopy: () => _copy(
                          'Password lama',
                          credential.history[i].password,
                        ),
                      ),
                      if (i != credential.history.length - 1)
                        const Divider(height: 2),
                    ],
                ],
              ),
            ),
          const SizedBox(height: 22),
          Text(
            'Terakhir diperbarui '
            '${_dateFormat.format(credential.updatedAt.toLocal())}',
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.monospace = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final bool monospace;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = NeoPalette.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: palette.purple),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: monospace ? 'JetBrainsMono' : null,
                      fontWeight: monospace ? FontWeight.w700 : null,
                      letterSpacing: monospace ? 1.2 : null,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatefulWidget {
  const _HistoryTile({
    required this.entry,
    required this.dateFormat,
    required this.onCopy,
  });

  final PasswordHistoryEntry entry;
  final DateFormat dateFormat;
  final VoidCallback onCopy;

  @override
  State<_HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<_HistoryTile> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = NeoPalette.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: <Widget>[
          Icon(Icons.history_toggle_off, color: palette.purple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _revealed
                      ? widget.entry.password
                      : List.filled(
                          widget.entry.password.length
                              .clamp(8, 16)
                              .toInt(),
                          '•',
                        ).join(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.dateFormat.format(
                    widget.entry.changedAt.toLocal(),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          NeobrutalIconButton(
            icon: _revealed
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            tooltip: _revealed ? 'Sembunyikan' : 'Tampilkan',
            size: 34,
            iconSize: 16,
            onPressed: () => setState(() => _revealed = !_revealed),
          ),
          const SizedBox(width: 6),
          NeobrutalIconButton(
            icon: Icons.copy_outlined,
            tooltip: 'Salin password lama',
            size: 34,
            iconSize: 16,
            onPressed: widget.onCopy,
          ),
        ],
      ),
    );
  }
}
