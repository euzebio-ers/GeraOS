import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/app.dart';
import 'package:geraos/core/preferences/preferencias.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> montarApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final preferencias = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [preferenciasProvider.overrideWithValue(preferencias)],
      child: const GeraOsApp(),
    ),
  );
  await tester.pumpAndSettle();
  return preferencias;
}

void main() {
  testWidgets('App abre exibindo o nome GeraOS', (tester) async {
    await montarApp(tester);
    expect(find.text('GeraOS'), findsOneWidget);
  });

  testWidgets('Valores aparecem no formato brasileiro', (tester) async {
    await montarApp(tester);
    expect(find.text('R\$\u00A01.234,56'), findsOneWidget);
  });

  testWidgets('Tema escolhido é salvo no aparelho', (tester) async {
    final preferencias = await montarApp(tester);

    await tester.tap(find.text('Escuro'));
    await tester.pumpAndSettle();

    expect(preferencias.getString('tema'), 'dark');
  });
}