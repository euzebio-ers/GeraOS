import '../formatting/telefone.dart';

/// Regras de validação dos formulários.
///
/// Cada função devolve a mensagem de erro, ou `null` quando o valor é válido,
/// que é o formato esperado pelo `validator` do `TextFormField`.
abstract final class Validadores {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Informe o e-mail.';
    if (!_email.hasMatch(texto)) return 'E-mail inválido.';
    return null;
  }

  static String? senhaLogin(String? valor) {
    if (valor == null || valor.isEmpty) return 'Informe a senha.';
    return null;
  }

  static final _letra = RegExp(r'[A-Za-zÀ-ÿ]');
  static final _numero = RegExp(r'\d');

  static String? nome(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.length < 2) return 'Informe seu nome.';
    if (texto.length > 120) return 'O nome deve ter no máximo 120 caracteres.';
    return null;
  }

  static String? nomeOrganizacao(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.length < 2) return 'Informe o nome da empresa.';
    if (texto.length > 120) {
      return 'O nome da empresa deve ter no máximo 120 caracteres.';
    }
    return null;
  }

  static String? nomeCliente(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.length < 2) return 'Informe o nome do cliente.';
    if (texto.length > 150) return 'O nome deve ter no máximo 150 caracteres.';
    return null;
  }

  static String? telefoneOpcional(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    return telefoneParaE164(valor) == null
        ? 'Telefone inválido. Informe o DDD e o número.'
        : null;
  }

  static String? emailOpcional(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    return email(valor);
  }

  static String? documento(String? valor) {
    final digitos = apenasDigitos(valor ?? '');
    if (digitos.isEmpty) return null;
    if (digitos.length != 11 && digitos.length != 14) {
      return 'Informe um CPF (11 dígitos) ou um CNPJ (14 dígitos).';
    }
    return null;
  }

  static String? senhaCadastro(String? valor) {
    final senha = valor ?? '';
    if (senha.length < 8) return 'A senha deve ter pelo menos 8 caracteres.';
    if (!_letra.hasMatch(senha) || !_numero.hasMatch(senha)) {
      return 'Use letras e números na senha.';
    }
    return null;
  }

  /// Confere se a confirmação é igual à senha digitada no outro campo.
  static String? Function(String?) confirmacaoSenha(String Function() senha) {
    return (valor) => valor == senha() ? null : 'As senhas não conferem.';
  }
}
