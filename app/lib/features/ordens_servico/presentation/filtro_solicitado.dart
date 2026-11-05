import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/filtro_status.dart';

/// Um filtro pedido por outra tela (ex.: tocar em "Prontas p/ retirar"
/// na Início). A lista de OS aplica o filtro e limpa o pedido.
class FiltroSolicitado extends Notifier<FiltroStatus?> {
  @override
  FiltroStatus? build() => null;

  void pedir(FiltroStatus filtro) => state = filtro;

  void limpar() => state = null;
}

final filtroOsSolicitadoProvider =
    NotifierProvider<FiltroSolicitado, FiltroStatus?>(FiltroSolicitado.new);
