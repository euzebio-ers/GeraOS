import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../formatting/telefone.dart';

/// Os botões "Ligar" e "Conversar" (WhatsApp). Ficam desativados
/// quando não há telefone.
class BotoesContato extends StatelessWidget {
  const BotoesContato({super.key, required this.telefone});

  /// No formato do banco: "+5571992341180".
  final String? telefone;

  Future<void> _abrir(BuildContext context, Uri endereco) async {
    final mensagens = ScaffoldMessenger.of(context);
    final abriu = await launchUrl(
      endereco,
      mode: LaunchMode.externalApplication,
    );
    if (!abriu) {
      mensagens.showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir neste aparelho.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final numero = telefone;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: numero == null
                ? null
                : () => _abrir(context, Uri(scheme: 'tel', path: numero)),
            icon: const Icon(Icons.call_outlined),
            label: const Text('Ligar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: numero == null
                ? null
                : () => _abrir(
                    context,
                    Uri.https('wa.me', '/${apenasDigitos(numero)}'),
                  ),
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Conversar'),
          ),
        ),
      ],
    );
  }
}
