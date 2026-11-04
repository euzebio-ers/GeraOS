import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_provider.dart';
import '../domain/nova_os.dart';

/// Resultado da criação de uma OS.
typedef OsCriada = ({String id, int numero});

class OrdensServicoRepository {
  OrdensServicoRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Cria a OS (e o cliente, se for novo) numa única transação no banco.
  Future<OsCriada> criarDigitada(NovaOs os) async {
    final linha = await _supabase.rpc(
      'criar_os_digitada',
      params: os.paraParametros(),
    ) as Map<String, dynamic>;

    return (
      id: linha['id'] as String,
      numero: (linha['numero'] as num).toInt(),
    );
  }
}

final ordensServicoRepositoryProvider = Provider<OrdensServicoRepository>(
  (ref) => OrdensServicoRepository(ref.watch(supabaseProvider)),
);
