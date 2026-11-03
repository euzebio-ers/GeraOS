import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/core/validation/validadores.dart';

void main() {
  group('Validadores.email', () {
    test('recusa e-mail vazio', () {
      expect(Validadores.email(''), 'Informe o e-mail.');
    });

    test('recusa e-mail sem domínio', () {
      expect(Validadores.email('maria@'), 'E-mail inválido.');
    });

    test('aceita e-mail válido, mesmo com espaços nas pontas', () {
      expect(Validadores.email('  maria@teste.com '), isNull);
    });
  });

  group('Validadores.senhaLogin', () {
    test('recusa senha vazia', () {
      expect(Validadores.senhaLogin(''), 'Informe a senha.');
    });

    test('aceita qualquer senha preenchida', () {
      expect(Validadores.senhaLogin('123'), isNull);
    });
  });
}
