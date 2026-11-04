import 'package:flutter/material.dart';

import '../../../../core/theme/cores_geraos.dart';
import '../../domain/status_os.dart';

/// Etiqueta colorida com o nome do status da OS.
class EtiquetaStatus extends StatelessWidget {
  const EtiquetaStatus(this.status, {super.key});

  final StatusOs status;

  @override
  Widget build(BuildContext context) {
    final cor = status.cor(context.cores);

    return Semantics(
      label: 'Status: ${status.rotulo}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cor.fundo,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            status.rotulo,
            maxLines: 1,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: cor.texto,
            ),
          ),
        ),
      ),
    );
  }
}
