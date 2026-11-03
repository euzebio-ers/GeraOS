import 'package:flutter/material.dart';

/// Tema visual do GeraOS (Material 3), nas versões clara e escura.
abstract final class AppTheme {
  static const _corPrincipal = Color(0xFF1F4E79);

  static ThemeData claro() =>
      _base(ColorScheme.fromSeed(seedColor: _corPrincipal));

  static ThemeData escuro() => _base(
    ColorScheme.fromSeed(seedColor: _corPrincipal, brightness: Brightness.dark),
  );

  static ThemeData _base(ColorScheme cores) {
    return ThemeData(
      colorScheme: cores,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),
    );
  }
}
