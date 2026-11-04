import 'package:flutter/material.dart';

import '../../../../core/theme/cores_geraos.dart';

/// Cartão de destaque da tela Início, que abre a gravação por áudio.
class CartaoGravarOs extends StatelessWidget {
  const CartaoGravarOs({super.key, required this.onTap, this.suave = false});

  final VoidCallback onTap;

  /// TEMPORÁRIO: versão clara do cartão, só para comparar no tema claro.
  /// Será removida depois da escolha.
  final bool suave;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final esquema = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final usarSuave = suave && !escuro;

    final fundo = usarSuave
        ? esquema.primaryContainer
        : cores.cartaoGravarFundo;
    final texto = usarSuave
        ? esquema.onPrimaryContainer
        : cores.cartaoGravarTexto;
    final subtexto = usarSuave
        ? esquema.onSurfaceVariant
        : cores.cartaoGravarSubtexto;

    return Semantics(
      button: true,
      label: 'Gravar nova OS por áudio',
      excludeSemantics: true,
      child: Material(
        color: fundo,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: escuro
              ? BorderSide(color: esquema.outlineVariant)
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
                          color: texto,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fale o nome do cliente, o aparelho e o defeito.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: subtexto,
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
