/// Data curta e relativa a hoje: "hoje", "ontem", "28/10" ou "28/10/25".
String dataRelativa(DateTime data, {DateTime? agora}) {
  final hoje = _dia(agora ?? DateTime.now());
  final dia = _dia(data.toLocal());
  final diferenca = hoje.difference(dia).inDays;

  if (diferenca == 0) return 'hoje';
  if (diferenca == 1) return 'ontem';

  final dd = dia.day.toString().padLeft(2, '0');
  final mm = dia.month.toString().padLeft(2, '0');
  if (dia.year == hoje.year) return '$dd/$mm';
  return '$dd/$mm/${(dia.year % 100).toString().padLeft(2, '0')}';
}

/// Só a data, sem horário, para comparar dias inteiros.
DateTime _dia(DateTime data) => DateTime.utc(data.year, data.month, data.day);

/// Data e hora curtas para os cartões de OS: "hoje 14:32", "ontem", "28/10".
String dataHoraCurta(DateTime data, {DateTime? agora}) {
  final relativa = dataRelativa(data, agora: agora);
  if (relativa != 'hoje') return relativa;

  final local = data.toLocal();
  final hora = local.hour.toString().padLeft(2, '0');
  final minuto = local.minute.toString().padLeft(2, '0');
  return 'hoje $hora:$minuto';
}
