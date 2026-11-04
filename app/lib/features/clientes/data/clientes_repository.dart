import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/formatting/telefone.dart';
import '../../../core/supabase/supabase_provider.dart';
import '../domain/cliente_resumo.dart';

class ClientesRepository {
  ClientesRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Quantos clientes a lista mostra de uma vez.
  static const limite = 50;

  static final _letras = RegExp(r'[A-Za-zÀ-ÿ]');

  /// Clientes da organização em ordem alfabética, com busca opcional
  /// por nome ou telefone.
  Future<List<ClienteResumo>> listar({String busca = ''}) async {
    var consulta = _supabase
        .from('clientes_resumo')
        .select('id, nome, telefone, email, quantidade_os, ultima_os_em');

    final termo = busca.trim();
    if (termo.isNotEmpty) {
      final digitos = apenasDigitos(termo);
      final ehTelefone = digitos.length >= 3 && !_letras.hasMatch(termo);
      consulta = ehTelefone
          ? consulta.ilike('telefone', '%$digitos%')
          : consulta.ilike('nome', '%$termo%');
    }

    final linhas = await consulta.order('nome', ascending: true).limit(limite);
    return linhas.map(ClienteResumo.deJson).toList();
  }
}

final clientesRepositoryProvider = Provider<ClientesRepository>(
  (ref) => ClientesRepository(ref.watch(supabaseProvider)),
);

/// Lista de clientes para um termo de busca. Cada termo tem o seu resultado.
final listaClientesProvider = FutureProvider.autoDispose
    .family<List<ClienteResumo>, String>(
      (ref, busca) =>
          ref.watch(clientesRepositoryProvider).listar(busca: busca),
    );
