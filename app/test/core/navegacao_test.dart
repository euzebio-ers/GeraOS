import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_teste.dart';

void main() {
  testWidgets('As abas trocam o conteúdo da tela', (tester) async {
    await montarApp(tester, EstadoAutenticacaoFalso(logado: true));

    await tester.tap(find.text('Clientes'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum cliente cadastrado ainda.'), findsOneWidget);

    await tester.tap(find.text('Ordens'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma OS cadastrada ainda.'), findsOneWidget);
  });

  testWidgets('O botão do microfone abre a gravação', (tester) async {
    await montarApp(tester, EstadoAutenticacaoFalso(logado: true));

    await tester.tap(find.byTooltip('Gravar nova OS'));
    await tester.pumpAndSettle();

    expect(find.text('Nova OS por áudio'), findsOneWidget);
  });

  testWidgets('O cartão da Início também abre a gravação', (tester) async {
    await montarApp(tester, EstadoAutenticacaoFalso(logado: true));

    await tester.tap(find.text('Gravar nova OS'));
    await tester.pumpAndSettle();

    expect(find.text('Nova OS por áudio'), findsOneWidget);
  });
}
