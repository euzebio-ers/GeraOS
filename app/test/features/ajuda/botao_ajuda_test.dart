import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/features/ajuda/topicos_ajuda.dart';
import 'package:geraos/features/ordens_servico/domain/os_detalhe.dart';
import 'package:geraos/features/ordens_servico/domain/os_resumo.dart';
import 'package:geraos/features/ordens_servico/domain/status_os.dart';

import '../../helpers/app_teste.dart';

final _os = OsDetalhe(
  id: 'os-1',
  numero: 127,
  status: StatusOs.emAndamento,
  equipamento: 'iPhone 12',
  descricaoProblema: 'Tela trincada.',
  criadoEm: DateTime(2026, 11, 4, 11, 5),
  cliente: const ClienteDaOs(id: 'c1', nome: 'Marina Costa'),
);

Future<void> abrirDetalhe(WidgetTester tester) async {
  await montarApp(
    tester,
    EstadoAutenticacaoFalso(logado: true),
    ordensServicoRepository: OrdensServicoRepositoryFalso(
      ordens: [
        OsResumo(
          id: _os.id,
          numero: _os.numero,
          status: _os.status,
          equipamento: _os.equipamento,
          clienteNome: _os.cliente.nome,
          criadoEm: _os.criadoEm,
        ),
      ],
      detalhes: {_os.id: _os},
    ),
  );
  await tester.tap(find.text('Ordens'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Marina Costa'));
  await tester.pumpAndSettle();
}

void main() {
  test('Todo assunto de ajuda tem título e explicação', () {
    for (final topico in TopicoAjuda.values) {
      expect(topico.titulo, isNotEmpty);
      expect(topico.paragrafos, isNotEmpty);
    }
  });

  testWidgets('O "i" da bancada abre a explicação e fecha em Entendi', (
    tester,
  ) async {
    await montarApp(tester, EstadoAutenticacaoFalso(logado: true));

    await tester.ensureVisible(find.byTooltip('Ajuda: Hoje na bancada'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ajuda: Hoje na bancada'));
    await tester.pumpAndSettle();

    final primeiro = TopicoAjuda.bancada.paragrafos.first;
    expect(find.text(primeiro), findsOneWidget);

    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();

    expect(find.text(primeiro), findsNothing);
  });

  testWidgets('O detalhe da OS explica as etapas e o orçamento', (
    tester,
  ) async {
    await abrirDetalhe(tester);

    expect(find.byTooltip('Ajuda: Etapas da OS'), findsOneWidget);
    expect(find.byTooltip('Ajuda: Orçamento'), findsOneWidget);

    await tester.tap(find.byTooltip('Ajuda: Etapas da OS'));
    await tester.pumpAndSettle();

    expect(find.text(TopicoAjuda.statusOs.paragrafos.first), findsOneWidget);
  });

  testWidgets('O valor estimado da Nova OS tem explicação', (tester) async {
    await montarApp(tester, EstadoAutenticacaoFalso(logado: true));
    await tester.tap(find.text('Criar OS'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Ajuda: Valor estimado'), findsOneWidget);
  });
}
