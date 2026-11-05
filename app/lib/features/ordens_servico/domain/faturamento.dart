/// Faturamento de um mês: o total das OS entregues.
class Faturamento {
  const Faturamento({
    required this.mes,
    required this.total,
    required this.quantidade,
  });

  factory Faturamento.deJson(Map<String, dynamic> json) => Faturamento(
    mes: DateTime.parse(json['mes'] as String),
    total: (json['total'] as num).toDouble(),
    quantidade: (json['quantidade'] as num).toInt(),
  );

  /// O primeiro dia do mês.
  final DateTime mes;
  final double total;
  final int quantidade;
}
