import 'status_os.dart';

/// Uma OS na lista. Vem da view `ordens_servico_resumo`.
class OsResumo {
  const OsResumo({
    required this.id,
    required this.numero,
    required this.status,
    required this.equipamento,
    required this.clienteNome,
    required this.criadoEm,
    this.clienteId,
    this.valorTotal = 0,
    this.quantidadeItens = 0,
  });

  factory OsResumo.deJson(Map<String, dynamic> json) => OsResumo(
    id: json['id'] as String,
    numero: (json['numero'] as num).toInt(),
    status: StatusOs.doBanco(json['status'] as String),
    equipamento: json['equipamento'] as String,
    clienteId: json['cliente_id'] as String?,
    clienteNome: json['cliente_nome'] as String,
    criadoEm: DateTime.parse(json['criado_em'] as String),
    valorTotal: (json['valor_total'] as num?)?.toDouble() ?? 0,
    quantidadeItens: (json['quantidade_itens'] as num?)?.toInt() ?? 0,
  );

  final String id;
  final int numero;
  final StatusOs status;
  final String equipamento;
  final String? clienteId;
  final String clienteNome;
  final DateTime criadoEm;
  final double valorTotal;
  final int quantidadeItens;

  /// Sem nenhum item ainda: o cartão mostra "a orçar" em vez de "R$ 0,00".
  bool get aOrcar => quantidadeItens == 0;
}
