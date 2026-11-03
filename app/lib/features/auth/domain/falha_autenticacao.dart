import 'package:supabase_flutter/supabase_flutter.dart';

/// Erro de autenticação já traduzido para exibir ao usuário.
class FalhaAutenticacao implements Exception {
  const FalhaAutenticacao(this.mensagem);

  final String mensagem;

  factory FalhaAutenticacao.de(AuthException erro) {
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
      'over_request_rate_limit' ||
      'over_email_send_rate_limit' => const FalhaAutenticacao(
        'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
      ),
      _ => const FalhaAutenticacao('Não foi possível entrar. Tente novamente.'),
    };
  }

  @override
  String toString() => mensagem;
}
