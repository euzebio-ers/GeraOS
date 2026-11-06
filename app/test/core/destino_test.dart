import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/core/router/destino.dart';

void main() {
  test('Aceita destinos internos do app', () {
    expect(destinoSeguro('/os?os=7f3a'), '/os?os=7f3a');
    expect(destinoSeguro('/clientes/123'), '/clientes/123');
    expect(destinoSeguro('/mais/empresa'), '/mais/empresa');
  });

  test('Recusa destinos externos e telas de entrada', () {
    expect(destinoSeguro(null), isNull);
    expect(destinoSeguro('https://site-falso.com'), isNull);
    expect(destinoSeguro('//site-falso.com'), isNull);
    expect(destinoSeguro('/login'), isNull);
    expect(destinoSeguro('/preparando?de=/os'), isNull);
    expect(destinoSeguro('/inicio'), isNull);
  });
}
