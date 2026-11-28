import 'package:flutter/material.dart';

import 'topicos_ajuda.dart';

/// O botão "i": abre a explicação de um assunto da tela.
class BotaoAjuda extends StatelessWidget {
  const BotaoAjuda(this.topico, {super.key});

  final TopicoAjuda topico;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Ajuda: ${topico.titulo}',
      visualDensity: VisualDensity.compact,
      iconSize: 20,
      color: Theme.of(context).colorScheme.primary,
      onPressed: () => mostrarAjuda(context, topico),
      icon: const Icon(Icons.info_outline_rounded),
    );
  }
}

/// Mostra a explicação de um assunto num painel que sobe da parte de baixo.
Future<void> mostrarAjuda(BuildContext context, TopicoAjuda topico) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final tema = Theme.of(context);

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: tema.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      topico.titulo,
                      style: tema.textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (final paragrafo in topico.paragrafos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(paragrafo, style: tema.textTheme.bodyLarge),
                ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(120, 44),
                  ),
                  child: const Text('Entendi'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
