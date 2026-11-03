import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences/preferencias.dart';

/// Tema escolhido pelo usuário: claro, escuro ou o do sistema.
final temaProvider = NotifierProvider<TemaController, ThemeMode>(TemaController.new);

class TemaController extends Notifier<ThemeMode> {
  static const _chave = 'tema';

  @override
  ThemeMode build() {
    final salvo = ref.watch(preferenciasProvider).getString(_chave);
    return ThemeMode.values.firstWhere(
      (modo) => modo.name == salvo,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> alterar(ThemeMode modo) async {
    state = modo;
    await ref.read(preferenciasProvider).setString(_chave, modo.name);
  }
}