/// Um item da OS a ser incluído (sem `id`) ou alterado (com `id`).
class DadosItem {
  const DadosItem({
    this.id,
    required this.tipo,
    required this.descricao,
    required this.quantidade,
    required this.valorUnitario,
  });

  final String? id;

  /// "servico" ou "peca".
  final String tipo;
  final String descricao;
  final double quantidade;
  final double valorUnitario;

  /// Colunas que o app grava. A OS e a organização não mudam.
  Map<String, dynamic> paraJson() => {
    'tipo': tipo,
    'descricao': descricao,
    'quantidade': quantidade,
    'valor_unitario': valorUnitario,
  };
}
