import 'package:supabase_flutter/supabase_flutter.dart';

/// Erro ao alterar uma OS, já em português para exibir ao usuário.
class FalhaOs implements Exception {
  const FalhaOs(this.mensagem);

  final String mensagem;

  factory FalhaOs.de(PostgrestException erro) => switch (erro.code) {
    // Regras de negócio das nossas funções: a mensagem já vem em
    // português ("Informe o motivo do cancelamento", "Transição de
    // status não permitida...", "Apenas administradores...").
    'P0001' || 'P0002' => FalhaOs(erro.message),
    '42501' when erro.message.contains('row-level security') => const FalhaOs(
      'Esta OS não pode mais ser alterada.',
    ),
    '42501' => FalhaOs(erro.message),
    _ => const FalhaOs('Não foi possível salvar. Tente novamente.'),
  };

  @override
  String toString() => mensagem;
}
