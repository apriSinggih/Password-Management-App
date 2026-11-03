import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/neo_palette.dart';
import 'core/widgets/neobrutal.dart';
import 'features/auth/presentation/lock_screen.dart';
import 'features/auth/presentation/setup_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/vault/presentation/generator_screen.dart';
import 'features/vault/presentation/vault_home_screen.dart';

class SecureVaultApp extends StatelessWidget {
  const SecureVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const _AppGate(),
    );
  }
}

class _AppGate extends StatelessWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthProvider, AuthStatus>(
      (auth) => auth.status,
    );

    switch (status) {
      case AuthStatus.initializing:
        final palette = NeoPalette.of(context);
        return Scaffold(
          body: Center(
            child: NeobrutalContainer(
              backgroundColor: palette.yellow,
              padding: const EdgeInsets.all(22),
              child: const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      case AuthStatus.needsSetup:
        return const SetupScreen();
      case AuthStatus.locked:
        return const LockScreen();
      case AuthStatus.unlocked:
        return const MainShell();
    }
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _index = 0;
  Timer? _inactivityTimer;
  DateTime? _backgroundedAt;
  late final AuthProvider _auth;
  late int _timeoutSeconds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auth = context.read<AuthProvider>();
    _timeoutSeconds = _auth.autoLockSeconds;
    _auth.addListener(_handleAuthChange);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    _scheduleInactivityLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _auth.removeListener(_handleAuthChange);
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _handleAuthChange() {
    if (!mounted) return;
    if (_auth.autoLockSeconds != _timeoutSeconds) {
      _timeoutSeconds = _auth.autoLockSeconds;
      _scheduleInactivityLock();
    }
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) _onUserInteraction();
    return false;
  }

  void _scheduleInactivityLock() {
    _inactivityTimer?.cancel();
    if (!_auth.isUnlocked || _timeoutSeconds <= 0) return;
    _inactivityTimer = Timer(Duration(seconds: _timeoutSeconds), () {
      if (mounted && _auth.isUnlocked) _auth.lock();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundedAt ??= DateTime.now();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      final backgroundedAt = _backgroundedAt;
      _backgroundedAt = null;
      if (backgroundedAt != null && _auth.isUnlocked) {
        final elapsed = DateTime.now().difference(backgroundedAt).inSeconds;
        if (_timeoutSeconds == 0 || elapsed >= _timeoutSeconds) {
          _auth.lock();
          return;
        }
      }
      _scheduleInactivityLock();
    }
  }

  void _onUserInteraction() {
    if (_auth.isUnlocked) _scheduleInactivityLock();
  }

  @override
  Widget build(BuildContext context) {
    final palette = NeoPalette.of(context);

    return Scaffold(
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _onUserInteraction(),
        child: IndexedStack(
          index: _index,
          children: const <Widget>[
            VaultHomeScreen(),
            GeneratorScreen(),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: palette.canvas,
          border: Border(
            top: BorderSide(color: palette.border, width: 3),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: 'BRANKAS',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'GENERATOR',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'PENGATURAN',
            ),
          ],
        ),
      ),
    );
  }
}
