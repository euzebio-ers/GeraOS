import '../../../core/theme/cores_geraos.dart';

/// Os status de uma OS, iguais ao tipo `status_os` do banco.
enum StatusOs {
  aberta('aberta', 'Pendente'),
  emAnalise('em_analise', 'Pendente'),
  aguardandoAprovacao('aguardando_aprovacao', 'Aguardando aprovação'),
  emAndamento('em_andamento', 'Em andamento'),
  pronta('pronta', 'Pronta p/ retirar'),
  entregue('entregue', 'Concluída'),
  cancelada('cancelada', 'Cancelada');

  const StatusOs(this.valorBanco, this.rotulo);

  /// Como o status é gravado no banco.
  final String valorBanco;

  /// Como o status aparece nas etiquetas e nos filtros.
  final String rotulo;

  /// Nome mais preciso, usado no histórico, onde "Pendente → Pendente"
  /// (aberta → em análise) não diria nada.
  String get rotuloDetalhado => switch (this) {
    StatusOs.aberta => 'Aberta',
    StatusOs.emAnalise => 'Em análise',
    _ => rotulo,
  };

  /// Converte o valor vindo do banco.
  static StatusOs doBanco(String valor) => values.firstWhere(
    (status) => status.valorBanco == valor,
    orElse: () => throw ArgumentError('Status de OS desconhecido: $valor'),
  );

  /// Cores da etiqueta, de acordo com o tema atual.
  CorStatus cor(CoresGeraOs cores) => switch (this) {
    StatusOs.aberta || StatusOs.emAnalise => cores.pendente,
    StatusOs.aguardandoAprovacao => cores.aguardandoAprovacao,
    StatusOs.emAndamento => cores.emAndamento,
    StatusOs.pronta => cores.pronta,
    StatusOs.entregue => cores.concluida,
    StatusOs.cancelada => cores.cancelada,
  };
}
