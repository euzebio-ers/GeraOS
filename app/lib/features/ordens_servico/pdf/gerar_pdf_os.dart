import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/formatting/datas.dart';
import '../../../core/formatting/documento.dart';
import '../../../core/formatting/moeda.dart';
import '../../../core/formatting/telefone.dart';
import '../../organizacao/domain/dados_empresa.dart';
import '../domain/formatos_os.dart';
import '../domain/os_detalhe.dart';

/// As fontes do GeraOS, as mesmas do app, embutidas no PDF.
class _Fontes {
  const _Fontes({
    required this.regular,
    required this.negrito,
    required this.extraNegrito,
    required this.mono,
  });

  final pw.Font regular;
  final pw.Font negrito;
  final pw.Font extraNegrito;
  final pw.Font mono;
}

/// Carregadas uma vez só e reaproveitadas nos próximos PDFs.
Future<_Fontes>? _fontes;

Future<_Fontes> _carregarFontes() => _fontes ??= () async {
  Future<pw.Font> carregar(String arquivo) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/$arquivo.ttf'));

  return _Fontes(
    regular: await carregar('Manrope-Regular'),
    negrito: await carregar('Manrope-Bold'),
    extraNegrito: await carregar('Manrope-ExtraBold'),
    mono: await carregar('JetBrainsMono-SemiBold'),
  );
}();

final _verde = PdfColor.fromHex('#0B7A62');
final _cinza = PdfColor.fromHex('#5F676C');
final _linha = PdfColor.fromHex('#D9DCD6');

/// Gera o PDF da OS, com os dados da empresa no cabeçalho
/// e os termos de garantia no rodapé.
Future<Uint8List> gerarPdfOs({
  required OsDetalhe os,
  required DadosEmpresa empresa,
  PdfPageFormat formato = PdfPageFormat.a4,
  DateTime? geradoEm,
}) async {
  final fontes = await _carregarFontes();
  final quando = geradoEm ?? DateTime.now();
  final pequeno = pw.TextStyle(fontSize: 8, color: _cinza);

  final documento = pw.Document(
    title: 'OS ${formatarNumeroOs(os.numero)}',
    author: empresa.nome,
    creator: 'GeraOS',
  );

  documento.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: formato,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 28),
        theme: pw.ThemeData.withFont(
          base: fontes.regular,
          bold: fontes.negrito,
        ),
      ),
      footer: (contexto) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 12),
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                'Gerado pelo GeraOS em ${dataHoraCompleta(quando)}',
                style: pequeno,
              ),
            ),
            pw.Text(
              'Página ${contexto.pageNumber} de ${contexto.pagesCount}',
              style: pequeno,
            ),
          ],
        ),
      ),
      build: (contexto) => [
        _cabecalho(os, empresa, fontes),
        _secao('Cliente', [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(flex: 3, child: _campo('Nome', os.cliente.nome)),
              pw.Expanded(
                flex: 2,
                child: _campo('Telefone', switch (os.cliente.telefone) {
                  final String telefone => formatarTelefone(telefone),
                  null => '—',
                }),
              ),
              pw.Expanded(
                flex: 3,
                child: _campo('E-mail', os.cliente.email ?? '—'),
              ),
            ],
          ),
        ]),
        _secao('Equipamento', [
          _campo('Aparelho', os.equipamento),
          _campo('Defeito relatado', os.descricaoProblema),
          if (os.acessorios != null)
            _campo('Acessórios deixados', os.acessorios!),
          _campo('Diagnóstico', os.diagnostico ?? 'Ainda sem diagnóstico.'),
        ]),
        _secao('Orçamento', [
          if (os.itens.isEmpty)
            pw.Text('A orçar.', style: pw.TextStyle(color: _cinza))
          else ...[
            _tabelaItens(os),
            pw.SizedBox(height: 8),
            _totais(os),
          ],
        ]),
        if (empresa.termosGarantia != null)
          _secao('Garantia', [
            pw.Text(
              empresa.termosGarantia!,
              style: pw.TextStyle(fontSize: 8.5, color: _cinza),
            ),
          ]),
        pw.SizedBox(height: 44),
        pw.Row(
          children: [
            pw.Expanded(child: _assinatura('Assinatura do cliente')),
            pw.SizedBox(width: 32),
            pw.Expanded(child: _assinatura('Responsável pela assistência')),
          ],
        ),
      ],
    ),
  );

  return documento.save();
}

pw.Widget _cabecalho(OsDetalhe os, DadosEmpresa empresa, _Fontes fontes) {
  final contatos = [
    if (empresa.documento != null) documentoComRotulo(empresa.documento!),
    if (empresa.telefone != null) formatarTelefone(empresa.telefone!),
    if (empresa.email != null) empresa.email!,
  ];
  final detalhe = pw.TextStyle(fontSize: 9, color: _cinza);

  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 12),
    decoration: pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _verde, width: 2)),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                empresa.nome,
                style: pw.TextStyle(font: fontes.extraNegrito, fontSize: 18),
              ),
              pw.SizedBox(height: 4),
              if (contatos.isNotEmpty)
                pw.Text(contatos.join('  ·  '), style: detalhe),
              if (empresa.endereco != null)
                pw.Text(empresa.endereco!, style: detalhe),
            ],
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'ORDEM DE SERVIÇO',
              style: pw.TextStyle(
                font: fontes.negrito,
                fontSize: 8,
                color: _cinza,
                letterSpacing: 1,
              ),
            ),
            pw.Text(
              formatarNumeroOs(os.numero),
              style: pw.TextStyle(
                font: fontes.mono,
                fontSize: 22,
                color: _verde,
              ),
            ),
            pw.Text(
              'Entrada: ${dataHoraCompleta(os.criadoEm)}',
              style: detalhe,
            ),
            pw.Text('Status: ${os.status.rotulo}', style: detalhe),
            if (os.previsaoEntrega != null)
              pw.Text(
                'Previsão: ${dataCompleta(os.previsaoEntrega!)}',
                style: detalhe,
              ),
          ],
        ),
      ],
    ),
  );
}

/// Título da seção em verde e maiúsculas, seguido do conteúdo.
pw.Widget _secao(String titulo, List<pw.Widget> conteudo) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 16),
      pw.Text(
        titulo.toUpperCase(),
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 8,
          color: _verde,
          letterSpacing: 1,
        ),
      ),
      pw.SizedBox(height: 6),
      ...conteudo,
    ],
  );
}

/// Um rótulo pequeno em cinza com o valor embaixo.
pw.Widget _campo(String rotulo, String valor) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6, right: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(rotulo, style: pw.TextStyle(fontSize: 7.5, color: _cinza)),
        pw.Text(valor, style: const pw.TextStyle(fontSize: 10)),
      ],
    ),
  );
}

/// 1.0 → "1"; 1.5 → "1,5".
String _quantidade(double valor) => valor == valor.roundToDouble()
    ? valor.toInt().toString()
    : valor.toString().replaceAll('.', ',');

pw.Widget _tabelaItens(OsDetalhe os) {
  const alinhamentos = {
    2: pw.Alignment.centerRight,
    3: pw.Alignment.centerRight,
    4: pw.Alignment.centerRight,
  };

  return pw.TableHelper.fromTextArray(
    headers: ['Descrição', 'Tipo', 'Qtd.', 'Valor unit.', 'Total'],
    data: [
      for (final item in os.itens)
        [
          item.descricao,
          item.tipo == 'peca' ? 'Peça' : 'Serviço',
          _quantidade(item.quantidade),
          formatarMoeda(item.valorUnitario),
          formatarMoeda(item.total),
        ],
    ],
    border: null,
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 8.5,
      color: PdfColors.white,
    ),
    headerDecoration: pw.BoxDecoration(color: _verde),
    cellStyle: const pw.TextStyle(fontSize: 9),
    rowDecoration: pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _linha, width: 0.5)),
    ),
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    headerAlignments: alinhamentos,
    cellAlignments: alinhamentos,
    columnWidths: const {
      0: pw.FlexColumnWidth(4),
      1: pw.FlexColumnWidth(1.4),
      2: pw.FlexColumnWidth(0.9),
      3: pw.FlexColumnWidth(1.8),
      4: pw.FlexColumnWidth(1.8),
    },
  );
}

pw.Widget _totais(OsDetalhe os) {
  final subtotal = os.itens.fold<double>(0, (soma, item) => soma + item.total);

  pw.Widget linha(String rotulo, String valor, {bool destaque = false}) {
    final estilo = pw.TextStyle(
      fontSize: destaque ? 12 : 9.5,
      fontWeight: destaque ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(rotulo, style: estilo)),
          pw.Text(valor, style: estilo),
        ],
      ),
    );
  }

  return pw.Align(
    alignment: pw.Alignment.centerRight,
    child: pw.SizedBox(
      width: 220,
      child: pw.Column(
        children: [
          if (os.desconto > 0) ...[
            linha('Subtotal', formatarMoeda(subtotal)),
            linha('Desconto', '- ${formatarMoeda(os.desconto)}'),
          ],
          pw.Divider(color: _linha, thickness: 0.7),
          linha('Total', formatarMoeda(os.valorTotal), destaque: true),
        ],
      ),
    ),
  );
}

pw.Widget _assinatura(String rotulo) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Divider(color: PdfColors.grey700, thickness: 0.7),
      pw.Text(rotulo, style: pw.TextStyle(fontSize: 8, color: _cinza)),
    ],
  );
}
