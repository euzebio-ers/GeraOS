import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_provider.dart';
import '../domain/falha_autenticacao.dart';
import '../domain/resultado_cadastro.dart';

/// Operações de conta no Supabase Auth.
class AuthRepository {
  AuthRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<void> entrar({required String email, required String senha}) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: senha,
      );
    } on AuthException catch (erro) {
      throw FalhaAutenticacao.de(erro);
    }
  }

  Future<ResultadoCadastro> cadastrar({
    required String nomeOrganizacao,
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final resposta = await _supabase.auth.signUp(
        email: email.trim(),
        password: senha,
        data: {'nome': nome.trim(), 'nome_organizacao': nomeOrganizacao.trim()},
      );
      return resposta.session != null
          ? ResultadoCadastro.logado
          : ResultadoCadastro.confirmarEmail;
    } on AuthException catch (erro) {
      throw FalhaAutenticacao.de(
        erro,
        padrao: 'Não foi possível criar a conta. Tente novamente.',
      );
    }
  }

  Future<void> enviarRecuperacaoSenha(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (erro) {
      throw FalhaAutenticacao.de(
        erro,
        padrao: 'Não foi possível enviar o e-mail. Tente novamente.',
      );
    }
  }

  Future<void> sair() => _supabase.auth.signOut();
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(supabaseProvider)),
);
