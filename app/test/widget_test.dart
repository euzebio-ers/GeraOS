import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_teste.dart';

void main() {
  testWidgets('Usuário não logado é levado ao login', (tester) async {
    await montarApp(tester, EstadoAutenticacaoFalso(logado: false));
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('Usuário logado vê a lista de OS', (tester) async {
    await montarApp(tester, EstadoAutenticacaoFalso(logado: true));
    expect(find.text('Ordens de Serviço'), findsOneWidget);
  });

  testWidgets('Ao sair da conta, o app volta para o login', (tester) async {
    final auth = EstadoAutenticacaoFalso(logado: true);
    await montarApp(tester, auth);

    auth.alterarLogin(false);
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('Tema escolhido é salvo no aparelho', (tester) async {
    final preferencias = await montarApp(
      tester,
      EstadoAutenticacaoFalso(logado: true),
    );

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escuro'));
    await tester.pumpAndSettle();

    expect(preferencias.getString('tema'), 'dark');
  });
}
