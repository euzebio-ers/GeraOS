import 'status_os.dart';

/// Filtros da lista de OS, com os nomes que aparecem na tela.
enum FiltroStatus {
  todas('Todas', []),
  pendente('Pendente', [StatusOs.aberta, StatusOs.emAnalise]),
  aguardandoAprovacao('Aguardando aprovação', [StatusOs.aguardandoAprovacao]),
  emAndamento('Em andamento', [StatusOs.emAndamento]),
  pronta('Pronta p/ retirar', [StatusOs.pronta]),
  concluida('Concluída', [StatusOs.entregue]),
  cancelada('Cancelada', [StatusOs.cancelada]);

  const FiltroStatus(this.rotulo, this.status);

  final String rotulo;

  /// Status do banco que entram neste filtro (vazio em "Todas").
  final List<StatusOs> status;

  /// Quantas OS entram neste filtro, a partir da contagem por status.
  int contar(Map<StatusOs, int> contagem) {
    if (this == FiltroStatus.todas) {
      return contagem.values.fold(0, (total, quantidade) => total + quantidade);
    }
    return status.fold(0, (total, item) => total + (contagem[item] ?? 0));
  }
}
