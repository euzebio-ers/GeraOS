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
}
