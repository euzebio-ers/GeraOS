import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/features/ordens_servico/domain/os_detalhe.dart';
import 'package:geraos/features/ordens_servico/domain/os_resumo.dart';
import 'package:geraos/features/ordens_servico/domain/status_os.dart';

import '../../helpers/app_teste.dart';

final _json = <String, dynamic>{
  'id': 'os-1',
  'numero': 127,
  'status': 'em_andamento',
  'equipamento': 'iPhone 12 · 128 GB · preto',
  'descricao_problema': 'Tela trincada após queda.',
  'diagnostico': 'Troca do conjunto de tela.',
  'acessorios': 'Capinha',
  'desconto': 0,
  'valor_total': 380,
  'previsao_entrega': null,
  'origem': 'audio',
  'criado_em': '2026-11-04T11:05:00+00:00',
  'entregue_em': null,
  'criado_por_nome': 'Euzébio Souza',
  'cliente': {
    'id': 'c1',
    'nome': 'Marina Costa',
    'telefone': '+5571992341180',
    'email': null,
    'quantidade_os': 3,
  },
  'itens': [
    {
      'id': 'i1',
      'tipo': 'peca',
      'descricao': 'Tela (conjunto)',
      'quantidade': 1,
      'valor_unitario': 320,
    },
    {
      'id': 'i2',
      'tipo': 'servico',
      'descricao': 'Mão de obra',
      'quantidade': 1,
      'valor_unitario': 60,
    },
  ],
  'historico': [
    {
      'status_anterior': 'em_analise',
      'status_novo': 'em_andamento',
      'observacao': null,
      'alterado_em': '2026-11-04T11:40:00+00:00',
      'alterado_por_nome': 'Euzébio Souza',
    },
    {
      'status_anterior': null,
      'status_novo': 'aberta',
      'observacao': null,
      'alterado_em': '2026-11-04T11:05:00+00:00',
      'alterado_por_nome': 'Euzébio Souza',
    },
  ],
};

Future<void> abrirDetalhe(WidgetTester tester, OsDetalhe detalhe) async {
  await montarApp(
    tester,
    EstadoAutenticacaoFalso(logado: true),
    ordensServicoRepository: OrdensServicoRepositoryFalso(
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
    ),
  );
  await tester.tap(find.text('Ordens'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(detalhe.cliente.nome));
  await tester.pumpAndSettle();
}

void main() {
  test('OsDetalhe é montado a partir da função do banco', () {
    final os = OsDetalhe.deJson(_json);

    expect(os.cliente.nome, 'Marina Costa');
    expect(os.itens.length, 2);
    expect(os.itens.first.total, 320);
    expect(os.historico.first.statusAnterior, StatusOs.emAnalise);
    expect(os.historico.last.statusAnterior, isNull);
  });

  testWidgets('Tocar num cartão abre o detalhe completo da OS', (tester) async {
    await abrirDetalhe(tester, OsDetalhe.deJson(_json));

    expect(find.text('OS #0127'), findsOneWidget);
    expect(find.text('Tela (conjunto)'), findsOneWidget);
    expect(find.text('R\$\u00A0380,00'), findsOneWidget);
    expect(find.text('Em análise → Em andamento'), findsOneWidget);
    expect(find.text('OS criada por áudio'), findsOneWidget);
  });

  testWidgets('OS cancelada mostra o aviso no lugar das etapas', (
    tester,
  ) async {
    await abrirDetalhe(
      tester,
      OsDetalhe.deJson({..._json, 'status': 'cancelada'}),
    );

    expect(find.text('Esta OS foi cancelada.'), findsOneWidget);
  });
}
