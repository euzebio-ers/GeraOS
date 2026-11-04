import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/core/formatting/datas.dart';
import 'package:geraos/features/ordens_servico/domain/filtro_status.dart';
import 'package:geraos/features/ordens_servico/domain/os_resumo.dart';
import 'package:geraos/features/ordens_servico/domain/status_os.dart';

import '../../helpers/app_teste.dart';

final _ordens = [
  OsResumo(
    id: '1',
    numero: 128,
    status: StatusOs.aberta,
    equipamento: 'Notebook Dell Inspiron 15',
    clienteNome: 'João Pereira',
    criadoEm: DateTime.now(),
  ),
  OsResumo(
    id: '2',
    numero: 127,
    status: StatusOs.emAndamento,
    equipamento: 'iPhone 12',
    clienteNome: 'Marina Costa',
    criadoEm: DateTime.now(),
    valorTotal: 380,
    quantidadeItens: 2,
  ),
];

Future<void> abrirOrdens(WidgetTester tester) async {
  await montarApp(
    tester,
    EstadoAutenticacaoFalso(logado: true),
    ordensServicoRepository: OrdensServicoRepositoryFalso(ordens: _ordens),
  );
  await tester.tap(find.text('Ordens'));
  await tester.pumpAndSettle();
}

void main() {
  test('OsResumo é montado a partir da view', () {
    final os = OsResumo.deJson({
      'id': 'o1',
      'numero': 128,
      'status': 'em_analise',
      'equipamento': 'Notebook Dell',
      'valor_total': 0,
      'quantidade_itens': 0,
      'cliente_nome': 'João Pereira',
      'criado_em': '2026-11-04T14:32:00+00:00',
    });

    expect(os.status, StatusOs.emAnalise);
    expect(os.aOrcar, isTrue);
  });

  test('dataHoraCurta mostra o horário só para hoje', () {
    final agora = DateTime(2026, 11, 4, 18);
    expect(
      dataHoraCurta(DateTime(2026, 11, 4, 14, 32), agora: agora),
      'hoje 14:32',
    );
    expect(dataHoraCurta(DateTime(2026, 11, 3, 9), agora: agora), 'ontem');
  });

  test('O filtro Pendente soma aberta e em análise', () {
    final contagem = {
      StatusOs.aberta: 2,
      StatusOs.emAnalise: 1,
      StatusOs.pronta: 4,
    };
    expect(FiltroStatus.pendente.contar(contagem), 3);
    expect(FiltroStatus.todas.contar(contagem), 7);
  });

  testWidgets('A lista mostra os cartões e as quantidades por status', (
    tester,
  ) async {
    await abrirOrdens(tester);

    expect(find.textContaining('#0128'), findsOneWidget);
    expect(find.text('a orçar'), findsOneWidget);
    expect(find.text('R\$\u00A0380,00'), findsOneWidget);
    expect(find.text('Todas 2'), findsOneWidget);
    expect(find.text('Pendente 1'), findsOneWidget);
  });

  testWidgets('O filtro mostra só as OS do status escolhido', (tester) async {
    await abrirOrdens(tester);

    await tester.ensureVisible(find.text('Em andamento 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Em andamento 1'));
    await tester.pumpAndSettle();

    expect(find.text('Marina Costa'), findsOneWidget);
    expect(find.text('João Pereira'), findsNothing);
  });

  testWidgets('A busca filtra pelo cliente ou aparelho', (tester) async {
    await abrirOrdens(tester);

    await tester.enterText(find.byType(TextField), 'iphone');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Marina Costa'), findsOneWidget);
    expect(find.text('João Pereira'), findsNothing);
  });
}
