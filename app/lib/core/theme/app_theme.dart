import 'package:flutter/material.dart';

import 'cores_geraos.dart';

/// Nomes das famílias de fonte declaradas no pubspec.yaml.
abstract final class Fontes {
  static const texto = 'Manrope';
  static const mono = 'JetBrainsMono';
}

/// Tema visual do GeraOS, com as cores e formas do protótipo.
abstract final class AppTheme {
  static ThemeData claro() => _montar(
    const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF0B7A62),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFDCE7E2),
      onPrimaryContainer: Color(0xFF0B5C4A),
      secondary: Color(0xFF0B7A62),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFDCE7E2),
      onSecondaryContainer: Color(0xFF0B5C4A),
      tertiary: Color(0xFFC2410C),
      onTertiary: Color(0xFFFFFFFF),
      error: Color(0xFFB3261E),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFF4F5F2),
      onSurface: Color(0xFF16191B),
      onSurfaceVariant: Color(0xFF5B6166),
      outline: Color(0xFFCDD1CC),
      outlineVariant: Color(0xFFE2E4E0),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFFFFFFF),
      surfaceContainer: Color(0xFFFFFFFF),
      surfaceContainerHigh: Color(0xFFECEDEB),
      surfaceContainerHighest: Color(0xFFE2E4E0),
    ),
    CoresGeraOs.claro,
  );

  static ThemeData escuro() => _montar(
    const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF3CC9A3),
      onPrimary: Color(0xFF0F1214),
      primaryContainer: Color(0xFF1E3A31),
      onPrimaryContainer: Color(0xFF7FE0C3),
      secondary: Color(0xFF3CC9A3),
      onSecondary: Color(0xFF0F1214),
      secondaryContainer: Color(0xFF1E3A31),
      onSecondaryContainer: Color(0xFF7FE0C3),
      tertiary: Color(0xFFE0602A),
      onTertiary: Color(0xFFFFFFFF),
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      surface: Color(0xFF0F1214),
      onSurface: Color(0xFFECEFEC),
      onSurfaceVariant: Color(0xFFA3AAAE),
      outline: Color(0xFF3A4146),
      outlineVariant: Color(0xFF2A3034),
      surfaceContainerLowest: Color(0xFF181C1F),
      surfaceContainerLow: Color(0xFF181C1F),
      surfaceContainer: Color(0xFF181C1F),
      surfaceContainerHigh: Color(0xFF1C2124),
      surfaceContainerHighest: Color(0xFF2A3034),
    ),
    CoresGeraOs.escuro,
  );

  static ThemeData _montar(ColorScheme cores, CoresGeraOs coresGeraOs) {
    final base = ThemeData(
      colorScheme: cores,
      fontFamily: Fontes.texto,
      scaffoldBackgroundColor: cores.surface,
    );
    final textos = base.textTheme;
    final cantos12 = BorderRadius.circular(12);
    final cantos14 = BorderRadius.circular(14);

    return base.copyWith(
      extensions: [coresGeraOs],
      textTheme: textos.copyWith(
        headlineMedium: textos.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        headlineSmall: textos.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        titleLarge: textos.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: textos.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        titleSmall: textos.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        labelLarge: textos.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cores.surface,
        foregroundColor: cores.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: Fontes.texto,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: cores.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cores.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: cantos12,
          borderSide: BorderSide(color: cores.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: cantos12,
          borderSide: BorderSide(color: cores.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: cantos12,
          borderSide: BorderSide(color: cores.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: cantos14),
          textStyle: const TextStyle(
            fontFamily: Fontes.texto,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: cores.surfaceContainerLowest,
          foregroundColor: cores.onSurface,
          side: BorderSide(color: cores.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: cantos14),
          textStyle: const TextStyle(
            fontFamily: Fontes.texto,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: cores.primary,
          textStyle: const TextStyle(
            fontFamily: Fontes.texto,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cores.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cores.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(color: cores.outlineVariant, space: 1),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: cores.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: cores.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((estados) {
          final selecionada = estados.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: Fontes.texto,
            fontSize: 12,
            fontWeight: selecionada ? FontWeight.w800 : FontWeight.w600,
            color: selecionada ? cores.primary : cores.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((estados) {
          final selecionada = estados.contains(WidgetState.selected);
          return IconThemeData(
            color: selecionada
                ? cores.onPrimaryContainer
                : cores.onSurfaceVariant,
          );
        }),
      ),
    );
  }
}
