import 'status_os.dart';

/// Um serviço ou peça da OS.
class ItemOs {
  const ItemOs({
    required this.id,
    required this.tipo,
    required this.descricao,
    required this.quantidade,
    required this.valorUnitario,
  });

  factory ItemOs.deJson(Map<String, dynamic> json) => ItemOs(
    id: json['id'] as String,
    tipo: json['tipo'] as String,
    descricao: json['descricao'] as String,
    quantidade: (json['quantidade'] as num).toDouble(),
    valorUnitario: (json['valor_unitario'] as num).toDouble(),
  );

  final String id;

  /// "servico" ou "peca".
  final String tipo;
  final String descricao;
  final double quantidade;
  final double valorUnitario;

  double get total => quantidade * valorUnitario;
}

/// Uma mudança de status no histórico da OS.
class RegistroHistorico {
  const RegistroHistorico({
    required this.statusNovo,
    required this.alteradoEm,
    this.statusAnterior,
    this.observacao,
    this.alteradoPorNome,
  });

  factory RegistroHistorico.deJson(Map<String, dynamic> json) =>
      RegistroHistorico(
        statusAnterior: json['status_anterior'] == null
            ? null
            : StatusOs.doBanco(json['status_anterior'] as String),
        statusNovo: StatusOs.doBanco(json['status_novo'] as String),
        observacao: json['observacao'] as String?,
        alteradoEm: DateTime.parse(json['alterado_em'] as String),
        alteradoPorNome: json['alterado_por_nome'] as String?,
      );

  /// `null` no registro da criação da OS.
  final StatusOs? statusAnterior;
  final StatusOs statusNovo;
  final String? observacao;
  final DateTime alteradoEm;
  final String? alteradoPorNome;
}

/// O cliente, como aparece no detalhe da OS.
class ClienteDaOs {
  const ClienteDaOs({
    required this.id,
    required this.nome,
    this.telefone,
    this.email,
    this.quantidadeOs = 0,
  });

  factory ClienteDaOs.deJson(Map<String, dynamic> json) => ClienteDaOs(
    id: json['id'] as String,
    nome: json['nome'] as String,
    telefone: json['telefone'] as String?,
    email: json['email'] as String?,
    quantidadeOs: (json['quantidade_os'] as num?)?.toInt() ?? 0,
  );

  final String id;
  final String nome;
  final String? telefone;
  final String? email;
  final int quantidadeOs;
}

/// A OS completa, como vem da função `detalhe_os`.
class OsDetalhe {
  const OsDetalhe({
    required this.id,
    required this.numero,
    required this.status,
    required this.equipamento,
    required this.descricaoProblema,
    required this.criadoEm,
    required this.cliente,
    this.diagnostico,
    this.acessorios,
    this.desconto = 0,
    this.valorTotal = 0,
    this.previsaoEntrega,
    this.origem = 'manual',
    this.entregueEm,
    this.criadoPorNome,
    this.itens = const [],
    this.historico = const [],
  });

  factory OsDetalhe.deJson(Map<String, dynamic> json) => OsDetalhe(
    id: json['id'] as String,
    numero: (json['numero'] as num).toInt(),
    status: StatusOs.doBanco(json['status'] as String),
    equipamento: json['equipamento'] as String,
    descricaoProblema: json['descricao_problema'] as String,
    diagnostico: json['diagnostico'] as String?,
    acessorios: json['acessorios'] as String?,
    desconto: (json['desconto'] as num?)?.toDouble() ?? 0,
    valorTotal: (json['valor_total'] as num?)?.toDouble() ?? 0,
    previsaoEntrega: json['previsao_entrega'] == null
        ? null
        : DateTime.parse(json['previsao_entrega'] as String),
    origem: json['origem'] as String? ?? 'manual',
    criadoEm: DateTime.parse(json['criado_em'] as String),
    entregueEm: json['entregue_em'] == null
        ? null
        : DateTime.parse(json['entregue_em'] as String),
    criadoPorNome: json['criado_por_nome'] as String?,
    cliente: ClienteDaOs.deJson(json['cliente'] as Map<String, dynamic>),
    itens: [
      for (final item in json['itens'] as List<dynamic>)
        ItemOs.deJson(item as Map<String, dynamic>),
    ],
    historico: [
      for (final registro in json['historico'] as List<dynamic>)
        RegistroHistorico.deJson(registro as Map<String, dynamic>),
    ],
  );

  final String id;
  final int numero;
  final StatusOs status;
  final String equipamento;
  final String descricaoProblema;
  final String? diagnostico;
  final String? acessorios;
  final double desconto;
  final double valorTotal;
  final DateTime? previsaoEntrega;

  /// "manual" ou "audio".
  final String origem;
  final DateTime criadoEm;
  final DateTime? entregueEm;
  final String? criadoPorNome;
  final ClienteDaOs cliente;
  final List<ItemOs> itens;
  final List<RegistroHistorico> historico;
}
