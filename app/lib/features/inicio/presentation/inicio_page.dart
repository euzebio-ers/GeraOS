import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/rotas.dart';
import '../../../core/widgets/avatar_iniciais.dart';
import '../../ordens_servico/presentation/widgets/cartao_gravar_os.dart';
import '../../organizacao/data/estado_organizacao.dart';

class InicioPage extends ConsumerWidget {
  const InicioPage({super.key});

  static String _saudacao(DateTime agora) {
    if (agora.hour < 12) return 'Bom dia';
    if (agora.hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final membro = ref.watch(estadoOrganizacaoProvider).membro;
    final primeiroNome = membro?.nome.trim().split(RegExp(r'\s+')).first;
    final saudacao = _saudacao(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: ListView(
          // O espaço extra embaixo evita que o botão do microfone cubra o conteúdo.
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (membro != null)
                        Text(
                          membro.nomeOrganizacao,
                          style: tema.textTheme.titleSmall?.copyWith(
                            color: tema.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        primeiroNome == null
                            ? saudacao
                            : '$saudacao, $primeiroNome',
                        style: tema.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                if (membro != null) AvatarIniciais(nome: membro.nome),
              ],
            ),
            const SizedBox(height: 22),
            CartaoGravarOs(onTap: () => context.push(Rotas.gravarOs)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(Rotas.novaOs),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Digitar OS'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go(Rotas.ordensServico),
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Buscar OS'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
