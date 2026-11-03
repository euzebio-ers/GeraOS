import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/features/auth/domain/resultado_cadastro.dart';

import '../../helpers/app_teste.dart';

Future<void> abrirCadastro(
  WidgetTester tester,
  AuthRepositoryFalso repositorio,
) async {
  await montarApp(
    tester,
    EstadoAutenticacaoFalso(logado: false),
    authRepository: repositorio,
  );
  await tester.tap(find.text('Criar conta da minha empresa'));
  await tester.pumpAndSettle();
}

Future<void> preencher(
  WidgetTester tester, {
  String confirmacao = 'senha1234',
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Nome da empresa'),
    'TecFix Assistência',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Seu nome'),
    'Maria Souza',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'E-mail'),
    'maria@teste.com',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Senha'),
    'senha1234',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirme a senha'),
    confirmacao,
  );
}

void main() {
  testWidgets('Senhas diferentes não enviam o cadastro', (tester) async {
    final repositorio = AuthRepositoryFalso();
    await abrirCadastro(tester, repositorio);

    await preencher(tester, confirmacao: 'outra1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
    await tester.pumpAndSettle();

    expect(find.text('As senhas não conferem.'), findsOneWidget);
    expect(repositorio.nomeCadastrado, isNull);
  });

  testWidgets('Cadastro com confirmação mostra o aviso de e-mail', (
    tester,
  ) async {
    final repositorio = AuthRepositoryFalso(
      resultadoCadastro: ResultadoCadastro.confirmarEmail,
    );
    await abrirCadastro(tester, repositorio);

    await preencher(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
    await tester.pumpAndSettle();

    expect(repositorio.nomeCadastrado, 'Maria Souza');
    expect(repositorio.organizacaoCadastrada, 'TecFix Assistência');
    expect(find.text('Confirme seu e-mail'), findsOneWidget);
  });
}
