import 'rotas.dart';

/// Confere um destino guardado no endereço (o parâmetro `de`) antes de usá-lo.
///
/// Só aceita endereços internos do app, como "/os?os=123". Recusa endereços
/// completos ("https://..."), os que começam com "//" (que o navegador lê
/// como outro site) e as telas de entrada, para evitar redirecionamento
/// aberto e voltas sem fim.
String? destinoSeguro(String? valor) {
  if (valor == null || !valor.startsWith('/') || valor.startsWith('//')) {
    return null;
  }

  final caminho = Uri.tryParse(valor)?.path;
  if (caminho == null ||
      caminho == Rotas.raiz ||
      caminho == Rotas.paginaInicial ||
      caminho == Rotas.novaSenha ||
      Rotas.publicas.contains(caminho) ||
      Rotas.entrada.contains(caminho)) {
    return null;
  }
  return valor;
}
