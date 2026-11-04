/// Dados de uma OS digitada, antes de ser criada.
///
/// O cliente é ou um já cadastrado (`clienteId`) ou um novo
/// (`clienteNome` e contatos), nunca os dois.
class NovaOs {
  const NovaOs({
    required this.equipamento,
    required this.descricaoProblema,
    this.clienteId,
    this.clienteNome,
    this.clienteTelefone,
    this.clienteEmail,
    this.acessorios,
    this.valorEstimado,
  });

  final String equipamento;
  final String descricaoProblema;
  final String? clienteId;
  final String? clienteNome;

  /// No formato do banco: "+5571992341180".
  final String? clienteTelefone;
  final String? clienteEmail;
  final String? acessorios;
  final double? valorEstimado;

  /// Parâmetros da função `criar_os_digitada`. Os vazios ficam de fora
  /// e a função usa o valor padrão de cada um.
  Map<String, dynamic> paraParametros() => {
    'p_equipamento': equipamento,
    'p_descricao_problema': descricaoProblema,
    if (clienteId != null) 'p_cliente_id': clienteId,
    if (clienteNome != null) 'p_cliente_nome': clienteNome,
    if (clienteTelefone != null) 'p_cliente_telefone': clienteTelefone,
    if (clienteEmail != null) 'p_cliente_email': clienteEmail,
    if (acessorios != null) 'p_acessorios': acessorios,
    if (valorEstimado != null) 'p_valor_estimado': valorEstimado,
  };
}
