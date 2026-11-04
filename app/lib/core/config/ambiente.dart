/// Configuração recebida na hora de rodar o app via
/// `--dart-define-from-file=env/<ambiente>.json`.
abstract final class Ambiente {
  static const nome = String.fromEnvironment(
    'AMBIENTE',
    defaultValue: 'desconhecido',
  );
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Endereço que abre o app no celular quando um link de e-mail é tocado.
  static const deepLinkAutenticacao =
      'io.github.euzebioers.geraos://login-callback';

  static bool get ehProducao => nome == 'producao';

  /// Falha cedo, com uma mensagem clara, se a configuração não foi passada.
  static void validar() {
    if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
      throw StateError(
        'Configuração de ambiente ausente. '
        'Rode com: --dart-define-from-file=env/local.json',
      );
    }
  }
}
