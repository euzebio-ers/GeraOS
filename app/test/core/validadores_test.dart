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

  group('Validadores.senhaCadastro', () {
    test('recusa senha curta', () {
      expect(
        Validadores.senhaCadastro('abc12'),
        'A senha deve ter pelo menos 8 caracteres.',
      );
    });

    test('recusa senha só com letras', () {
      expect(
        Validadores.senhaCadastro('abcdefgh'),
        'Use letras e números na senha.',
      );
    });

    test('aceita senha com letras acentuadas e números', () {
      expect(Validadores.senhaCadastro('coração2026'), isNull);
    });
  });

  group('Validadores.confirmacaoSenha', () {
    test('recusa quando as senhas são diferentes', () {
      final validar = Validadores.confirmacaoSenha(() => 'senha123');
      expect(validar('senha124'), 'As senhas não conferem.');
    });

    test('aceita quando as senhas são iguais', () {
      final validar = Validadores.confirmacaoSenha(() => 'senha123');
      expect(validar('senha123'), isNull);
    });
  });

  group('Validadores.nomeOrganizacao', () {
    test('recusa nome vazio', () {
      expect(Validadores.nomeOrganizacao(' '), 'Informe o nome da empresa.');
    });
  });

  group('Validadores de cliente', () {
    test('telefone opcional aceita vazio e recusa número incompleto', () {
      expect(Validadores.telefoneOpcional(''), isNull);
      expect(Validadores.telefoneOpcional('(71) 99234-1180'), isNull);
      expect(Validadores.telefoneOpcional('(71) 9923'), isNotNull);
    });

    test('documento aceita CPF ou CNPJ, só pela quantidade de dígitos', () {
      expect(Validadores.documento(''), isNull);
      expect(Validadores.documento('12345678901'), isNull);
      expect(Validadores.documento('12345678000199'), isNull);
      expect(Validadores.documento('123'), isNotNull);
    });
  });
}
