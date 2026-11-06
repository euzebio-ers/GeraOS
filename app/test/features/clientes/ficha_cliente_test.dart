import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/features/clientes/domain/cliente_resumo.dart';
import 'package:geraos/features/ordens_servico/domain/os_resumo.dart';
import 'package:geraos/features/ordens_servico/domain/status_os.dart';

import '../../helpers/app_teste.dart';

const _clientes = [
  ClienteResumo(id: '1', nome: 'Carlos Menezes', telefone: '+5571991205567'),
  ClienteResumo(id: '2', nome: 'Marina Costa', telefone: '+5571992341180'),
];

final _ordens = [
  OsResumo(
    id: 'os-1',
    numero: 127,
    status: StatusOs.emAndamento,
    equipamento: 'iPhone 12',
    clienteId: '2',
    clienteNome: 'Marina Costa',
    criadoEm: DateTime(2026, 11, 5, 14),
  ),
  OsResumo(
    id: 'os-2',
    numero: 98,
    status: StatusOs.entregue,
    equipamento: 'iPad 9',
    clienteId: '2',
    clienteNome: 'Marina Costa',
    criadoEm: DateTime(2026, 9, 12),
  ),
  OsResumo(
    id: 'os-3',
    numero: 126,
    status: StatusOs.aberta,
    equipamento: 'Smart TV LG',
    clienteId: '1',
    clienteNome: 'Carlos Menezes',
    criadoEm: DateTime(2026, 11, 4),
  ),
];

void usarTela(WidgetTester tester, double largura, double altura) {
  tester.view.physicalSize = Size(largura, altura);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> abrirClientes(WidgetTester tester) async {
  await montarApp(
    tester,
    EstadoAutenticacaoFalso(logado: true),
    clientesRepository: ClientesRepositoryFalso(clientes: _clientes),
    ordensServicoRepository: OrdensServicoRepositoryFalso(ordens: _ordens),
  );
  await tester.tap(find.text('Clientes'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('A ficha mostra só as OS do próprio cliente', (tester) async {
    usarTela(tester, 390, 844);
    await abrirClientes(tester);

    await tester.tap(find.text('Marina Costa'));
    await tester.pumpAndSettle();

    expect(find.text('Histórico de OS'), findsOneWidget);
    expect(find.text('iPhone 12'), findsOneWidget);
    expect(find.text('iPad 9'), findsOneWidget);
    expect(find.text('Smart TV LG'), findsNothing);
  });

  testWidgets('O botão Editar da ficha abre o formulário', (tester) async {
    usarTela(tester, 390, 844);
    await abrirClientes(tester);

    await tester.tap(find.text('Marina Costa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Editar cliente'), findsOneWidget);
    expect(find.text('(71) 99234-1180'), findsOneWidget);
  });

  testWidgets('No computador, a ficha abre ao lado da lista', (tester) async {
    usarTela(tester, 1400, 900);
    await abrirClientes(tester);

    expect(find.text('Selecione um cliente para ver a ficha'), findsOneWidget);

    await tester.tap(find.text('Marina Costa'));
    await tester.pumpAndSettle();

    expect(find.text('Histórico de OS'), findsOneWidget);
    expect(find.text('Carlos Menezes'), findsOneWidget);
    expect(find.text('Selecione um cliente para ver a ficha'), findsNothing);
  });
}
