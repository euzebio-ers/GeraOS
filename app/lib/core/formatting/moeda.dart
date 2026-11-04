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
    // Padrão brasileiro: ponto separa milhar, vírgula separa centavos.
    limpo = limpo.replaceAll('.', '').replaceAll(',', '.');
  } else if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(limpo)) {
    // "1.500" sem vírgula: o ponto é de milhar.
    limpo = limpo.replaceAll('.', '');
  }

  final valor = double.tryParse(limpo);
  if (valor == null) return null;
  return (valor * 100).round() / 100;
}
