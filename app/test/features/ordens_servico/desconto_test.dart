import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/features/ordens_servico/domain/os_detalhe.dart';
import 'package:geraos/features/ordens_servico/domain/os_resumo.dart';
import 'package:geraos/features/ordens_servico/domain/status_os.dart';
import 'package:geraos/features/ordens_servico/presentation/widgets/dialogo_desconto.dart';

import '../../helpers/app_teste.dart';

OsDetalhe _os({double desconto = 0, double? descontoPercentual}) => OsDetalhe(
  id: 'os-1',
  numero: 127,
  status: StatusOs.emAnalise,
  equipamento: 'iPhone 12',
  descricaoProblema: 'Tela trincada.',
  criadoEm: DateTime(2026, 11, 4, 11, 5),
  cliente: const ClienteDaOs(id: 'c1', nome: 'Marina Costa'),
  desconto: desconto,
  descontoPercentual: descontoPercentual,
  valorTotal: 300 - desconto,
  itens: const [
    ItemOs(
      id: 'i1',
      tipo: 'peca',
      descricao: 'Tela (conjunto)',
      quantidade: 1,
      valorUnitario: 300,
    ),
  ],
);

/// Abre o detalhe da OS pela lista e devolve o repositório falso.
Future<OrdensServicoRepositoryFalso> abrirDetalhe(
  WidgetTester tester,
  OsDetalhe detalhe,
) async {
  final repositorio = OrdensServicoRepositoryFalso(
    ordens: [
      OsResumo(
        id: detalhe.id,
        numero: detalhe.numero,
        status: detalhe.status,
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

/// Toca em "Dar desconto", que fica no fim do orçamento.
Future<void> abrirJanelaDesconto(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Dar desconto'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Dar desconto'));
  await tester.pumpAndSettle();
}

void main() {
  test('A porcentagem aparece sem casas decimais desnecessárias', () {
    expect(formatarPercentual(10), '10%');
    expect(formatarPercentual(12.5), '12,5%');
  });

  test('O subtotal é a soma dos itens, antes do desconto', () {
    expect(_os(desconto: 30).subtotal, 300);
  });

  testWidgets('Desconto em porcentagem mostra o valor e é salvo como %', (
    tester,
  ) async {
    final repositorio = await abrirDetalhe(tester, _os());
    await abrirJanelaDesconto(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Porcentagem de desconto'),
      '10',
    );
    await tester.pump();

    expect(find.textContaining('Desconto de R\$\u00A030,00'), findsOneWidget);

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(repositorio.percentualSalvo, 10);
    expect(repositorio.descontoSalvo, isNull);
  });

  testWidgets('Desconto em reais continua funcionando', (tester) async {
    final repositorio = await abrirDetalhe(tester, _os());
    await abrirJanelaDesconto(tester);

    await tester.tap(find.text('R\$'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Valor do desconto'),
      '2000',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(repositorio.descontoSalvo, 20);
    expect(repositorio.percentualSalvo, isNull);
  });

  testWidgets('Porcentagem acima de 100% é recusada', (tester) async {
    final repositorio = await abrirDetalhe(tester, _os());
    await abrirJanelaDesconto(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Porcentagem de desconto'),
      '150',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Use no máximo 100%.'), findsOneWidget);
    expect(repositorio.percentualSalvo, isNull);
  });

  testWidgets('O orçamento mostra a porcentagem ao lado do desconto', (
    tester,
  ) async {
    await abrirDetalhe(tester, _os(desconto: 30, descontoPercentual: 10));

    await tester.ensureVisible(find.text('Desconto (10%)'));
    expect(find.text('Desconto (10%)'), findsOneWidget);
  });
}
