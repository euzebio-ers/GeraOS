import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/rotas.dart';
import '../data/ordens_servico_repository.dart';
import '../domain/filtro_status.dart';
import '../domain/os_resumo.dart';
import 'widgets/cartao_os.dart';
import 'filtro_solicitado.dart';

class ListaOsPage extends ConsumerStatefulWidget {
  const ListaOsPage({super.key});

  @override
  ConsumerState<ListaOsPage> createState() => _ListaOsPageState();
}

class _ListaOsPageState extends ConsumerState<ListaOsPage> {
  final _rolagem = ScrollController();
  final _campoBusca = TextEditingController();
  Timer? _espera;

  FiltroStatus _filtro = FiltroStatus.todas;
  String _busca = '';

  final _itens = <OsResumo>[];
  int _pagina = 0;
  bool _temMais = true;
  bool _carregando = false;
  bool _falhou = false;

  /// Muda a cada recarga. Respostas de buscas antigas são descartadas.
  int _geracao = 0;

  @override
  void initState() {
    super.initState();
    _rolagem.addListener(_aoRolar);

    final pedido = ref.read(filtroOsSolicitadoProvider);
    if (pedido != null) {
      _filtro = pedido;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(filtroOsSolicitadoProvider.notifier).limpar(),
      );
    }

    _carregarMais();
  }

  @override
  void dispose() {
    _espera?.cancel();
    _rolagem.dispose();
    _campoBusca.dispose();
    super.dispose();
  }

  /// Perto do fim da lista, busca a próxima página.
  void _aoRolar() {
    final posicao = _rolagem.position;
    if (posicao.pixels > posicao.maxScrollExtent - 300) _carregarMais();
  }

  Future<void> _recarregar() async {
    _geracao++;
    setState(() {
      _itens.clear();
      _pagina = 0;
      _temMais = true;
      _carregando = false;
      _falhou = false;
    });
    await _carregarMais();
  }

  Future<void> _carregarMais() async {
    if (_carregando || !_temMais) return;
    final geracao = _geracao;

    setState(() {
      _carregando = true;
      _falhou = false;
    });

    try {
      final novos = await ref
          .read(ordensServicoRepositoryProvider)
          .listar(filtro: _filtro, busca: _busca, pagina: _pagina);
      if (!mounted || geracao != _geracao) return;
      setState(() {
        _itens.addAll(novos);
        _pagina++;
        _temMais = novos.length == OrdensServicoRepository.tamanhoPagina;
        _carregando = false;
      });
    } on Exception {
      if (!mounted || geracao != _geracao) return;
      setState(() {
        _carregando = false;
        _falhou = true;
      });
    }
  }

  Future<void> _atualizar() async {
    ref.invalidate(contagemStatusProvider);
    await _recarregar();
  }

  void _escolherFiltro(FiltroStatus filtro) {
    if (filtro == _filtro) return;
    _filtro = filtro;
    _recarregar();
  }

  void _aoDigitar(String texto) {
    _espera?.cancel();
    _espera = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _busca = texto.trim();
      _recarregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(atualizacaoOsProvider, (anterior, atual) => _recarregar());
    ref.listen<FiltroStatus?>(filtroOsSolicitadoProvider, (anterior, pedido) {
      if (pedido == null) return;
      ref.read(filtroOsSolicitadoProvider.notifier).limpar();
      _escolherFiltro(pedido);
    });
    final contagem = ref.watch(contagemStatusProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filled(
              tooltip: 'Nova OS',
              onPressed: () => context.push(Rotas.novaOs),
              icon: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: TextField(
              controller: _campoBusca,
              onChanged: _aoDigitar,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Cliente, aparelho ou nº da OS',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final filtro in FiltroStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        contagem.isEmpty
                            ? filtro.rotulo
                            : '${filtro.rotulo} ${filtro.contar(contagem)}',
                      ),
                      selected: _filtro == filtro,
                      onSelected: (_) => _escolherFiltro(filtro),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _conteudo()),
        ],
      ),
    );
  }

  Widget _conteudo() {
    if (_itens.isEmpty) {
      if (_carregando) return const Center(child: CircularProgressIndicator());
      if (_falhou) {
        return _Falha(aoTentarDeNovo: _recarregar);
      }
      final semFiltro = _busca.isEmpty && _filtro == FiltroStatus.todas;
      return Center(
        child: Text(
          semFiltro ? 'Nenhuma OS cadastrada ainda.' : 'Nenhuma OS encontrada.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _atualizar,
      child: ListView.separated(
        controller: _rolagem,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
        itemCount: _itens.length + 1,
        separatorBuilder: (context, indice) => const SizedBox(height: 10),
        itemBuilder: (context, indice) {
          if (indice == _itens.length) return _rodape();
          final os = _itens[indice];
          return CartaoOs(os: os, aoTocar: () => context.push(Rotas.os(os.id)));
        },
      ),
    );
  }

  /// Fim da lista: carregando mais, falha ao carregar, ou nada.
  Widget _rodape() {
    if (_carregando) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_falhou) {
      return TextButton(
        onPressed: _carregarMais,
        child: const Text('Não foi possível carregar mais. Tentar de novo'),
      );
    }
    return const SizedBox.shrink();
  }
}

class _Falha extends StatelessWidget {
  const _Falha({required this.aoTentarDeNovo});

  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Não foi possível carregar as OS. Verifique sua conexão.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: aoTentarDeNovo,
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
    );
  }
}
