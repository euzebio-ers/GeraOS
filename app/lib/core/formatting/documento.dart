import 'telefone.dart';

/// CPF ou CNPJ formatado: "12345678000199" → "12.345.678/0001-99".
String formatarDocumento(String documento) {
  final d = apenasDigitos(documento);
  if (d.length == 11) {
    return '${d.substring(0, 3)}.${d.substring(3, 6)}.'
        '${d.substring(6, 9)}-${d.substring(9)}';
  }
  if (d.length == 14) {
    return '${d.substring(0, 2)}.${d.substring(2, 5)}.${d.substring(5, 8)}/'
        '${d.substring(8, 12)}-${d.substring(12)}';
  }
  return documento;
}

/// "CNPJ 12.345.678/0001-99" ou "CPF 123.456.789-01".
String documentoComRotulo(String documento) {
  final tipo = apenasDigitos(documento).length == 14 ? 'CNPJ' : 'CPF';
  return '$tipo ${formatarDocumento(documento)}';
}
