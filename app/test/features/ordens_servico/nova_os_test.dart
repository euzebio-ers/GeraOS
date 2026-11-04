import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/core/formatting/moeda.dart';
import 'package:geraos/features/clientes/domain/cliente_resumo.dart';
import 'package:geraos/features/ordens_servico/domain/nova_os.dart';
import 'package:geraos/features/ordens_servico/domain/os_detalhe.dart';
import 'package:geraos/features/ordens_servico/domain/status_os.dart';

import '../../helpers/app_teste.dart';

/// Detalhe que o app abre depois de criar a OS.
final _detalheCriado = OsDetalhe(
  id: 'os-teste',
  numero: 42,
  status: StatusOs.aberta,
  equipamento: 'Notebook Dell',
  descricaoProblema: 'Não liga',
  criadoEm: DateTime(2026, 11, 4),
  cliente: const ClienteDaOs(id: 'c-novo', nome: 'Fernanda Rocha'),
);

/// Abre a Nova OS pelo botão "Digitar OS" da Início.
Future<OrdensServicoRepositoryFalso> abrirNovaOs(
  WidgetTester tester, {
  List<ClienteResumo> clientes = const [],
}) async {
  final repositorio = OrdensServicoRepositoryFalso(
    detalhes: {'os-teste': _detalheCriado},
  );
  await montarApp(
    tester,
    EstadoAutenticacaoFalso(logado: true),
    clientesRepository: ClientesRepositoryFalso(clientes: clientes),
    ordensServicoRepository: repositorio,
  );
  await tester.tap(find.text('Digitar OS'));
  await tester.pumpAndSettle();
  return repositorio;
}

Future<void> preencherCampo(WidgetTester tester, String rotulo, String texto) =>
    tester.enterText(find.widgetWithText(TextFormField, rotulo), texto);

/// O botão fica no fim do formulário: rola até ele antes de tocar.
Future<void> tocarCriarOs(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Criar OS'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Criar OS'));
  await tester.pumpAndSettle();
}

void main() {
  group('textoParaValor', () {
    test('entende os formatos brasileiros', () {
      expect(textoParaValor('150'), 150);
      expect(textoParaValor('150,00'), 150);
      expect(textoParaValor('R\$ 1.500,50'), 1500.5);
      expect(textoParaValor('1.500'), 1500);
    });

    test('recusa o que não é valor', () {
      expect(textoParaValor(''), isNull);
      expect(textoParaValor('abc'), isNull);
    });
  });

  test('NovaOs só envia os parâmetros preenchidos', () {
    const os = NovaOs(
      equipamento: 'iPhone 12',
      descricaoProblema: 'Tela quebrada',
      clienteId: 'c1',
    );

    final parametros = os.paraParametros();
    expect(parametros['p_cliente_id'], 'c1');
    expect(parametros.containsKey('p_cliente_nome'), isFalse);
    expect(parametros.containsKey('p_valor_estimado'), isFalse);
  });

  testWidgets('Campos obrigatórios são conferidos antes de enviar', (
    tester,
  ) async {
    final repositorio = await abrirNovaOs(tester);

    await tocarCriarOs(tester);

    expect(find.text('Informe o nome do cliente.'), findsOneWidget);
    expect(
      find.text('Informe o aparelho, a marca e o modelo.'),
      findsOneWidget,
    );
    expect(repositorio.criada, isNull);
  });

  testWidgets('OS com cliente novo e valor estimado', (tester) async {
    final repositorio = await abrirNovaOs(tester);

    await preencherCampo(tester, 'Nome completo *', 'Fernanda Rocha');
    await preencherCampo(tester, 'WhatsApp / telefone com DDD', '71984550912');
    await preencherCampo(tester, 'Aparelho, marca e modelo *', 'Notebook Dell');
    await preencherCampo(tester, 'Defeito relatado *', 'Não liga');
    await preencherCampo(tester, 'Valor estimado (R\$)', '150,00');
    await tocarCriarOs(tester);

    final os = repositorio.criada!;
    expect(os.clienteId, isNull);
    expect(os.clienteNome, 'Fernanda Rocha');
    expect(os.clienteTelefone, '+5571984550912');
    expect(os.valorEstimado, 150);
    expect(find.text('OS #0042'), findsOneWidget);
  });

  testWidgets('OS com cliente escolhido na busca', (tester) async {
    final repositorio = await abrirNovaOs(
      tester,
      clientes: const [
        ClienteResumo(
          id: 'c2',
          nome: 'Marina Costa',
          telefone: '+5571992341180',
        ),
      ],
    );

    await preencherCampo(tester, 'Nome completo *', 'Mar');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marina Costa'));
    await tester.pumpAndSettle();

    // O cliente escolhido aparece num cartão, com a opção de trocar.
    expect(find.text('Trocar'), findsOneWidget);

    await preencherCampo(tester, 'Aparelho, marca e modelo *', 'iPhone 12');
    await preencherCampo(tester, 'Defeito relatado *', 'Tela quebrada');
    await tocarCriarOs(tester);

    final os = repositorio.criada!;
    expect(os.clienteId, 'c2');
    expect(os.clienteNome, isNull);
  });
}
