import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_teste.dart';

void usarTela(WidgetTester tester, double largura, double altura) {
  tester.view.physicalSize = Size(largura, altura);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('No computador, as últimas OS ficam na coluna da direita', (
    tester,
  ) async {
    usarTela(tester, 1600, 1000);
    await montarApp(tester, EstadoAutenticacaoFalso(logado: true));

    final bancada = tester.getTopLeft(find.text('Hoje na bancada'));
    final ultimas = tester.getTopLeft(find.text('Últimas OS'));

    expect(ultimas.dx, greaterThan(bancada.dx + 200));
  });

  testWidgets('No celular, as últimas OS ficam embaixo da bancada', (
    tester,
  ) async {
    usarTela(tester, 390, 2000);
    await montarApp(tester, EstadoAutenticacaoFalso(logado: true));

    final bancada = tester.getTopLeft(find.text('Hoje na bancada'));
    final ultimas = tester.getTopLeft(find.text('Últimas OS'));

    expect(ultimas.dx, bancada.dx);
    expect(ultimas.dy, greaterThan(bancada.dy));
  });
}
