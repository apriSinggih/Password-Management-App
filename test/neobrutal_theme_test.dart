import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/core/theme/app_theme.dart';
import 'package:secure_vault/core/theme/neo_palette.dart';
import 'package:secure_vault/core/widgets/neobrutal.dart';

void main() {
  testWidgets('neobrutal controls use readable colors on dark surfaces', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Column(
            children: <Widget>[
              NeobrutalIconButton(icon: Icons.settings, onPressed: () {}),
              NeobrutalButton(
                icon: Icons.fingerprint,
                label: 'Biometrik',
                backgroundColor: NeoPalette.dark.card,
                onPressed: () {},
              ),
              NeobrutalIconButton(
                icon: Icons.delete,
                backgroundColor: NeoPalette.dark.coral,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.widget<Icon>(find.byIcon(Icons.settings)).color,
      NeoPalette.dark.textPrimary,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.fingerprint)).color,
      NeoPalette.dark.textPrimary,
    );
    expect(tester.widget<Icon>(find.byIcon(Icons.delete)).color, Colors.black);
  });
}
