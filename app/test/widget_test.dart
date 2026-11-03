import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/app.dart';
import 'package:geraos/core/preferences/preferencias.dart';
import 'package:geraos/features/auth/data/estado_autenticacao.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Versão falsa do estado de login, controlada pelo próprio teste.
/// Versão falsa do estado de login, controlada pelo próprio teste.
class EstadoAutenticacaoFalso extends EstadoAutenticacao {
  EstadoAutenticacaoFalso({required this.logado});

  @override
  bool logado;

  void alterarLogin(bool valor) {
    logado = valor;
    notifyListeners();
  }
}

Future<SharedPreferences> montarApp(
  WidgetTester tester,
  EstadoAutenticacao auth,
) async {
  SharedPreferences.setMockInitialValues({});
  final preferencias = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        preferenciasProvider.overrideWithValue(preferencias),
        estadoAutenticacaoProvider.overrideWithValue(auth),
      ],
      child: const GeraOsApp(),
    ),
  );
  await tester.pumpAndSettle();
  return preferencias;
}

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
    final preferencias = await montarApp(tester, EstadoAutenticacaoFalso(logado: true));

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escuro'));
    await tester.pumpAndSettle();

    expect(preferencias.getString('tema'), 'dark');
  });
}