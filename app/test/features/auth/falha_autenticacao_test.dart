import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/features/auth/domain/falha_autenticacao.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('credenciais inválidas viram mensagem genérica', () {
    final falha = FalhaAutenticacao.de(
      const AuthException(
        'Invalid login credentials',
        code: 'invalid_credentials',
      ),
    );
    expect(falha.mensagem, 'E-mail ou senha inválidos.');
  });

  test('e-mail já cadastrado não confirma que a conta existe', () {
    final falha = FalhaAutenticacao.de(
      const AuthException(
        'User already registered',
        code: 'user_already_exists',
      ),
    );
    expect(falha.mensagem, contains('Se você já tem conta'));
  });

  test('erro desconhecido usa a mensagem padrão informada', () {
    final falha = FalhaAutenticacao.de(
      const AuthException('Algo inesperado', code: 'codigo_novo'),
      padrao: 'Não foi possível criar a conta. Tente novamente.',
    );
    expect(falha.mensagem, 'Não foi possível criar a conta. Tente novamente.');
  });
}
