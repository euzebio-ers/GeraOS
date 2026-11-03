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
}

/// Implementação real, baseada na sessão do Supabase Auth.
class EstadoAutenticacaoSupabase extends EstadoAutenticacao {
  EstadoAutenticacaoSupabase(this._auth) {
    _assinatura = _auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  final GoTrueClient _auth;
  late final StreamSubscription<AuthState> _assinatura;

  @override
  String? get usuarioId => _auth.currentUser?.id;

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
