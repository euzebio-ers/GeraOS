/// Endereços das telas do app.
abstract final class Rotas {
  static const login = '/login';
  static const cadastro = '/cadastro';
  static const recuperarSenha = '/recuperar-senha';
  static const preparando = '/preparando';
  static const configurarOrganizacao = '/empresa/nova';
  static const ordensServico = '/os';
  static const configuracoes = '/configuracoes';

  /// Telas acessíveis sem login.
  static const publicas = {login, cadastro, recuperarSenha};

  /// Telas do caminho entre o login e o app pronto para uso.
  static const entrada = {preparando, configurarOrganizacao};
}
