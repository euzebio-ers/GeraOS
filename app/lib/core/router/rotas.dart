/// Endereços das telas do app.
abstract final class Rotas {
  static const login = '/login';
  static const cadastro = '/cadastro';
  static const ordensServico = '/os';
  static const configuracoes = '/configuracoes';

  /// Telas acessíveis sem login.
  static const publicas = {login, cadastro};
}
