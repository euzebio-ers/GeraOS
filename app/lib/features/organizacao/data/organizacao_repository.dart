import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_provider.dart';
import '../domain/dados_empresa.dart';
import '../domain/membro_atual.dart';

/// Dados informados no cadastro da conta.
typedef DadosCadastro = ({String? nome, String? nomeOrganizacao});

/// A alteração não foi aplicada: só administradores alteram a empresa.
class SemPermissaoEmpresa implements Exception {
  const SemPermissaoEmpresa();
}

class OrganizacaoRepository {
  OrganizacaoRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Vínculo da pessoa logada com a sua organização, ou `null` se ainda não tiver.
  Future<MembroAtual?> buscarMembroAtual() async {
    final usuarioId = _supabase.auth.currentUser?.id;
    if (usuarioId == null) return null;

    final linha = await _supabase
        .from('membros')
        .select('id, nome, papel, organizacao:organizacoes(id, nome)')
        .eq('usuario_id', usuarioId)
        .eq('ativo', true)
        .maybeSingle();

    return linha == null ? null : MembroAtual.deJson(linha);
  }

  /// Nome da pessoa e da empresa, guardados junto com a conta no cadastro.
  DadosCadastro dadosDoCadastro() {
    final dados =
        _supabase.auth.currentUser?.userMetadata ?? const <String, dynamic>{};
    return (
      nome: dados['nome'] as String?,
      nomeOrganizacao: dados['nome_organizacao'] as String?,
    );
  }

  Future<void> criarOrganizacao({
    required String nomeOrganizacao,
    required String nomeMembro,
  }) async {
    await _supabase.rpc(
      'criar_organizacao',
      params: {
        'p_nome_organizacao': nomeOrganizacao.trim(),
        'p_nome_membro': nomeMembro.trim(),
      },
    );
  }

  /// Os dados da empresa, para a tela de Ajustes e para o PDF da OS.
  Future<DadosEmpresa> buscarDadosEmpresa(String organizacaoId) async {
    final linha = await _supabase
        .from('organizacoes')
        .select('nome, documento, telefone, email, endereco, termos_garantia')
        .eq('id', organizacaoId)
        .single();
    return DadosEmpresa.deJson(linha);
  }

  /// Salva os dados da empresa. Lança [SemPermissaoEmpresa] se o banco
  /// não aplicou a alteração, o que acontece quando quem salva não é
  /// administrador (o RLS ignora a alteração em silêncio).
  Future<void> salvarDadosEmpresa(
    String organizacaoId,
    DadosEmpresa dados,
  ) async {
    final linhas = await _supabase
        .from('organizacoes')
        .update(dados.paraJson())
        .eq('id', organizacaoId)
        .select('id');
    if (linhas.isEmpty) throw const SemPermissaoEmpresa();
  }
}

final organizacaoRepositoryProvider = Provider<OrganizacaoRepository>(
  (ref) => OrganizacaoRepository(ref.watch(supabaseProvider)),
);
