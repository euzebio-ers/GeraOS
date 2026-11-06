/// Endereços das telas do app.
abstract final class Rotas {
  static const raiz = '/';

  // Entrada
  static const login = '/login';
  static const cadastro = '/cadastro';
  static const recuperarSenha = '/recuperar-senha';
  static const novaSenha = '/nova-senha';
  static const preparando = '/preparando';
  static const configurarOrganizacao = '/empresa/nova';

  // Abas
  static const inicio = '/inicio';
  static const ordensServico = '/os';
  static const clientes = '/clientes';
  static const mais = '/mais';

  // Dentro das abas, abertas em tela cheia
  static const novaOs = '/os/nova';
  static String os(String id) => '/os/$id';
  static String pdfOs(String id) => '/os/$id/pdf';
  static String osNaLista(String id) =>
      Uri(path: ordensServico, queryParameters: {'os': id}).toString();
  static const novoCliente = '/clientes/novo';
  static const dadosEmpresa = '/mais/empresa';
  static String cliente(String id) => '/clientes/$id';

  // Por cima das abas
  static const gravarOs = '/gravar';

  /// Para onde a pessoa vai depois de entrar no app.
  static const paginaInicial = inicio;

  /// Telas acessíveis sem login.
  static const publicas = {login, cadastro, recuperarSenha};

  /// Telas do caminho entre o login e o app pronto para uso.
  static const entrada = {preparando, configurarOrganizacao};
}
