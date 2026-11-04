import 'package:flutter/material.dart';

import '../../../../core/theme/cores_geraos.dart';

/// Cartão de destaque da tela Início, que abre a gravação por áudio.
class CartaoGravarOs extends StatelessWidget {
  const CartaoGravarOs({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final escuro = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Gravar nova OS por áudio',
      excludeSemantics: true,
      child: Material(
        color: cores.cartaoGravarFundo,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: escuro
              ? BorderSide(color: Theme.of(context).colorScheme.outlineVariant)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: cores.microfone,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gravar nova OS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: cores.cartaoGravarTexto,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fale o nome do cliente, o aparelho e o defeito.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: cores.cartaoGravarSubtexto,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
