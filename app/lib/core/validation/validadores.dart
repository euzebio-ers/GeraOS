import '../formatting/moeda.dart';
import '../formatting/telefone.dart';

/// Regras de validação dos formulários.
///
/// Cada função devolve a mensagem de erro, ou `null` quando o valor é válido,
/// que é o formato esperado pelo `validator` do `TextFormField`.
abstract final class Validadores {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _letra = RegExp(r'[A-Za-zÀ-ÿ]');
  static final _numero = RegExp(r'\d');

  // ===== Conta =====

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

  // ===== Cliente =====

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

  // ===== Ordem de serviço =====

  static String? equipamento(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.length < 2) return 'Informe o aparelho, a marca e o modelo.';
    if (texto.length > 200) return 'Use no máximo 200 caracteres.';
    return null;
  }

  static String? defeito(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.length < 3) return 'Descreva o defeito relatado pelo cliente.';
    if (texto.length > 2000) return 'Use no máximo 2.000 caracteres.';
    return null;
  }

  static String? valorOpcional(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    final numero = textoParaValor(valor);
    if (numero == null || numero < 0) return 'Valor inválido. Ex.: 150,00';
    return null;
  }
}
