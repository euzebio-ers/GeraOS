import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_teste.dart';

void main() {
  testWidgets('Quem chega pelo link de recuperação vê a tela de nova senha', (
    tester,
  ) async {
    await montarApp(
      tester,
      EstadoAutenticacaoFalso(logado: true, recuperandoSenha: true),
    );

    expect(find.text('Salvar nova senha'), findsOneWidget);
  });

  testWidgets('Nova senha é salva e o app segue para as OS', (tester) async {
    final auth = EstadoAutenticacaoFalso(logado: true, recuperandoSenha: true);
    final repositorio = AuthRepositoryFalso();
    await montarApp(tester, auth, authRepository: repositorio);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nova senha'),
      'novaSenha123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirme a nova senha'),
      'novaSenha123',
    );
    await tester.tap(find.text('Salvar nova senha'));
    await tester.pumpAndSettle();

    expect(repositorio.novaSenhaDefinida, 'novaSenha123');
    expect(auth.recuperandoSenha, isFalse);
    expect(find.text('Ordens de Serviço'), findsOneWidget);
  });
}
