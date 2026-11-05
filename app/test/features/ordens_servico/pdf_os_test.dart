import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/core/formatting/datas.dart';
import 'package:geraos/core/formatting/documento.dart';
import 'package:geraos/features/ordens_servico/domain/os_detalhe.dart';
import 'package:geraos/features/ordens_servico/domain/status_os.dart';
import 'package:geraos/features/ordens_servico/pdf/gerar_pdf_os.dart';
import 'package:geraos/features/organizacao/domain/dados_empresa.dart';

final _os = OsDetalhe(
  id: 'os-1',
  numero: 127,
  status: StatusOs.emAndamento,
  equipamento: 'iPhone 12 · 128 GB · preto',
  descricaoProblema: 'Tela trincada após queda.',
  diagnostico: 'Troca do conjunto de tela.',
  acessorios: 'Capinha',
  desconto: 20,
  valorTotal: 360,
  criadoEm: DateTime(2026, 11, 4, 11, 5),
  cliente: const ClienteDaOs(
    id: 'c1',
    nome: 'Marina Costa',
    telefone: '+5571992341180',
  ),
  itens: const [
    ItemOs(
      id: 'i1',
      tipo: 'peca',
      descricao: 'Tela (conjunto)',
      quantidade: 1,
      valorUnitario: 320,
    ),
    ItemOs(
      id: 'i2',
      tipo: 'servico',
      descricao: 'Mão de obra',
      quantidade: 1,
      valorUnitario: 60,
    ),
  ],
);

const _empresa = DadosEmpresa(
  nome: 'TecFix Assistência',
  documento: '12345678000199',
  telefone: '+557132341180',
  endereco: 'Rua das Flores, 120, Centro, Salvador - BA',
  termosGarantia: 'Garantia de 90 dias para o serviço executado.',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('CPF e CNPJ são formatados com pontos, barra e traço', () {
    expect(formatarDocumento('12345678000199'), '12.345.678/0001-99');
    expect(formatarDocumento('12345678901'), '123.456.789-01');
    expect(documentoComRotulo('12345678000199'), startsWith('CNPJ'));
  });

  test('Datas completas, para documentos', () {
    expect(dataCompleta(DateTime(2026, 11, 4)), '04/11/2026');
    expect(dataHoraCompleta(DateTime(2026, 11, 4, 9, 5)), '04/11/2026 09:05');
  });

  test('O PDF da OS é gerado', () async {
    final bytes = await gerarPdfOs(
      os: _os,
      empresa: _empresa,
      geradoEm: DateTime(2026, 11, 5, 10, 32),
    );

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(10000));
  });

  test('OS sem itens e empresa só com o nome também geram PDF', () async {
    final bytes = await gerarPdfOs(
      os: OsDetalhe(
        id: 'os-2',
        numero: 128,
        status: StatusOs.aberta,
        equipamento: 'Notebook Dell Inspiron 15',
        descricaoProblema: 'Não liga',
        criadoEm: DateTime(2026, 11, 5, 9),
        cliente: const ClienteDaOs(id: 'c2', nome: 'João Pereira'),
      ),
      empresa: const DadosEmpresa(nome: 'TecFix Assistência'),
    );

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
