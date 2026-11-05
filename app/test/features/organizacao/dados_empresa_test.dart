import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/features/organizacao/domain/dados_empresa.dart';
import 'package:geraos/features/organizacao/domain/membro_atual.dart';

import '../../helpers/app_teste.dart';

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

Future<OrganizacaoRepositoryFalso> abrirDadosEmpresa(
  WidgetTester tester,
  MembroAtual membro,
) async {
  final repositorio = OrganizacaoRepositoryFalso();
  await montarApp(
    tester,
    EstadoAutenticacaoFalso(logado: true),
    organizacao: EstadoOrganizacaoFalso(membro: membro),
    organizacaoRepository: repositorio,
  );
  await tester.tap(find.text('Mais'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('TecFix Assistência'));
  await tester.pumpAndSettle();
  return repositorio;
}

void main() {
  test('DadosEmpresa grava os vazios como null', () {
    const dados = DadosEmpresa(nome: 'TecFix Assistência');
    final json = dados.paraJson();

    expect(json['nome'], 'TecFix Assistência');
    expect(json.containsKey('telefone'), isTrue);
    expect(json['telefone'], isNull);
  });

  testWidgets('O administrador salva os dados da empresa', (tester) async {
    final repositorio = await abrirDadosEmpresa(tester, _admin);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Telefone / WhatsApp'),
      '7132341180',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'CNPJ ou CPF'),
      '12345678000199',
    );
    await tester.ensureVisible(find.text('Usar texto sugerido'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usar texto sugerido'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Salvar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final salvos = repositorio.dadosSalvos!;
    expect(salvos.telefone, '+557132341180');
    expect(salvos.documento, '12345678000199');
    expect(salvos.termosGarantia, contains('90 dias'));
  });

  testWidgets('O técnico só consulta os dados da empresa (RN002)', (
    tester,
  ) async {
    await abrirDadosEmpresa(tester, _tecnico);

    expect(
      find.text('Só administradores podem alterar os dados da empresa.'),
      findsOneWidget,
    );
    expect(find.text('Salvar'), findsNothing);
    expect(find.text('Usar texto sugerido'), findsNothing);
  });
}
