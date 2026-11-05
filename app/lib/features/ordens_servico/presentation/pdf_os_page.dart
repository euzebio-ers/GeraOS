import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../organizacao/data/estado_organizacao.dart';
import '../data/ordens_servico_repository.dart';
import '../domain/formatos_os.dart';
import '../pdf/gerar_pdf_os.dart';

/// Pré-visualização do PDF da OS, com os botões de imprimir e compartilhar.
class PdfOsPage extends ConsumerWidget {
  const PdfOsPage({super.key, required this.osId});

  final String osId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final os = ref.watch(detalheOsProvider(osId));
    final empresa = ref.watch(dadosEmpresaProvider);
    final detalhe = os.value;
    final dados = empresa.value;

    final Widget corpo;
    if (os.hasError || empresa.hasError) {
      corpo = const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Não foi possível preparar o PDF. Verifique sua conexão.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (detalhe == null || dados == null) {
      corpo = const Center(child: CircularProgressIndicator());
    } else {
      corpo = PdfPreview(
        build: (formato) =>
            gerarPdfOs(os: detalhe, empresa: dados, formato: formato),
        pdfFileName: 'OS-${detalhe.numero.toString().padLeft(4, '0')}.pdf',
        initialPageFormat: PdfPageFormat.a4,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        loadingWidget: const CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          detalhe == null
              ? 'PDF da OS'
              : 'OS ${formatarNumeroOs(detalhe.numero)}',
        ),
      ),
      body: corpo,
    );
  }
}
