import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_provider.dart';
import '../domain/dados_item.dart';
import '../domain/falha_os.dart';
import '../domain/filtro_status.dart';
import '../domain/nova_os.dart';
import '../domain/os_detalhe.dart';
import '../domain/os_resumo.dart';
import '../domain/status_os.dart';

/// Resultado da criação de uma OS.
typedef OsCriada = ({String id, int numero});

/// A OS não existe ou é de outra organização.
class OsNaoEncontrada implements Exception {
  const OsNaoEncontrada();
}

class OrdensServicoRepository {
  OrdensServicoRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Quantas OS são buscadas de cada vez.
  static const tamanhoPagina = 30;

  static final _buscaPorNumero = RegExp(r'^#?(\d{1,7})$');
  static final _caracteresDoFiltro = RegExp(r'[,()*%\\"]');

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

  /// Uma página de OS, das mais recentes para as mais antigas.
  Future<List<OsResumo>> listar({
    FiltroStatus filtro = FiltroStatus.todas,
    String busca = '',
    int pagina = 0,
  }) async {
    var consulta = _supabase
        .from('ordens_servico_resumo')
        .select(
          'id, numero, status, equipamento, valor_total, '
          'quantidade_itens, cliente_nome, criado_em',
        );

    if (filtro != FiltroStatus.todas) {
      consulta = consulta.inFilter('status', [
        for (final status in filtro.status) status.valorBanco,
      ]);
    }

    final termo = busca.trim();
    if (termo.isNotEmpty) {
      final numero = _buscaPorNumero.firstMatch(termo);
      if (numero != null) {
        consulta = consulta.eq('numero', int.parse(numero.group(1)!));
      } else {
        final seguro = termo.replaceAll(_caracteresDoFiltro, ' ').trim();
        if (seguro.isNotEmpty) {
          consulta = consulta.or(
            'cliente_nome.ilike.*$seguro*,equipamento.ilike.*$seguro*',
          );
        }
      }
    }

    final inicio = pagina * tamanhoPagina;
    final linhas = await consulta
        .order('criado_em', ascending: false)
        .order('numero', ascending: false)
        .range(inicio, inicio + tamanhoPagina - 1);
    return linhas.map(OsResumo.deJson).toList();
  }

  /// Quantidade de OS em cada status.
  Future<Map<StatusOs, int>> contarPorStatus() async {
    final linhas = await _supabase.rpc('contar_os_por_status') as List<dynamic>;
    return {
      for (final linha in linhas.cast<Map<String, dynamic>>())
        StatusOs.doBanco(linha['status'] as String):
            (linha['quantidade'] as num).toInt(),
    };
  }

  /// A OS completa: cliente, itens e histórico.
  Future<OsDetalhe> buscarDetalhe(String id) async {
    final dados = await _supabase.rpc('detalhe_os', params: {'p_os_id': id});
    if (dados == null) throw const OsNaoEncontrada();
    return OsDetalhe.deJson(dados as Map<String, dynamic>);
  }

  /// Muda o status pela função do banco, que valida a transição (RN007)
  /// e registra o histórico (RN006).
  Future<void> alterarStatus(
    String osId,
    StatusOs novo, {
    String? observacao,
  }) => _alterar(
    () => _supabase.rpc(
      'alterar_status_os',
      params: {
        'p_os_id': osId,
        'p_novo_status': novo.valorBanco,
        'p_observacao': ?observacao,
      },
    ),
  );

  Future<void> salvarDiagnostico(String osId, String? diagnostico) => _alterar(
    () => _supabase
        .from('ordens_servico')
        .update({'diagnostico': diagnostico})
        .eq('id', osId),
  );

  /// O total é recalculado pelo banco (RN008).
  Future<void> salvarDesconto(String osId, double desconto) => _alterar(
    () => _supabase
        .from('ordens_servico')
        .update({'desconto': desconto})
        .eq('id', osId),
  );

  /// Inclui (sem id) ou altera (com id) um item da OS.
  Future<void> salvarItem(String osId, DadosItem item) => _alterar(() {
    final id = item.id;
    if (id == null) {
      return _supabase.from('itens_os').insert({
        ...item.paraJson(),
        'os_id': osId,
      });
    }
    return _supabase.from('itens_os').update(item.paraJson()).eq('id', id);
  });

  Future<void> removerItem(String itemId) =>
      _alterar(() => _supabase.from('itens_os').delete().eq('id', itemId));

  /// Executa uma alteração e traduz os erros para `FalhaOs`.
  Future<void> _alterar(Future<Object?> Function() operacao) async {
    try {
      await operacao();
    } on PostgrestException catch (erro) {
      throw FalhaOs.de(erro);
    } on Exception {
      throw const FalhaOs(
        'Não foi possível salvar. Verifique sua conexão e tente novamente.',
      );
    }
  }
}

final ordensServicoRepositoryProvider = Provider<OrdensServicoRepository>(
  (ref) => OrdensServicoRepository(ref.watch(supabaseProvider)),
);

/// Avisa as telas que as OS mudaram (uma foi criada ou alterada).
class AtualizacaoOs extends Notifier<int> {
  @override
  int build() => 0;

  void avisar() => state++;
}

final atualizacaoOsProvider = NotifierProvider<AtualizacaoOs, int>(
  AtualizacaoOs.new,
);

/// Contagem por status, refeita sempre que as OS mudam.
final contagemStatusProvider = FutureProvider.autoDispose<Map<StatusOs, int>>((
  ref,
) {
  ref.watch(atualizacaoOsProvider);
  return ref.watch(ordensServicoRepositoryProvider).contarPorStatus();
});

/// O detalhe de uma OS, refeito sempre que as OS mudam.
final detalheOsProvider = FutureProvider.autoDispose.family<OsDetalhe, String>((
  ref,
  id,
) {
  ref.watch(atualizacaoOsProvider);
  return ref.watch(ordensServicoRepositoryProvider).buscarDetalhe(id);
});
