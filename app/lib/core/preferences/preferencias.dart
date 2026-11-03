import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Acesso às preferências salvas no aparelho.
///
/// O valor real é carregado no `main.dart` e injetado com `overrideWithValue`,
/// porque o carregamento é assíncrono e precisa acontecer antes do app abrir.
final preferenciasProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'preferenciasProvider precisa ser sobrescrito no main.dart',
  ),
);