import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/features/clientes/domain/cliente_resumo.dart';

import '../../helpers/app_teste.dart';

import 'package:geraos/features/clientes/domain/cliente.dart';

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

  test('Cliente grava só os campos editáveis', () {
    const cliente = Cliente(
      id: 'c1',
      nome: 'Marina Costa',
      telefone: '+5571992341180',
    );

    final json = cliente.paraJson();
    expect(json.containsKey('id'), isFalse);
    expect(json.containsKey('organizacao_id'), isFalse);
    expect(json['telefone'], '+5571992341180');
  });

  testWidgets('Novo cliente exige telefone ou e-mail', (tester) async {
    final repositorio = ClientesRepositoryFalso();
    await montarApp(
      tester,
      EstadoAutenticacaoFalso(logado: true),
      clientesRepository: repositorio,
    );
    await tester.tap(find.text('Clientes'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Novo cliente'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome completo *'),
      'Fernanda Rocha',
    );
    await tester.tap(find.text('Cadastrar cliente'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o telefone ou o e-mail.'), findsOneWidget);
    expect(repositorio.salvo, isNull);
  });

  testWidgets('Novo cliente é salvo com o telefone no formato do banco', (
    tester,
  ) async {
    final repositorio = ClientesRepositoryFalso();
    await montarApp(
      tester,
      EstadoAutenticacaoFalso(logado: true),
      clientesRepository: repositorio,
    );
    await tester.tap(find.text('Clientes'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Novo cliente'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome completo *'),
      'Fernanda Rocha',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'WhatsApp / telefone com DDD'),
      '71984550912',
    );
    await tester.tap(find.text('Cadastrar cliente'));
    await tester.pumpAndSettle();

    expect(repositorio.salvo?.nome, 'Fernanda Rocha');
    expect(repositorio.salvo?.telefone, '+5571984550912');
    expect(repositorio.salvo?.id, isNull);
    // Voltou para a lista.
    expect(find.text('Nome ou telefone'), findsOneWidget);
  });

  testWidgets('Tocar num cliente abre a edição já preenchida', (tester) async {
    final repositorio = ClientesRepositoryFalso(clientes: _clientes);
    await montarApp(
      tester,
      EstadoAutenticacaoFalso(logado: true),
      clientesRepository: repositorio,
    );
    await tester.tap(find.text('Clientes'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Marina Costa'));
    await tester.pumpAndSettle();

    expect(find.text('Editar cliente'), findsOneWidget);
    expect(find.text('(71) 99234-1180'), findsOneWidget);

    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    expect(repositorio.salvo?.id, '2');
  });
}
