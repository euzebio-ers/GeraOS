import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/features/auth/domain/falha_autenticacao.dart';

import '../../helpers/app_teste.dart';

void main() {
  testWidgets('Campos vazios mostram as mensagens e não tentam entrar', (
    tester,
  ) async {
    final repositorio = AuthRepositoryFalso();
    await montarApp(
      tester,
      EstadoAutenticacaoFalso(logado: false),
      authRepository: repositorio,
    );

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o e-mail.'), findsOneWidget);
    expect(find.text('Informe a senha.'), findsOneWidget);
    expect(repositorio.tentativasDeLogin, 0);
  });

  testWidgets('Erro de login aparece em português', (tester) async {
    final repositorio = AuthRepositoryFalso(
      falha: const FalhaAutenticacao('E-mail ou senha inválidos.'),
    );
    await montarApp(
      tester,
      EstadoAutenticacaoFalso(logado: false),
      authRepository: repositorio,
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'maria@teste.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'senha-errada',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(repositorio.tentativasDeLogin, 1);
    expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
  });

  testWidgets('Botão de sair chama o repositório', (tester) async {
    final repositorio = AuthRepositoryFalso();
    await montarApp(
      tester,
      EstadoAutenticacaoFalso(logado: true),
      authRepository: repositorio,
    );

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();

    expect(repositorio.saidas, 1);
  });
}
