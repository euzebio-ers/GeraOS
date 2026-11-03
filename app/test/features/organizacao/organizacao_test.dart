import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/features/organizacao/data/estado_organizacao.dart';
import 'package:geraos/features/organizacao/domain/membro_atual.dart';

import '../../helpers/app_teste.dart';

void main() {
  test('MembroAtual é montado a partir da resposta do banco', () {
    final membro = MembroAtual.deJson({
      'id': 'm1',
      'nome': 'Euzébio Souza',
      'papel': 'administrador',
      'organizacao': {'id': 'o1', 'nome': 'TecFix Assistência'},
    });

    expect(membro.nome, 'Euzébio Souza');
    expect(membro.ehAdmin, isTrue);
    expect(membro.nomeOrganizacao, 'TecFix Assistência');
  });

  testWidgets('Sem os dados do cadastro, pede o nome da empresa', (
    tester,
  ) async {
    final repositorio = OrganizacaoRepositoryFalso();
    await montarApp(
      tester,
      EstadoAutenticacaoFalso(logado: true),
      organizacao: EstadoOrganizacaoFalso(
        situacao: SituacaoOrganizacao.semOrganizacao,
      ),
      organizacaoRepository: repositorio,
    );

    expect(find.text('Começar a usar'), findsOneWidget);
    expect(repositorio.organizacaoCriada, isNull);
  });

  testWidgets('Com os dados do cadastro, cria a empresa sozinho', (
    tester,
  ) async {
    final repositorio = OrganizacaoRepositoryFalso(
      nome: 'Euzébio Souza',
      nomeOrganizacao: 'TecFix Assistência',
    );
    final organizacao = EstadoOrganizacaoFalso(
      situacao: SituacaoOrganizacao.semOrganizacao,
    );
    await montarApp(
      tester,
      EstadoAutenticacaoFalso(logado: true),
      organizacao: organizacao,
      organizacaoRepository: repositorio,
    );

    expect(repositorio.organizacaoCriada, 'TecFix Assistência');
    expect(organizacao.recarregamentos, 1);
    expect(find.text('Ordens de Serviço'), findsOneWidget);
  });

  testWidgets('Erro ao carregar permite tentar de novo', (tester) async {
    final organizacao = EstadoOrganizacaoFalso(
      situacao: SituacaoOrganizacao.erro,
    );
    await montarApp(
      tester,
      EstadoAutenticacaoFalso(logado: true),
      organizacao: organizacao,
    );

    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(organizacao.recarregamentos, 1);
    expect(find.text('Ordens de Serviço'), findsOneWidget);
  });
}
