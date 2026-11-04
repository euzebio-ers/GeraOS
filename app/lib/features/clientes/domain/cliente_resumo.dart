/// Um cliente na lista: dados principais e o resumo das OS.
/// Vem da view `clientes_resumo`.
class ClienteResumo {
  const ClienteResumo({
    required this.id,
    required this.nome,
    this.telefone,
    this.email,
    this.quantidadeOs = 0,
    this.ultimaOsEm,
  });

  factory ClienteResumo.deJson(Map<String, dynamic> json) => ClienteResumo(
    id: json['id'] as String,
    nome: json['nome'] as String,
    telefone: json['telefone'] as String?,
    email: json['email'] as String?,
    quantidadeOs: (json['quantidade_os'] as num?)?.toInt() ?? 0,
    ultimaOsEm: json['ultima_os_em'] == null
        ? null
        : DateTime.parse(json['ultima_os_em'] as String),
  );

  final String id;
  final String nome;
  final String? telefone;
  final String? email;
  final int quantidadeOs;
  final DateTime? ultimaOsEm;
}
