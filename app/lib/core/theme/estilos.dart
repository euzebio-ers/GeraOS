import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Estilos de texto do GeraOS que não fazem parte do tema padrão.
extension EstilosDoTema on BuildContext {
  /// Número e data da OS: "#0128 · hoje 14:32".
  TextStyle get estiloNumeroOs => TextStyle(
    fontFamily: Fontes.mono,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Theme.of(this).colorScheme.onSurfaceVariant,
  );
}
