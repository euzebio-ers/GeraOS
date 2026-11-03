import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_provider.dart';
import '../domain/falha_autenticacao.dart';

/// Operações de login e logout no Supabase Auth.
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

  Future<void> sair() => _supabase.auth.signOut();
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(supabaseProvider)),
);
