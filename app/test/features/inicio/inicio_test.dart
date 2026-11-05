import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/features/ordens_servico/domain/faturamento.dart';
import 'package:geraos/features/ordens_servico/domain/os_resumo.dart';
import 'package:geraos/features/ordens_servico/domain/status_os.dart';
import 'package:geraos/features/organizacao/domain/membro_atual.dart';

import '../../helpers/app_teste.dart';

OsResumo _os(String id, int numero, StatusOs status, String cliente) =>
    OsResumo(
      id: id,
      numero: numero,
      status: status,
      equipamento: 'Aparelho $numero',
      clienteNome: cliente,
      criadoEm: DateTime(2026, 11, 4, numero),
    );

final _ordens = [
  _os('4', 4, StatusOs.pronta, 'Roberto Alves'),
  _os('3', 3, StatusOs.emAndamento, 'Carlos Menezes'),
  _os('2', 2, StatusOs.aberta, 'João Pereira'),
  _os('1', 1, StatusOs.emAnalise, 'Fernanda Rocha'),
];

const _admin = MembroAtual(
  id: 'm1',
  nome: 'Euzébio Souza',
  ehAdmin: true,
  organizacaoId: 'o1',
  nomeOrganizacao: 'TecFix Assistência',
);

const _tecnico = MembroAtual(
  id: 'm2',
  nome: 'Rafael Moura',
  ehAdmin: false,
  organizacaoId: 'o1',
  nomeOrganizacao: 'TecFix Assistência',
);

Future<void> abrirInicio(WidgetTester tester, MembroAtual membro) async {
  await montarApp(
    tester,
    EstadoAutenticacaoFalso(logado: true),
    organizacao: EstadoOrganizacaoFalso(membro: membro),
    ordensServicoRepository: OrdensServicoRepositoryFalso(ordens: _ordens)
      ..faturamento = Faturamento(
        mes: DateTime(2026, 11),
        total: 18420,
        quantidade: 61,
      ),
  );
}

void main() {
  test('Faturamento é montado a partir da função do banco', () {
    final faturamento = Faturamento.deJson({
      'mes': '2026-11-01',
      'total': 18420,
      'quantidade': 61,
    });

    expect(faturamento.mes.month, 11);
    expect(faturamento.total, 18420);
  });

  testWidgets('Hoje na bancada mostra as quantidades', (tester) async {
    await abrirInicio(tester, _tecnico);

    expect(find.bySemanticsLabel('2 Pendentes'), findsOneWidget);
    expect(find.bySemanticsLabel('1 Em andamento'), findsOneWidget);
    expect(find.bySemanticsLabel('1 Prontas p/ retirar'), findsOneWidget);
  });

  testWidgets('Tocar num contador abre as Ordens já filtradas', (tester) async {
    await abrirInicio(tester, _tecnico);

    await tester.tap(find.text('Prontas p/ retirar'));
    await tester.pumpAndSettle();

    expect(find.text('Roberto Alves'), findsOneWidget);
    expect(find.text('Carlos Menezes'), findsNothing);
  });

  testWidgets('O administrador vê o faturamento do mês', (tester) async {
    await abrirInicio(tester, _admin);

    expect(find.text('Faturamento de novembro · só admin'), findsOneWidget);
    expect(find.text('R\$\u00A018.420,00'), findsOneWidget);
  });

  testWidgets('O técnico não vê o faturamento (RN002)', (tester) async {
    await abrirInicio(tester, _tecnico);

    expect(find.textContaining('Faturamento'), findsNothing);
  });

  testWidgets('Últimas OS mostra só as 3 mais recentes', (tester) async {
    await abrirInicio(tester, _tecnico);

    expect(find.text('Roberto Alves'), findsOneWidget);
    expect(find.text('João Pereira'), findsOneWidget);
    expect(find.text('Fernanda Rocha'), findsNothing);
  });
}
