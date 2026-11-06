import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../layout/larguras.dart';
import '../router/rotas.dart';
import '../theme/cores_geraos.dart';

/// Estrutura comum às abas. No celular, barra embaixo com o microfone no
/// centro; em telas largas, menu lateral com o botão de gravar no topo.
class CascaApp extends StatelessWidget {
  const CascaApp({super.key, required this.navigationShell});

  /// Fornecido pelo go_router: a aba atual e como trocar de aba.
  final StatefulNavigationShell navigationShell;

  /// Troca de aba. Tocar na aba que já está aberta volta para o início dela.
  void _irPara(int aba) {
    navigationShell.goBranch(
      aba,
      initialLocation: aba == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width;

    if (largura < Larguras.menuLateral) {
      return _CascaCelular(
        navigationShell: navigationShell,
        aoEscolher: _irPara,
      );
    }
    return _CascaTelaLarga(
      navigationShell: navigationShell,
      aoEscolher: _irPara,
      expandido: largura >= Larguras.menuExpandido,
    );
  }
}

void _gravar(BuildContext context) => context.push(Rotas.gravarOs);

/// Celular: barra de abas embaixo, com o microfone no centro.
class _CascaCelular extends StatelessWidget {
  const _CascaCelular({
    required this.navigationShell,
    required this.aoEscolher,
  });

  final StatefulNavigationShell navigationShell;
  final ValueChanged<int> aoEscolher;

  /// Posição do espaço reservado ao microfone, no meio da barra.
  static const _posicaoMicrofone = 2;

  /// Converte o índice da aba no índice da barra (que tem o espaço do meio).
  int get _indiceNaBarra {
    final aba = navigationShell.currentIndex;
    return aba < _posicaoMicrofone ? aba : aba + 1;
  }

  void _aoTocar(int indiceNaBarra) {
    if (indiceNaBarra == _posicaoMicrofone) return;
    aoEscolher(
      indiceNaBarra < _posicaoMicrofone ? indiceNaBarra : indiceNaBarra - 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 72,
        height: 72,
        child: FloatingActionButton(
          tooltip: 'Gravar nova OS',
          onPressed: () => _gravar(context),
          backgroundColor: context.cores.microfone,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 3,
          child: const Icon(Icons.mic_none_rounded, size: 34),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _indiceNaBarra,
          onDestinationSelected: _aoTocar,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment_rounded),
              label: 'Ordens',
            ),
            // Espaço reservado para o botão do microfone.
            NavigationDestination(
              icon: SizedBox.shrink(),
              label: '',
              enabled: false,
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Clientes',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_rounded),
              label: 'Mais',
            ),
          ],
        ),
      ),
    );
  }
}

/// Tablet deitado e computador: menu lateral à esquerda.
class _CascaTelaLarga extends StatelessWidget {
  const _CascaTelaLarga({
    required this.navigationShell,
    required this.aoEscolher,
    required this.expandido,
  });

  final StatefulNavigationShell navigationShell;
  final ValueChanged<int> aoEscolher;

  /// `true` no computador: o menu mostra os nomes ao lado dos ícones.
  final bool expandido;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              extended: expandido,
              minExtendedWidth: 232,
              labelType: expandido
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: aoEscolher,
              leading: _TopoDoMenu(expandido: expandido),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Início'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment_rounded),
                  label: Text('Ordens'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline_rounded),
                  selectedIcon: Icon(Icons.people_rounded),
                  label: Text('Clientes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: Text('Ajustes'),
                ),
              ],
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: tema.colorScheme.outlineVariant,
            ),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    );
  }
}

/// A marca e o botão de gravar, no topo do menu lateral.
class _TopoDoMenu extends StatelessWidget {
  const _TopoDoMenu({required this.expandido});

  final bool expandido;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final microfone = context.cores.microfone;

    return Padding(
      padding: EdgeInsets.fromLTRB(expandido ? 12 : 0, 12, 0, 20),
      child: Column(
        crossAxisAlignment: expandido
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (expandido) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'GeraOS',
                style: tema.textTheme.titleLarge?.copyWith(
                  color: tema.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              onPressed: () => _gravar(context),
              backgroundColor: microfone,
              foregroundColor: Colors.white,
              elevation: 1,
              icon: const Icon(Icons.mic_none_rounded),
              label: const Text('Gravar OS'),
            ),
          ] else
            FloatingActionButton(
              tooltip: 'Gravar nova OS',
              onPressed: () => _gravar(context),
              backgroundColor: microfone,
              foregroundColor: Colors.white,
              elevation: 1,
              child: const Icon(Icons.mic_none_rounded),
            ),
        ],
      ),
    );
  }
}
