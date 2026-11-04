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

  /// Nome mais preciso, usado no histórico e na mudança de status,
  /// onde "Pendente → Pendente" (aberta → em análise) não diria nada.
  String get rotuloDetalhado => switch (this) {
    StatusOs.aberta => 'Aberta',
    StatusOs.emAnalise => 'Em análise',
    _ => rotulo,
  };

  /// Para onde a OS pode ir a partir deste status (RN007).
  ///
  /// É a mesma regra da função `transicao_status_valida` do banco, que
  /// continua sendo quem decide. A reabertura de uma OS entregue
  /// (volta para "em análise") é exclusiva de administradores e é
  /// tratada à parte, por isso não aparece aqui.
  List<StatusOs> get proximos => switch (this) {
    StatusOs.aberta => const [StatusOs.emAnalise, StatusOs.cancelada],
    StatusOs.emAnalise => const [
      StatusOs.aguardandoAprovacao,
      StatusOs.emAndamento,
      StatusOs.cancelada,
    ],
    StatusOs.aguardandoAprovacao => const [
      StatusOs.emAndamento,
      StatusOs.cancelada,
    ],
    StatusOs.emAndamento => const [StatusOs.pronta, StatusOs.cancelada],
    StatusOs.pronta => const [StatusOs.entregue],
    StatusOs.entregue => const [],
    StatusOs.cancelada => const [],
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
