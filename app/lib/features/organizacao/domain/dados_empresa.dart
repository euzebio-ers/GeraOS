/// Dados da empresa que aparecem na OS impressa (RF006).
class DadosEmpresa {
  const DadosEmpresa({
    required this.nome,
    this.documento,
    this.telefone,
    this.email,
    this.endereco,
    this.termosGarantia,
  });

  factory DadosEmpresa.deJson(Map<String, dynamic> json) => DadosEmpresa(
    nome: json['nome'] as String,
    documento: json['documento'] as String?,
    telefone: json['telefone'] as String?,
    email: json['email'] as String?,
    endereco: json['endereco'] as String?,
    termosGarantia: json['termos_garantia'] as String?,
  );

  final String nome;

  /// Só números: CPF (11) ou CNPJ (14).
  final String? documento;

  /// No formato do banco: "+557132341180".
  final String? telefone;
  final String? email;
  final String? endereco;
  final String? termosGarantia;

  /// Campos que o app grava. Os vazios vão como `null`, apagando o valor.
  Map<String, dynamic> paraJson() => {
    'nome': nome,
    'documento': documento,
    'telefone': telefone,
    'email': email,
    'endereco': endereco,
    'termos_garantia': termosGarantia,
  };
}
