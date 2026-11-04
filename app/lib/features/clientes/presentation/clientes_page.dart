import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/datas.dart';
import '../../../core/formatting/telefone.dart';
import '../../../core/widgets/avatar_iniciais.dart';
import '../data/clientes_repository.dart';
import '../domain/cliente_resumo.dart';

class ClientesPage extends ConsumerStatefulWidget {
  const ClientesPage({super.key});

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

  void _emBreve() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('O cadastro de cliente chega na parte 8.2b.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultado = ref.watch(listaClientesProvider(_busca));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filled(
              tooltip: 'Novo cliente',
              onPressed: _emBreve,
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
                        aoTocar: (cliente) => _emBreve(),
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
  const _ListaClientes({required this.clientes, required this.aoTocar});

  final List<ClienteResumo> clientes;
  final void Function(ClienteResumo) aoTocar;

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
      // Espaço extra embaixo para o botão do microfone não cobrir o último.
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
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
        return _LinhaCliente(cliente: cliente, aoTocar: () => aoTocar(cliente));
      },
    );
  }
}

class _LinhaCliente extends StatelessWidget {
  const _LinhaCliente({required this.cliente, required this.aoTocar});

  final ClienteResumo cliente;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final secundario = tema.textTheme.bodyMedium?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    final contato = cliente.telefone != null
        ? formatarTelefone(cliente.telefone!)
        : cliente.email;

    return InkWell(
      onTap: aoTocar,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
                  Text(dataRelativa(cliente.ultimaOsEm!), style: secundario),
              ],
            ),
          ],
        ),
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
