import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/features/ordens_servico/domain/os_detalhe.dart';
import 'package:geraos/features/ordens_servico/domain/os_resumo.dart';
import 'package:geraos/features/ordens_servico/domain/status_os.dart';

import '../../helpers/app_teste.dart';

OsDetalhe _os(StatusOs status) => OsDetalhe(
  id: 'os-1',
  numero: 127,
  status: status,
  equipamento: 'iPhone 12',
  descricaoProblema: 'Tela trincada após queda.',
  criadoEm: DateTime(2026, 11, 4, 11, 5),
  cliente: const ClienteDaOs(id: 'c1', nome: 'Marina Costa'),
);

/// Abre o detalhe da OS pela lista e devolve o repositório falso.
Future<OrdensServicoRepositoryFalso> abrirDetalhe(
  WidgetTester tester,
  StatusOs status,
) async {
  final detalhe = _os(status);
  final repositorio = OrdensServicoRepositoryFalso(
    ordens: [
      OsResumo(
        id: detalhe.id,
        numero: detalhe.numero,
        status: status,
        equipamento: detalhe.equipamento,
        clienteNome: detalhe.cliente.nome,
        criadoEm: detalhe.criadoEm,
      ),
    ],
    detalhes: {detalhe.id: detalhe},
  );
  await montarApp(
    tester,
    EstadoAutenticacaoFalso(logado: true),
    ordensServicoRepository: repositorio,
  );
  await tester.tap(find.text('Ordens'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Marina Costa'));
  await tester.pumpAndSettle();
  return repositorio;
}

void main() {
  test('As transições do app são as mesmas do banco (RN007)', () {
    const doBanco = {
      'aberta>em_analise',
      'aberta>cancelada',
      'em_analise>aguardando_aprovacao',
      'em_analise>em_andamento',
      'em_analise>cancelada',
      'aguardando_aprovacao>em_andamento',
      'aguardando_aprovacao>cancelada',
      'em_andamento>pronta',
      'em_andamento>cancelada',
      'pronta>entregue',
    };

    final doApp = {
      for (final de in StatusOs.values)
        for (final para in de.proximos) '${de.valorBanco}>${para.valorBanco}',
    };

    expect(doApp, doBanco);
  });

  testWidgets('Mudar status oferece só os próximos permitidos', (tester) async {
    final repositorio = await abrirDetalhe(tester, StatusOs.emAndamento);

    await tester.tap(find.text('Mudar status'));
    await tester.pumpAndSettle();

    expect(find.text('Pronta p/ retirar'), findsOneWidget);
    expect(find.text('Em análise'), findsNothing);

    await tester.tap(find.text('Pronta p/ retirar'));
    await tester.pumpAndSettle();

    expect(repositorio.statusAlterado, StatusOs.pronta);
    expect(repositorio.motivo, isNull);
  });

  testWidgets('Cancelar exige o motivo', (tester) async {
    final repositorio = await abrirDetalhe(tester, StatusOs.aberta);

    await tester.tap(find.text('Mudar status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelada'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirmar cancelamento'));
    await tester.pumpAndSettle();
    expect(find.text('Preencha este campo.'), findsOneWidget);
    expect(repositorio.statusAlterado, isNull);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Motivo'),
      'Cliente desistiu do reparo',
    );
    await tester.tap(find.text('Confirmar cancelamento'));
    await tester.pumpAndSettle();

    expect(repositorio.statusAlterado, StatusOs.cancelada);
    expect(repositorio.motivo, 'Cliente desistiu do reparo');
  });

  testWidgets('Adicionar item com a máscara de moeda', (tester) async {
    final repositorio = await abrirDetalhe(tester, StatusOs.emAnalise);

    await tester.ensureVisible(find.text('Adicionar item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Peça'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descrição *'),
      'Película de vidro',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Valor unitário *'),
      '3000',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final item = repositorio.itemSalvo!;
    expect(item.id, isNull);
    expect(item.tipo, 'peca');
    expect(item.descricao, 'Película de vidro');
    expect(item.quantidade, 1);
    expect(item.valorUnitario, 30);
  });

  testWidgets('OS entregue não permite mexer no orçamento', (tester) async {
    await abrirDetalhe(tester, StatusOs.entregue);

    expect(find.text('Adicionar item'), findsNothing);
    expect(find.byTooltip('Editar diagnóstico'), findsNothing);
  });
}
