import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_teste.dart';

/// Simula uma tela com a largura e a altura informadas.
void usarTela(WidgetTester tester, double largura, double altura) {
  tester.view.physicalSize = Size(largura, altura);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('No celular, a navegação fica na barra embaixo', (tester) async {
    usarTela(tester, 390, 844);
    await montarApp(tester, EstadoAutenticacaoFalso(logado: true));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('No tablet deitado, o menu lateral é fino', (tester) async {
    usarTela(tester, 1000, 700);
    await montarApp(tester, EstadoAutenticacaoFalso(logado: true));

    final menu = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(menu.extended, isFalse);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byTooltip('Gravar nova OS'), findsOneWidget);
  });

  testWidgets('No computador, o menu lateral mostra os nomes e troca de aba', (
    tester,
  ) async {
    usarTela(tester, 1400, 900);
    await montarApp(tester, EstadoAutenticacaoFalso(logado: true));

    final menu = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(menu.extended, isTrue);
    expect(find.text('Gravar OS'), findsOneWidget);
    expect(find.text('Ajustes'), findsWidgets);

    await tester.tap(find.text('Clientes'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum cliente cadastrado ainda.'), findsOneWidget);
  });
}
