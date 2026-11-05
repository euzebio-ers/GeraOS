import '../../../core/formatting/moeda.dart';
import 'formatos_os.dart';
import 'os_detalhe.dart';
import 'status_os.dart';

/// Só o primeiro nome: "Marina Costa" → "Marina".
String primeiroNome(String nome) => nome.trim().split(RegExp(r'\s+')).first;

/// Mensagem para o cliente pelo WhatsApp, de acordo com o status da OS.
String mensagemWhatsApp(OsDetalhe os, {required String empresa}) {
  final nome = primeiroNome(os.cliente.nome);
  final numero = formatarNumeroOs(os.numero);
  final equipamento = 'seu equipamento (${os.equipamento})';
  final total = os.itens.isEmpty ? null : formatarMoeda(os.valorTotal);

  final corpo = switch (os.status) {
    StatusOs.aberta || StatusOs.emAnalise =>
      'Recebemos $equipamento. O número da sua OS é $numero. '
          'Assim que tivermos o diagnóstico, avisamos por aqui.',
    StatusOs.aguardandoAprovacao => [
      'O orçamento de $equipamento ficou pronto (OS $numero):',
      '',
      for (final item in os.itens)
        '• ${item.descricao}: ${formatarMoeda(item.total)}',
      if (os.desconto > 0) '• Desconto: - ${formatarMoeda(os.desconto)}',
      if (total != null) '*Total: $total*',
      '',
      'Podemos seguir com o serviço?',
    ].join('\n'),
    StatusOs.emAndamento =>
      'O conserto de $equipamento já está em andamento (OS $numero). '
          'Avisamos assim que estiver pronto.',
    StatusOs.pronta =>
      total == null
          ? 'O conserto de $equipamento foi concluído e ele está pronto '
                'para retirada (OS $numero).'
          : 'O conserto de $equipamento foi concluído e ele está pronto '
                'para retirada (OS $numero). Valor: $total.',
    StatusOs.entregue =>
      'Obrigado pela confiança! Qualquer dúvida sobre o '
          'serviço da OS $numero, é só chamar por aqui.',
    StatusOs.cancelada =>
      'A OS $numero, de $equipamento, foi cancelada. '
          'Qualquer dúvida, estamos à disposição.',
  };

  final assinatura = empresa.trim().isEmpty ? '' : '\n\n${empresa.trim()}';
  return 'Olá, $nome! $corpo$assinatura';
}
