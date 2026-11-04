import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/features/clientes/domain/cliente_resumo.dart';

import '../../helpers/app_teste.dart';

final _clientes = [
  ClienteResumo(
    id: '1',
    nome: 'Carlos Menezes',
    telefone: '+5571991205567',
    quantidadeOs: 1,
    ultimaOsEm: DateTime.now(),
  ),
  const ClienteResumo(
    id: '2',
    nome: 'Marina Costa',
    telefone: '+5571992341180',
    quantidadeOs: 3,
  ),
];

Future<void> abrirClientes(WidgetTester tester) async {
  await montarApp(
    tester,
    EstadoAutenticacaoFalso(logado: true),
    clientesRepository: ClientesRepositoryFalso(clientes: _clientes),
  );
  await tester.tap(find.text('Clientes'));
  await tester.pumpAndSettle();
}

void main() {
  test('ClienteResumo é montado a partir da view', () {
    final cliente = ClienteResumo.deJson({
      'id': 'c1',
      'nome': 'Marina Costa',
      'telefone': '+5571992341180',
      'email': null,
      'quantidade_os': 3,
      'ultima_os_em': '2026-11-04T14:32:00+00:00',
    });

    expect(cliente.quantidadeOs, 3);
    expect(cliente.ultimaOsEm, isNotNull);
  });

  testWidgets('A lista mostra os clientes com telefone e quantidade de OS', (
    tester,
  ) async {
    await abrirClientes(tester);

    expect(find.text('2 clientes'), findsOneWidget);
    expect(find.text('(71) 99234-1180'), findsOneWidget);
    expect(find.text('3 OS'), findsOneWidget);
    expect(find.text('hoje'), findsOneWidget);
  });

  testWidgets('A busca filtra a lista', (tester) async {
    await abrirClientes(tester);

    await tester.enterText(find.byType(TextField), 'mar');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Marina Costa'), findsOneWidget);
    expect(find.text('Carlos Menezes'), findsNothing);
  });

  testWidgets('Busca sem resultado mostra o aviso', (tester) async {
    await abrirClientes(tester);

    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum cliente encontrado.'), findsOneWidget);
  });
}
