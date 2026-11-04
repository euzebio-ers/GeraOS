import 'package:flutter/material.dart';

import '../../domain/status_os.dart';

/// Mostra os próximos status permitidos e devolve o escolhido,
/// ou `null` se a pessoa fechar sem escolher.
Future<StatusOs?> escolherStatus(
  BuildContext context, {
  required StatusOs atual,
  required bool podeReabrir,
}) {
  return showModalBottomSheet<StatusOs>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final tema = Theme.of(context);

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text('Mudar status', style: tema.textTheme.titleLarge),
            ),
            for (final status in atual.proximos)
              ListTile(
                leading: Icon(
                  status == StatusOs.cancelada
                      ? Icons.cancel_outlined
                      : Icons.arrow_forward_rounded,
                ),
                title: Text(status.rotuloDetalhado),
                subtitle: status == StatusOs.cancelada
                    ? const Text('Exige o motivo do cancelamento')
                    : null,
                onTap: () => Navigator.of(context).pop(status),
              ),
            if (atual == StatusOs.entregue && podeReabrir)
              ListTile(
                leading: const Icon(Icons.replay_rounded),
                title: const Text('Reabrir (retorno em garantia)'),
                subtitle: const Text('Volta para Em análise. Exige o motivo.'),
                onTap: () => Navigator.of(context).pop(StatusOs.emAnalise),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
