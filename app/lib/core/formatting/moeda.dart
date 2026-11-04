import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final _formatoReal = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

/// Valor para exibir: 1500.5 → "R$ 1.500,50".
String formatarMoeda(num valor) => _formatoReal.format(valor);

/// Converte o valor digitado para número: "1.500,50" → 1500.5.
///
/// Aceita "150", "150,00", "R$ 1.500,50" e "1.500" (milhar com ponto).
/// Devolve `null` se o texto não for um valor válido.
double? textoParaValor(String texto) {
  var limpo = texto.replaceAll(RegExp(r'[R$\s]'), '');
  if (limpo.isEmpty) return null;

  if (limpo.contains(',')) {
    limpo = limpo.replaceAll('.', '').replaceAll(',', '.');
  } else if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(limpo)) {
    limpo = limpo.replaceAll('.', '');
  }

  final valor = double.tryParse(limpo);
  if (valor == null) return null;
  return (valor * 100).round() / 100;
}

/// Formata o valor enquanto se digita, com os centavos entrando pela
/// direita: "1" → "0,01", "15000" → "150,00", "150000" → "1.500,00".
class MascaraMoeda extends TextInputFormatter {
  /// 12 dígitos: até 9.999.999.999,99, o limite do banco (numeric(12,2)).
  static const _maximoDigitos = 12;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue novo,
  ) {
    var digitos = novo.text.replaceAll(RegExp(r'\D'), '');
    digitos = digitos.replaceFirst(RegExp(r'^0+'), '');
    if (digitos.length > _maximoDigitos) {
      digitos = digitos.substring(0, _maximoDigitos);
    }

    if (digitos.isEmpty) return TextEditingValue.empty;

    final centavosTotais = int.parse(digitos);
    final reais = centavosTotais ~/ 100;
    final centavos = (centavosTotais % 100).toString().padLeft(2, '0');
    final texto = '${_comPontoDeMilhar(reais)},$centavos';

    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  /// 1500000 → "1.500.000".
  static String _comPontoDeMilhar(int valor) {
    final numero = valor.toString();
    final resultado = StringBuffer();
    for (var i = 0; i < numero.length; i++) {
      final faltam = numero.length - i;
      if (i > 0 && faltam % 3 == 0) resultado.write('.');
      resultado.write(numero[i]);
    }
    return resultado.toString();
  }
}
