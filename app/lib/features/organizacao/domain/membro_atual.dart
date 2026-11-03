/// A pessoa logada, com sua organização e seu papel.
class MembroAtual {
  const MembroAtual({
    required this.id,
    required this.nome,
    required this.ehAdmin,
    required this.organizacaoId,
    required this.nomeOrganizacao,
  });

  /// Converte a resposta do Supabase (membro + organização) em objeto.
  factory MembroAtual.deJson(Map<String, dynamic> json) {
    final organizacao = json['organizacao'] as Map<String, dynamic>;
    return MembroAtual(
      id: json['id'] as String,
      nome: json['nome'] as String,
      ehAdmin: json['papel'] == 'administrador',
      organizacaoId: organizacao['id'] as String,
      nomeOrganizacao: organizacao['nome'] as String,
    );
  }

  final String id;
  final String nome;
  final bool ehAdmin;
  final String organizacaoId;
  final String nomeOrganizacao;
}
