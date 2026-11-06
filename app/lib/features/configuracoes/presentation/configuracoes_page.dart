import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/rotas.dart';
import '../../../core/theme/tema_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../organizacao/data/estado_organizacao.dart';

class ConfiguracoesPage extends ConsumerWidget {
  const ConfiguracoesPage({super.key});

  /// Sair da conta leva sempre ao login "limpo". Sem isso, o router
  /// guardaria esta tela como destino, e o próximo login voltaria a ela.
  Future<void> _sair(BuildContext context, WidgetRef ref) async {
    final router = GoRouter.of(context);
    await ref.read(authRepositoryProvider).sair();
    router.go(Rotas.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final membro = ref.watch(membroAtualProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (membro != null) ...[
            Text('Empresa', style: tema.textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: Text(membro.nomeOrganizacao),
                subtitle: Text(
                  membro.ehAdmin
                      ? 'Dados que aparecem na OS do cliente'
                      : 'Ver os dados da empresa',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(Rotas.dadosEmpresa),
              ),
            ),
            const SizedBox(height: 32),
          ],
          Text('Aparência', style: tema.textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Claro'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('Sistema'),
                icon: Icon(Icons.brightness_auto),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Escuro'),
                icon: Icon(Icons.dark_mode),
              ),
            ],
            selected: {ref.watch(temaProvider)},
            onSelectionChanged: (selecao) =>
                ref.read(temaProvider.notifier).alterar(selecao.first),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => _sair(context, ref),
            icon: const Icon(Icons.logout),
            label: const Text('Sair da conta'),
          ),
        ],
      ),
    );
  }
}
