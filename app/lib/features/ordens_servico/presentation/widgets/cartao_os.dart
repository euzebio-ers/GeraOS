import 'package:flutter/material.dart';

import '../../../../core/formatting/datas.dart';
import '../../../../core/formatting/moeda.dart';
import '../../../../core/theme/estilos.dart';
import '../../domain/formatos_os.dart';
import '../../domain/os_resumo.dart';
import 'etiqueta_status.dart';

/// Cartão de uma OS nas listas (aba Ordens e Início).
class CartaoOs extends StatelessWidget {
  const CartaoOs({
    super.key,
    required this.os,
    this.aoTocar,
    this.selecionado = false,
  });

  final OsResumo os;
  final VoidCallback? aoTocar;

  /// Destaca o cartão da OS que está aberta ao lado, no computador.
  final bool selecionado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final borda = BorderSide(color: tema.colorScheme.primary, width: 2);
    final formaDoTema = tema.cardTheme.shape;
    final forma = formaDoTema is RoundedRectangleBorder
        ? formaDoTema.copyWith(side: borda)
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borda,
          );

    return Semantics(
      selected: selecionado,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: selecionado ? forma : null,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${formatarNumeroOs(os.numero)} · '
                        '${dataHoraCurta(os.criadoEm)}',
                        style: context.estiloNumeroOs,
                      ),
                    ),
                    EtiquetaStatus(os.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  os.clienteNome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        os.equipamento,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      os.aOrcar ? 'a orçar' : formatarMoeda(os.valorTotal),
                      style: tema.textTheme.titleSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
