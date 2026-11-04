import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/core/formatting/datas.dart';
import 'package:geraos/core/formatting/telefone.dart';

void main() {
  group('telefoneParaE164', () {
    test('aceita celular e fixo, em vários formatos', () {
      expect(telefoneParaE164('(71) 99234-1180'), '+5571992341180');
      expect(telefoneParaE164('71 3234-1180'), '+557132341180');
      expect(telefoneParaE164('+55 71 99234-1180'), '+5571992341180');
    });

    test('recusa números incompletos ou impossíveis', () {
      expect(telefoneParaE164('1234'), isNull);
      expect(telefoneParaE164('(01) 99234-1180'), isNull); // DDD com 0
      expect(telefoneParaE164('(71) 89234-1180'), isNull); // celular sem 9
    });
  });

  test('formatarTelefone mostra no padrão brasileiro', () {
    expect(formatarTelefone('+5571992341180'), '(71) 99234-1180');
    expect(formatarTelefone('+557132341180'), '(71) 3234-1180');
  });

  test('a máscara formata enquanto se digita', () {
    final mascara = MascaraTelefone();
    TextEditingValue digitar(String texto) => mascara.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: texto),
    );

    expect(digitar('71').text, '(71');
    expect(digitar('7199234').text, '(71) 9923-4');
    expect(digitar('71992341180').text, '(71) 99234-1180');
    expect(digitar('5571992341180').text, '(71) 99234-1180');
  });

  test('dataRelativa usa hoje, ontem e dia/mês', () {
    final agora = DateTime(2026, 11, 4, 15);
    expect(dataRelativa(DateTime(2026, 11, 4, 9), agora: agora), 'hoje');
    expect(dataRelativa(DateTime(2026, 11, 3, 23), agora: agora), 'ontem');
    expect(dataRelativa(DateTime(2026, 10, 28), agora: agora), '28/10');
    expect(dataRelativa(DateTime(2025, 10, 28), agora: agora), '28/10/25');
  });
}
