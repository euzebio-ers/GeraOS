import 'package:flutter/material.dart';

import '../theme/cores_geraos.dart';

/// Círculo com as iniciais de uma pessoa: "Euzébio Souza" → "ES".
class AvatarIniciais extends StatelessWidget {
  const AvatarIniciais({super.key, required this.nome, this.tamanho = 44});

  final String nome;
  final double tamanho;

  /// Primeira letra do primeiro e do último nome.
  static String iniciais(String nome) {
    final partes = nome
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList();
    if (partes.isEmpty) return '?';

    final primeira = partes.first[0];
    final ultima = partes.length > 1 ? partes.last[0] : '';
    return (primeira + ultima).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final paleta = [
      cores.aguardandoAprovacao,
      cores.emAndamento,
      cores.pendente,
      cores.pronta,
    ];

    // A mesma pessoa sempre recebe a mesma cor.
    final soma = nome.codeUnits.fold<int>(0, (total, letra) => total + letra);
    final cor = paleta[soma % paleta.length];

    return ExcludeSemantics(
      child: Container(
        width: tamanho,
        height: tamanho,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: cor.fundo, shape: BoxShape.circle),
        child: Text(
          iniciais(nome),
          style: TextStyle(
            fontSize: tamanho * 0.36,
            fontWeight: FontWeight.w800,
            color: cor.texto,
          ),
        ),
      ),
    );
  }
}
