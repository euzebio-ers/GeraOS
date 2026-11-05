import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/formatting/telefone.dart';
import '../../../core/router/rotas.dart';
import '../domain/mensagem_os.dart';
import '../domain/os_detalhe.dart';
import 'widgets/dialogo_texto.dart';

enum _OpcaoEnvio { whatsapp, pdf }

/// O botão "Enviar OS": pergunta como enviar e segue com a opção escolhida.
Future<void> enviarOs(
  BuildContext context, {
  required OsDetalhe os,
  required String empresa,
}) async {
  final telefone = os.cliente.telefone;
  final opcao = await _escolherOpcao(context, temTelefone: telefone != null);
  if (opcao == null || !context.mounted) return;

  switch (opcao) {
    case _OpcaoEnvio.pdf:
      context.push(Rotas.pdfOs(os.id));
    case _OpcaoEnvio.whatsapp:
      final texto = await pedirTexto(
        context,
        titulo: 'Mensagem para ${primeiroNome(os.cliente.nome)}',
        rotulo: 'Mensagem',
        ajuda: 'Você pode ajustar o texto antes de enviar.',
        inicial: mensagemWhatsApp(os, empresa: empresa),
        obrigatorio: true,
        minLinhas: 6,
        maximoCaracteres: 1000,
        textoConfirmar: 'Abrir WhatsApp',
      );
      if (texto == null || telefone == null || !context.mounted) return;

      final mensagens = ScaffoldMessenger.of(context);
      final endereco = Uri.parse(
        'https://wa.me/${apenasDigitos(telefone)}'
        '?text=${Uri.encodeComponent(texto)}',
      );
      final abriu = await launchUrl(
        endereco,
        mode: LaunchMode.externalApplication,
      );
      if (!abriu) {
        mensagens.showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
        );
      }
  }
}

Future<_OpcaoEnvio?> _escolherOpcao(
  BuildContext context, {
  required bool temTelefone,
}) {
  return showModalBottomSheet<_OpcaoEnvio>(
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
              child: Text('Enviar OS', style: tema.textTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: const Text('Mensagem no WhatsApp'),
              subtitle: Text(
                temTelefone
                    ? 'Texto pronto de acordo com o status da OS'
                    : 'O cliente não tem telefone cadastrado',
              ),
              enabled: temTelefone,
              onTap: () => Navigator.of(context).pop(_OpcaoEnvio.whatsapp),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('PDF da OS'),
              subtitle: const Text('Ver, imprimir ou compartilhar'),
              onTap: () => Navigator.of(context).pop(_OpcaoEnvio.pdf),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
