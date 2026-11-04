import 'package:flutter/services.dart';

/// Só os dígitos de um texto: "(71) 99234-1180" → "71992341180".
String apenasDigitos(String texto) => texto.replaceAll(RegExp(r'\D'), '');

/// Converte o telefone digitado para o formato do banco (E.164).
///
/// Aceita números brasileiros com DDD, com ou sem o +55.
/// Devolve `null` se não for um telefone válido.
String? telefoneParaE164(String texto) {
  var digitos = apenasDigitos(texto);

  // "+55 71 99234-1180": tira o código do país para conferir o resto.
  if (digitos.length > 11 && digitos.startsWith('55')) {
    digitos = digitos.substring(2);
  }

  // DDD (2 dígitos) + número fixo (8) ou celular (9).
  if (digitos.length != 10 && digitos.length != 11) return null;
  // Nenhum DDD começa com 0.
  if (digitos.startsWith('0')) return null;
  // Celular, no Brasil, começa com 9.
  if (digitos.length == 11 && digitos[2] != '9') return null;

  return '+55$digitos';
}

/// Formata um telefone do banco para exibir: "+5571992341180" → "(71) 99234-1180".
String formatarTelefone(String e164) {
  final digitos = apenasDigitos(e164);
  // Números de outros países são mostrados como estão.
  if (!digitos.startsWith('55') || digitos.length < 12) return e164;
  return _mascarar(digitos.substring(2));
}

/// Aplica a máscara brasileira a uma sequência de dígitos (já sem o 55).
String _mascarar(String digitos) {
  if (digitos.isEmpty) return '';
  if (digitos.length <= 2) return '($digitos';

  final ddd = digitos.substring(0, 2);
  final numero = digitos.substring(2);

  // Celular (9 dígitos) quebra depois do 5º; fixo (8 dígitos), depois do 4º.
  final corte = numero.length > 8 ? 5 : 4;
  if (numero.length <= corte) return '($ddd) $numero';
  return '($ddd) ${numero.substring(0, corte)}-${numero.substring(corte)}';
}

/// Formata o telefone enquanto a pessoa digita.
class MascaraTelefone extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue novo,
  ) {
    var digitos = apenasDigitos(novo.text);
    if (digitos.length > 11 && digitos.startsWith('55')) {
      digitos = digitos.substring(2);
    }
    if (digitos.length > 11) digitos = digitos.substring(0, 11);

    final texto = _mascarar(digitos);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
