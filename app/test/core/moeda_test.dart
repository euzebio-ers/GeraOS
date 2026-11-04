import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/core/formatting/moeda.dart';

void main() {
  final mascara = MascaraMoeda();

  TextEditingValue digitar(String texto) => mascara.formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(text: texto),
  );

  test('os centavos entram pela direita', () {
    expect(digitar('1').text, '0,01');
    expect(digitar('15').text, '0,15');
    expect(digitar('150').text, '1,50');
    expect(digitar('15000').text, '150,00');
    expect(digitar('150000').text, '1.500,00');
    expect(digitar('123456789').text, '1.234.567,89');
  });

  test('apagar um dígito desfaz na ordem inversa', () {
    expect(digitar('150,0').text, '15,00');
    expect(digitar('0,1').text, '0,01');
  });

  test('campo vazio continua vazio, para mostrar "a orçar"', () {
    expect(digitar('').text, '');
    expect(digitar('0').text, '');
  });

  test('o valor da máscara é entendido na hora de salvar', () {
    expect(textoParaValor(digitar('150000').text), 1500);
  });
}
