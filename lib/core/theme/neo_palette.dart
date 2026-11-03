import 'package:flutter/material.dart';

class NeoPalette {
  const NeoPalette({
    required this.canvas,
    required this.card,
    required this.muted,
    required this.border,
    required this.shadow,
    required this.textPrimary,
    required this.textSecondary,
    required this.yellow,
    required this.purple,
    required this.mint,
    required this.coral,
    required this.cyan,
  });

  final Color canvas;
  final Color card;
  final Color muted;
  final Color border;
  final Color shadow;
  final Color textPrimary;
  final Color textSecondary;
  final Color yellow;
  final Color purple;
  final Color mint;
  final Color coral;
  final Color cyan;

  static const NeoPalette light = NeoPalette(
    canvas: Color(0xFFF4F0EA),
    card: Color(0xFFFFFFFF),
    muted: Color(0xFFE7E2D9),
    border: Color(0xFF000000),
    shadow: Color(0xFF000000),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF71717A),
    yellow: Color(0xFFFFE600),
    purple: Color(0xFF8B5CF6),
    mint: Color(0xFF00F5A0),
    coral: Color(0xFFFF4757),
    cyan: Color(0xFF00D2FF),
  );

  static const NeoPalette dark = NeoPalette(
    canvas: Color(0xFF18181B),
    card: Color(0xFF27272A),
    muted: Color(0xFF3F3F46),
    border: Color(0xFFF4F0EA),
    shadow: Color(0xFF000000),
    textPrimary: Color(0xFFF4F0EA),
    textSecondary: Color(0xFFA1A1AA),
    yellow: Color(0xFFFFE600),
    purple: Color(0xFF8B5CF6),
    mint: Color(0xFF00F5A0),
    coral: Color(0xFFFF4757),
    cyan: Color(0xFF00D2FF),
  );

  static NeoPalette of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}
