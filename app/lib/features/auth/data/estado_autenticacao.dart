import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_provider.dart';

/// Informa se há um usuário logado e avisa sempre que isso mudar.
abstract class EstadoAutenticacao extends ChangeNotifier {
  bool get logado;
}

/// Implementação real, baseada na sessão do Supabase Auth.
class EstadoAutenticacaoSupabase extends EstadoAutenticacao {
  EstadoAutenticacaoSupabase(this._auth) {
    _assinatura = _auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  final GoTrueClient _auth;
  late final StreamSubscription<AuthState> _assinatura;

  @override
  bool get logado => _auth.currentSession != null;

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