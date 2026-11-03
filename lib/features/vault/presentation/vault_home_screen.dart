import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/categories.dart';
import '../../../core/theme/neo_palette.dart';
import '../../../core/widgets/neobrutal.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/credential.dart';
import '../providers/vault_provider.dart';
import 'credential_detail_screen.dart';
import 'credential_edit_screen.dart';
import 'widgets/category_style.dart';
import 'widgets/credential_tile.dart';

class VaultHomeScreen extends StatefulWidget {
  const VaultHomeScreen({super.key});

  @override
  State<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends State<VaultHomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<VaultProvider>().search,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openEditor([Credential? credential]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CredentialEditScreen(credential: credential),
      ),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          credential == null
              ? 'Kredensial berhasil ditambahkan'
              : 'Perubahan berhasil disimpan',
        ),
      ),
    );
  }

  void _openDetail(Credential credential) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CredentialDetailScreen(credentialId: credential.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultProvider>();
    final auth = context.read<AuthProvider>();
    final theme = Theme.of(context);
    final palette = NeoPalette.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BRANKAS'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: NeobrutalIconButton(
              icon: Icons.lock_outline,
              tooltip: 'Kunci brankas',
              size: 40,
              iconSize: 19,
              onPressed: auth.lock,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(118),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: vault.setSearch,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Cari nama, username, atau tag...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: vault.search.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Hapus pencarian',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              vault.setSearch('');
                            },
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: vault.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = vault.categories[index];
                    final selected = vault.selectedCategory == category;
                    final count = vault.countForCategory(category);
                    return FilterChip(
                      selected: selected,
                      label: Text('$category ($count)'),
                      avatar: category == VaultCategories.all
                          ? null
                          : Icon(
                              CategoryStyle.iconFor(category),
                              size: 17,
                              color: selected
                                  ? Colors.black
                                  : palette.textPrimary,
                            ),
                      onSelected: (_) => vault.setCategory(category),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(vault, theme, palette),
      floatingActionButton: NeobrutalButton(
        expand: false,
        height: 50,
        onPressed: () => _openEditor(),
        icon: Icons.add,
        label: 'Tambah',
      ),
    );
  }

  Widget _buildBody(
    VaultProvider vault,
    ThemeData theme,
    NeoPalette palette,
  ) {
    if (vault.isLoading && vault.credentials.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 3));
    }

    if (vault.error != null && vault.credentials.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: NeobrutalContainer(
            backgroundColor: palette.coral,
            child: Text(
              vault.error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    final items = vault.filteredCredentials;

    if (items.isEmpty) {
      final hasAny = vault.credentials.isNotEmpty;
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              NeobrutalContainer(
                backgroundColor: palette.purple,
                padding: const EdgeInsets.all(22),
                borderRadius: 16,
                child: Icon(
                  hasAny ? Icons.search_off : Icons.shield_outlined,
                  size: 54,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                hasAny
                    ? 'TIDAK ADA HASIL'
                    : 'BRANKAS MASIH KOSONG',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                hasAny
                    ? 'Coba kata kunci atau kategori lain.'
                    : 'Tambahkan akun pertama Anda dan mulai simpan '
                          'kredensial dengan aman.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: palette.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (!hasAny) ...<Widget>[
                const SizedBox(height: 24),
                NeobrutalButton(
                  expand: false,
                  onPressed: () => _openEditor(),
                  icon: Icons.add,
                  label: 'Tambah Kredensial',
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vault.load,
      color: palette.purple,
      backgroundColor: palette.card,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final credential = items[index];
          return CredentialTile(
            credential: credential,
            onTap: () => _openDetail(credential),
          );
        },
      ),
    );
  }
}
