import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_teste.dart';

void usarTela(WidgetTester tester, double largura, double altura) {
  tester.view.physicalSize = Size(largura, altura);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('A tecla N abre uma nova OS', (tester) async {
    usarTela(tester, 1400, 900);
    await montarApp(tester, EstadoAutenticacaoFalso(logado: true));

    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();

    expect(find.text('Criar OS'), findsOneWidget);
  });

  testWidgets('A tecla / vai para a busca de OS', (tester) async {
    usarTela(tester, 1400, 900);
    await montarApp(tester, EstadoAutenticacaoFalso(logado: true));

    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.pumpAndSettle();

    final busca = tester.widget<TextField>(find.byType(TextField));
    expect(busca.focusNode?.hasFocus, isTrue);
  });

  testWidgets('Digitando num campo, o N não abre uma nova OS', (tester) async {
    usarTela(tester, 1400, 900);
    await montarApp(tester, EstadoAutenticacaoFalso(logado: true));

    await tester.tap(find.text('Ordens'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();

    expect(find.text('Criar OS'), findsNothing);
  });
}
