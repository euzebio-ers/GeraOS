import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/datas.dart';
import '../../../core/formatting/telefone.dart';
import '../../../core/layout/larguras.dart';
import '../../../core/router/rotas.dart';
import '../../../core/widgets/avatar_iniciais.dart';
import '../data/clientes_repository.dart';
import '../domain/cliente_resumo.dart';
import 'ficha_cliente_page.dart';

class ClientesPage extends ConsumerStatefulWidget {
  const ClientesPage({super.key, this.selecionado});

  /// Id do cliente aberto ao lado da lista, em telas largas.
  final String? selecionado;

  @override
  ConsumerState<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends ConsumerState<ClientesPage> {
  final _campoBusca = TextEditingController();
  Timer? _espera;
  String _busca = '';

  @override
  void dispose() {
    _espera?.cancel();
    _campoBusca.dispose();
    super.dispose();
  }

  /// Espera a pessoa parar de digitar antes de buscar.
  void _aoDigitar(String texto) {
    _espera?.cancel();
    _espera = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _busca = texto.trim());
    });
  }

  /// Lado a lado, a ficha abre à direita; senão, em tela cheia.
  void _abrir(ClienteResumo cliente, {required bool ladoALado}) {
    if (ladoALado) {
      context.go(Rotas.clienteNaLista(cliente.id));
    } else {
      context.push(Rotas.cliente(cliente.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, limites) {
        final ladoALado = limites.maxWidth >= Larguras.listaEDetalhe;
        final lista = _lista(ladoALado: ladoALado);
        if (!ladoALado) return lista;

        final selecionado = widget.selecionado;
        return Row(
          children: [
            SizedBox(width: Larguras.colunaLista, child: lista),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            Expanded(
              child: selecionado == null
                  ? const _NenhumSelecionado()
                  : FichaClientePage(
                      key: ValueKey(selecionado),
                      clienteId: selecionado,
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _lista({required bool ladoALado}) {
    final resultado = ref.watch(listaClientesProvider(_busca));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filled(
              tooltip: 'Novo cliente',
              onPressed: () => context.push(Rotas.novoCliente),
              icon: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _campoBusca,
              onChanged: _aoDigitar,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Nome ou telefone',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: resultado.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (erro, pilha) => _Falha(
                aoTentarDeNovo: () =>
                    ref.invalidate(listaClientesProvider(_busca)),
              ),
              data: (clientes) => clientes.isEmpty
                  ? _ListaVazia(buscando: _busca.isNotEmpty)
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.refresh(listaClientesProvider(_busca).future),
                      child: _ListaClientes(
                        clientes: clientes,
                        selecionado: ladoALado ? widget.selecionado : null,
                        espacoFinal: ladoALado ? 24 : 120,
                        aoTocar: (cliente) =>
                            _abrir(cliente, ladoALado: ladoALado),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListaClientes extends StatelessWidget {
  const _ListaClientes({
    required this.clientes,
    required this.aoTocar,
    required this.espacoFinal,
    this.selecionado,
  });

  final List<ClienteResumo> clientes;
  final void Function(ClienteResumo) aoTocar;

  /// Espaço no fim da lista. No celular, maior, para o microfone não
  /// cobrir o último cliente.
  final double espacoFinal;
  final String? selecionado;

  String get _contagem {
    if (clientes.length >= ClientesRepository.limite) {
      return 'Mostrando os ${ClientesRepository.limite} primeiros. '
          'Busque para encontrar outros.';
    }
    return clientes.length == 1 ? '1 cliente' : '${clientes.length} clientes';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 0, 20, espacoFinal),
      itemCount: clientes.length + 1,
      separatorBuilder: (context, indice) =>
          indice == 0 ? const SizedBox(height: 4) : const Divider(),
      itemBuilder: (context, indice) {
        if (indice == 0) {
          return Text(
            _contagem,
            style: tema.textTheme.labelLarge?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          );
        }
        final cliente = clientes[indice - 1];
        return _LinhaCliente(
          cliente: cliente,
          selecionado: cliente.id == selecionado,
          aoTocar: () => aoTocar(cliente),
        );
      },
    );
  }
}

class _LinhaCliente extends StatelessWidget {
  const _LinhaCliente({
    required this.cliente,
    required this.aoTocar,
    this.selecionado = false,
  });

  final ClienteResumo cliente;
  final VoidCallback aoTocar;
  final bool selecionado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final secundario = tema.textTheme.bodyMedium?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    final contato = cliente.telefone != null
        ? formatarTelefone(cliente.telefone!)
        : cliente.email;

    return Semantics(
      selected: selecionado,
      child: Material(
        color: selecionado
            ? tema.colorScheme.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: aoTocar,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                AvatarIniciais(nome: cliente.nome),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cliente.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.titleMedium,
                      ),
                      if (contato != null) Text(contato, style: secundario),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      cliente.quantidadeOs == 1
                          ? '1 OS'
                          : '${cliente.quantidadeOs} OS',
                      style: tema.textTheme.titleSmall,
                    ),
                    if (cliente.ultimaOsEm != null)
                      Text(
                        dataRelativa(cliente.ultimaOsEm!),
                        style: secundario,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// O lado direito, quando nenhum cliente foi escolhido ainda.
class _NenhumSelecionado extends StatelessWidget {
  const _NenhumSelecionado();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 48,
            color: tema.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Selecione um cliente para ver a ficha',
            style: tema.textTheme.bodyLarge?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListaVazia extends StatelessWidget {
  const _ListaVazia({required this.buscando});

  final bool buscando;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: buscando
            ? const Text('Nenhum cliente encontrado.')
            : const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Nenhum cliente cadastrado ainda.'),
                  SizedBox(height: 4),
                  Text('Toque em + para cadastrar o primeiro.'),
                ],
              ),
      ),
    );
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
              'Não foi possível carregar os clientes. '
              'Verifique sua conexão.',
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
