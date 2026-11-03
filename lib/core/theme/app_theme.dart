import 'package:flutter/material.dart';

import 'neo_palette.dart';

class AppTheme {
  static ThemeData get light => _build(NeoPalette.light, Brightness.light);

  static ThemeData get dark => _build(NeoPalette.dark, Brightness.dark);

  static ThemeData _build(NeoPalette palette, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Lexend',
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: palette.purple,
      brightness: brightness,
    ).copyWith(
      primary: palette.yellow,
      onPrimary: Colors.black,
      primaryContainer: palette.yellow,
      onPrimaryContainer: Colors.black,
      secondary: palette.purple,
      onSecondary: Colors.white,
      secondaryContainer: palette.purple,
      onSecondaryContainer: Colors.white,
      tertiary: palette.cyan,
      onTertiary: Colors.black,
      error: palette.coral,
      onError: Colors.black,
      surface: palette.canvas,
      onSurface: palette.textPrimary,
      surfaceContainerLow: palette.card,
      surfaceContainer: palette.card,
      surfaceContainerHigh: palette.muted,
      surfaceContainerHighest: palette.muted,
      onSurfaceVariant: palette.textSecondary,
      outline: palette.border,
      outlineVariant: palette.border,
      shadow: palette.shadow,
      scrim: Colors.black,
    );

    final textTheme = base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
        fontSize: 40,
        height: 1.1,
        fontWeight: FontWeight.w900,
        letterSpacing: -1,
      ),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.4,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: base.textTheme.titleSmall?.copyWith(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.45,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontSize: 15,
        height: 1.3,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
      labelMedium: base.textTheme.labelMedium?.copyWith(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
      labelSmall: base.textTheme.labelSmall?.copyWith(
        fontSize: 11,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: palette.border, width: 3),
    );

    return base.copyWith(
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: palette.canvas,
      canvasColor: palette.canvas,
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 2,
        space: 2,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.canvas,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
        iconTheme: IconThemeData(color: palette.textPrimary),
        actionsIconTheme: IconThemeData(color: palette.textPrimary),
        shape: Border(
          bottom: BorderSide(color: palette.border, width: 3),
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.border, width: 3),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: palette.textSecondary, width: 3),
        ),
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: palette.purple, width: 3),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: palette.coral, width: 3),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: palette.coral, width: 3),
        ),
        labelStyle: TextStyle(
          color: palette.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        floatingLabelStyle: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.w800,
        ),
        hintStyle: TextStyle(
          color: palette.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        helperStyle: TextStyle(
          color: palette.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: palette.textPrimary,
        suffixIconColor: palette.textPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.yellow,
          foregroundColor: Colors.black,
          disabledBackgroundColor: palette.muted,
          disabledForegroundColor: palette.textSecondary,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: palette.border, width: 3),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          backgroundColor: palette.card,
          side: BorderSide(color: palette.border, width: 3),
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.textPrimary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: palette.textPrimary,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.card,
        selectedColor: palette.yellow,
        secondarySelectedColor: palette.yellow,
        disabledColor: palette.muted,
        surfaceTintColor: Colors.transparent,
        side: BorderSide(color: palette.border, width: 2.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: palette.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w800,
        ),
        checkmarkColor: Colors.black,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 74,
        indicatorColor: palette.yellow,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: palette.border, width: 2.5),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(
          textTheme.labelSmall!.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
          states,
        ) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? Colors.black : palette.textSecondary,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        shadowColor: palette.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.border, width: 3),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: palette.textPrimary,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: palette.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: palette.border, width: 2),
        ),
        insetPadding: const EdgeInsets.all(16),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          return states.contains(WidgetState.selected)
              ? Colors.black
              : palette.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          return states.contains(WidgetState.selected)
              ? palette.mint
              : palette.muted;
        }),
        trackOutlineColor: WidgetStatePropertyAll<Color>(palette.border),
        trackOutlineWidth: const WidgetStatePropertyAll<double>(2.5),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.yellow,
        inactiveTrackColor: palette.muted,
        thumbColor: palette.yellow,
        overlayColor: Colors.transparent,
        trackHeight: 8,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.purple,
        linearTrackColor: palette.muted,
        circularTrackColor: palette.muted,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          return states.contains(WidgetState.selected)
              ? palette.yellow
              : palette.card;
        }),
        checkColor: const WidgetStatePropertyAll<Color>(Colors.black),
        side: BorderSide(color: palette.border, width: 2.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          return states.contains(WidgetState.selected)
              ? palette.yellow
              : palette.card;
        }),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.textPrimary,
        textColor: palette.textPrimary,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: palette.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.card,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: palette.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: palette.border, width: 2),
        ),
        textStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
