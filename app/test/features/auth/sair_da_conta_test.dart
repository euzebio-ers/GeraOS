import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/app_teste.dart';

/// Repositório falso que, ao sair, também encerra a sessão.
class _AuthQueEncerraSessao extends AuthRepositoryFalso {
  _AuthQueEncerraSessao(this.auth);

  final EstadoAutenticacaoFalso auth;

  @override
  Future<void> sair() async {
    await super.sair();
    auth.alterarLogin(false);
  }
}

void main() {
  testWidgets('Sair da conta leva ao login sem guardar a tela atual', (
    tester,
  ) async {
    final auth = EstadoAutenticacaoFalso(logado: true);
    await montarApp(tester, auth, authRepository: _AuthQueEncerraSessao(auth));

    await tester.tap(find.text('Mais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);

    final router = GoRouter.of(tester.element(find.text('Entrar')));
    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/login');
  });
}
