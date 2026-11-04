import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Erro de autenticação já traduzido para exibir ao usuário.
class FalhaAutenticacao implements Exception {
  const FalhaAutenticacao(this.mensagem);

  final String mensagem;

  factory FalhaAutenticacao.de(
    AuthException erro, {
    String padrao = 'Não foi possível entrar. Tente novamente.',
  }) {
    if (kDebugMode) {
      debugPrint(
        'FalhaAutenticacao: ${erro.runtimeType} '
        'code=${erro.code} status=${erro.statusCode} mensagem=${erro.message}',
      );
    }

    if (erro is AuthRetryableFetchException) {
      return const FalhaAutenticacao(
        'Sem conexão com o servidor. Verifique sua internet e tente novamente.',
      );
    }

    return switch (erro.code) {
      'invalid_credentials' => const FalhaAutenticacao(
        'E-mail ou senha inválidos.',
      ),
      'email_not_confirmed' => const FalhaAutenticacao(
        'Confirme seu e-mail antes de entrar. Verifique sua caixa de entrada.',
      ),
      'user_already_exists' || 'email_exists' => const FalhaAutenticacao(
        'Não foi possível usar este e-mail. Se você já tem conta, entre ou recupere sua senha.',
      ),
      'weak_password' => const FalhaAutenticacao(
        'Senha fraca. Use pelo menos 8 caracteres, com letras e números.',
      ),
      'same_password' => const FalhaAutenticacao(
        'A nova senha precisa ser diferente da anterior.',
      ),

      'over_request_rate_limit' ||
      'over_email_send_rate_limit' => const FalhaAutenticacao(
        'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
      ),
      _ => FalhaAutenticacao(padrao),
    };
  }

  @override
  String toString() => mensagem;
}
