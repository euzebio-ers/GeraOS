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
  desconto: 20,
  valorTotal: 360,
  itens: const [
    ItemOs(
      id: 'i1',
      tipo: 'peca',
      descricao: 'Tela (conjunto)',
      quantidade: 1,
      valorUnitario: 320,
    ),
    ItemOs(
      id: 'i2',
      tipo: 'servico',
      descricao: 'Mão de obra',
      quantidade: 1,
      valorUnitario: 60,
    ),
  ],
);

Future<void> _abrirDetalhe(WidgetTester tester, StatusOs status) async {
  final detalhe = _os(status);
  await montarApp(
    tester,
    EstadoAutenticacaoFalso(logado: true),
    ordensServicoRepository: OrdensServicoRepositoryFalso(
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
    ),
  );
  await tester.tap(find.text('Ordens'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Marina Costa'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Itens, desconto e diagnóstico mostram o lápis', (tester) async {
    await _abrirDetalhe(tester, StatusOs.emAnalise);

    expect(find.byIcon(Icons.edit_outlined), findsNWidgets(4));
  });

  testWidgets('OS entregue não mostra lápis em nada', (tester) async {
    await _abrirDetalhe(tester, StatusOs.entregue);

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });
}
