import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/rotas.dart';
import '../theme/cores_geraos.dart';

/// Estrutura comum às abas: barra inferior e botão do microfone.
class CascaApp extends StatelessWidget {
  const CascaApp({super.key, required this.navigationShell});

  /// Fornecido pelo go_router: a aba atual e como trocar de aba.
  final StatefulNavigationShell navigationShell;

  /// Posição do espaço reservado ao microfone, no meio da barra.
  static const _posicaoMicrofone = 2;

  /// Converte o índice da aba no índice da barra (que tem o espaço do meio).
  int get _indiceNaBarra {
    final aba = navigationShell.currentIndex;
    return aba < _posicaoMicrofone ? aba : aba + 1;
  }

  void _aoTocar(int indiceNaBarra) {
    if (indiceNaBarra == _posicaoMicrofone) return;
    final aba = indiceNaBarra < _posicaoMicrofone
        ? indiceNaBarra
        : indiceNaBarra - 1;

    // Tocar na aba que já está aberta volta para o início dela.
    navigationShell.goBranch(
      aba,
      initialLocation: aba == navigationShell.currentIndex,
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
          onPressed: () => context.push(Rotas.gravarOs),
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
