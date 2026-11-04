import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/core/theme/app_theme.dart';
import 'package:geraos/core/widgets/avatar_iniciais.dart';
import 'package:geraos/features/ordens_servico/domain/formatos_os.dart';
import 'package:geraos/features/ordens_servico/domain/status_os.dart';
import 'package:geraos/features/ordens_servico/presentation/widgets/etiqueta_status.dart';

void main() {
  test('Todos os status do banco são reconhecidos', () {
    const doBanco = [
      'aberta',
      'em_analise',
      'aguardando_aprovacao',
      'em_andamento',
      'pronta',
      'entregue',
      'cancelada',
    ];
    for (final valor in doBanco) {
      expect(StatusOs.doBanco(valor).valorBanco, valor);
    }
    expect(StatusOs.values.length, doBanco.length);
  });

  test('Status desconhecido gera erro claro', () {
    expect(() => StatusOs.doBanco('perdida'), throwsArgumentError);
  });

  test('Número da OS tem pelo menos 4 dígitos', () {
    expect(formatarNumeroOs(42), '#0042');
    expect(formatarNumeroOs(12345), '#12345');
  });

  test('Iniciais usam o primeiro e o último nome', () {
    expect(AvatarIniciais.iniciais('Euzébio Souza'), 'ES');
    expect(AvatarIniciais.iniciais('  ana  beatriz lima '), 'AL');
    expect(AvatarIniciais.iniciais('Maria'), 'M');
    expect(AvatarIniciais.iniciais('   '), '?');
  });

  testWidgets('Etiqueta mostra o nome do status', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro(),
        home: const Scaffold(
          body: EtiquetaStatus(StatusOs.aguardandoAprovacao),
        ),
      ),
    );

    expect(find.text('Aguardando aprovação'), findsOneWidget);
  });
}
