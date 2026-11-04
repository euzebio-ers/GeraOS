/// Cliente com todos os dados, usado no formulário.
class Cliente {
  const Cliente({
    this.id,
    required this.nome,
    this.telefone,
    this.email,
    this.documento,
    this.observacoes,
  });

  factory Cliente.deJson(Map<String, dynamic> json) => Cliente(
    id: json['id'] as String,
    nome: json['nome'] as String,
    telefone: json['telefone'] as String?,
    email: json['email'] as String?,
    documento: json['documento'] as String?,
    observacoes: json['observacoes'] as String?,
  );

  /// `null` enquanto o cliente ainda não foi salvo.
  final String? id;
  final String nome;

  /// No formato do banco: "+5571992341180".
  final String? telefone;
  final String? email;

  /// Só números: CPF (11) ou CNPJ (14).
  final String? documento;
  final String? observacoes;

  /// Campos que o app grava. O id e a organização ficam a cargo do banco.
  Map<String, dynamic> paraJson() => {
    'nome': nome,
    'telefone': telefone,
    'email': email,
    'documento': documento,
    'observacoes': observacoes,
  };
}
