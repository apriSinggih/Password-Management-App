import 'package:flutter/material.dart';

import '../theme/neo_palette.dart';
import '../utils/password_generator.dart';

class StrengthMeter extends StatelessWidget {
  const StrengthMeter({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final strength = PasswordGenerator.analyze(password);
    final palette = NeoPalette.of(context);
    final color = switch (strength.score) {
      0 || 1 => palette.coral,
      2 => palette.yellow,
      _ => palette.mint,
    };
    final activeSegments = strength.score + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: List<Widget>.generate(5, (index) {
            return Expanded(
              child: Container(
                height: 10,
                margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                decoration: BoxDecoration(
                  color: index < activeSegments ? color : palette.muted,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: palette.border,
                    width: 1.5,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              strength.label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color == palette.yellow
                    ? palette.textPrimary
                    : color,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '${strength.entropyBits.toStringAsFixed(0)} BIT',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: palette.textSecondary,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
