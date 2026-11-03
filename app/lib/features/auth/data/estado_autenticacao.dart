import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_provider.dart';

/// Informa quem está logado e avisa sempre que isso mudar.
abstract class EstadoAutenticacao extends ChangeNotifier {
  /// ID do usuário logado, ou `null` se ninguém estiver logado.
  String? get usuarioId;

  bool get logado => usuarioId != null;

  /// `true` quando a pessoa entrou pelo link de "esqueci minha senha".
  bool get recuperandoSenha;

  /// Chamado depois que a nova senha foi salva.
  void concluirRecuperacao();
}

/// Implementação real, baseada na sessão do Supabase Auth.
class EstadoAutenticacaoSupabase extends EstadoAutenticacao {
  EstadoAutenticacaoSupabase(this._auth) {
    _assinatura = _auth.onAuthStateChange.listen(
      (dados) {
        if (dados.event == AuthChangeEvent.passwordRecovery) {
          _recuperandoSenha = true;
        } else if (dados.event == AuthChangeEvent.signedOut) {
          _recuperandoSenha = false;
        }
        notifyListeners();
      },
      // Link expirado ou já usado: a pessoa continua deslogada e
      // pode entrar normalmente, então não há o que fazer aqui.
      onError: (Object _) {},
    );
  }

  final GoTrueClient _auth;
  late final StreamSubscription<AuthState> _assinatura;
  bool _recuperandoSenha = false;

  @override
  String? get usuarioId => _auth.currentUser?.id;

  @override
  bool get recuperandoSenha => _recuperandoSenha;

  @override
  void concluirRecuperacao() {
    _recuperandoSenha = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _assinatura.cancel();
    super.dispose();
  }
}

final estadoAutenticacaoProvider = Provider<EstadoAutenticacao>((ref) {
  final estado = EstadoAutenticacaoSupabase(ref.watch(supabaseProvider).auth);
  ref.onDispose(estado.dispose);
  return estado;
});
