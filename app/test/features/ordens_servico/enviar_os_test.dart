import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/features/ordens_servico/domain/mensagem_os.dart';
import 'package:geraos/features/ordens_servico/domain/os_detalhe.dart';
import 'package:geraos/features/ordens_servico/domain/os_resumo.dart';
import 'package:geraos/features/ordens_servico/domain/status_os.dart';

import '../../helpers/app_teste.dart';

OsDetalhe _os(StatusOs status, {String? telefone = '+5571992341180'}) =>
    OsDetalhe(
      id: 'os-1',
      numero: 127,
      status: status,
      equipamento: 'iPhone 12',
      descricaoProblema: 'Tela trincada.',
      valorTotal: 380,
      criadoEm: DateTime(2026, 11, 4, 11, 5),
      cliente: ClienteDaOs(id: 'c1', nome: 'Marina Costa', telefone: telefone),
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
  await tester.tap(find.text('Marina Costa'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Enviar OS'));
  await tester.pumpAndSettle();
}

void main() {
  test(
    'A mensagem chama o cliente pelo primeiro nome e assina pela empresa',
    () {
      final texto = mensagemWhatsApp(
        _os(StatusOs.emAndamento),
        empresa: 'TecFix Assistência',
      );

      expect(texto, startsWith('Olá, Marina!'));
      expect(texto, contains('#0127'));
      expect(texto, endsWith('TecFix Assistência'));
    },
  );

  test('Aguardando aprovação mostra o orçamento item a item', () {
    final texto = mensagemWhatsApp(
      _os(StatusOs.aguardandoAprovacao),
      empresa: 'TecFix Assistência',
    );

    expect(texto, contains('• Tela (conjunto): R\$\u00A0320,00'));
    expect(texto, contains('*Total: R\$\u00A0380,00*'));
    expect(texto, contains('Podemos seguir com o serviço?'));
  });

  test('Pronta avisa a retirada com o valor', () {
    final texto = mensagemWhatsApp(
      _os(StatusOs.pronta),
      empresa: 'TecFix Assistência',
    );

    expect(texto, contains('pronto para retirada'));
    expect(texto, contains('R\$\u00A0380,00'));
  });

  testWidgets('Enviar OS oferece o WhatsApp com a mensagem pronta', (
    tester,
  ) async {
    await abrirDetalhe(tester, _os(StatusOs.pronta));

    expect(find.text('PDF da OS'), findsOneWidget);
    await tester.tap(find.text('Mensagem no WhatsApp'));
    await tester.pumpAndSettle();

    expect(find.text('Mensagem para Marina'), findsOneWidget);
    expect(find.textContaining('pronto para retirada'), findsOneWidget);
    expect(find.text('Abrir WhatsApp'), findsOneWidget);
  });

  testWidgets('Sem telefone, a opção do WhatsApp fica desativada', (
    tester,
  ) async {
    await abrirDetalhe(tester, _os(StatusOs.pronta, telefone: null));

    final opcao = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Mensagem no WhatsApp'),
    );
    expect(opcao.enabled, isFalse);
    expect(find.text('O cliente não tem telefone cadastrado'), findsOneWidget);
  });
}
