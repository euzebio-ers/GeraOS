/// Larguras que mudam a organização das telas, seguindo as
/// "window size classes" do Material Design 3.
abstract final class Larguras {
  /// A partir daqui, a barra de abas embaixo vira um menu lateral.
  static const menuLateral = 840.0;

  /// A partir daqui, o menu lateral mostra os nomes ao lado dos ícones.
  static const menuExpandido = 1200.0;

  /// Largura máxima de leitura do conteúdo (Início, detalhe, formulários).
  static const conteudo = 720.0;

  /// Largura da área de conteúdo a partir da qual uma lista e o detalhe
  /// do item selecionado aparecem lado a lado.
  static const listaEDetalhe = 860.0;

  /// Largura da coluna da lista, quando ela divide a tela com o detalhe.
  static const colunaLista = 380.0;
}
