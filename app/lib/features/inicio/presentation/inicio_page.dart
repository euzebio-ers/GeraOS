import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/moeda.dart';
import '../../../core/layout/larguras.dart';
import '../../../core/router/rotas.dart';
import '../../../core/theme/cores_geraos.dart';
import '../../../core/widgets/avatar_iniciais.dart';
import '../../../core/widgets/lista_formulario.dart';
import '../../ordens_servico/data/ordens_servico_repository.dart';
import '../../ordens_servico/domain/filtro_status.dart';
import '../../ordens_servico/domain/status_os.dart';
import '../../ordens_servico/presentation/filtro_solicitado.dart';
import '../../ordens_servico/presentation/widgets/cartao_gravar_os.dart';
import '../../ordens_servico/presentation/widgets/cartao_os.dart';
import '../../organizacao/data/estado_organizacao.dart';
import '../../organizacao/domain/membro_atual.dart';

class InicioPage extends ConsumerWidget {
  const InicioPage({super.key});

  /// Abre a aba Ordens já com o filtro aplicado.
  static void _abrirOrdens(
    BuildContext context,
    WidgetRef ref,
    FiltroStatus filtro,
  ) {
    ref.read(filtroOsSolicitadoProvider.notifier).pedir(filtro);
    context.go(Rotas.ordensServico);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membro = ref.watch(membroAtualProvider);
    final contagem = ref.watch(contagemStatusProvider).value ?? const {};
    final ehAdmin = membro?.ehAdmin ?? false;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, limites) {
            final emColunas = limites.maxWidth >= Larguras.inicioEmColunas;

            final cabecalho = _Cabecalho(membro: membro);
            const acoes = _Acoes();
            final bancada = _Bancada(
              contagem: contagem,
              aoAbrir: (filtro) => _abrirOrdens(context, ref, filtro),
            );
            final ultimas = _SecaoUltimas(
              ladoALado: emColunas,
              aoVerTodas: () => _abrirOrdens(context, ref, FiltroStatus.todas),
            );

            if (!emColunas) {
              return ListaFormulario(
                // O espaço extra embaixo evita que o microfone cubra o conteúdo.
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                children: [
                  cabecalho,
                  const SizedBox(height: 22),
                  acoes,
                  const SizedBox(height: 24),
                  bancada,
                  if (ehAdmin) ...[
                    const SizedBox(height: 16),
                    const _CartaoFaturamento(),
                  ],
                  const SizedBox(height: 24),
                  ultimas,
                ],
              );
            }

            return ListaFormulario(
              padding: const EdgeInsets.all(32),
              larguraMaxima: Larguras.inicioLargo,
              children: [
                cabecalho,
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          acoes,
                          const SizedBox(height: 24),
                          bancada,
                          if (ehAdmin) ...[
                            const SizedBox(height: 16),
                            const _CartaoFaturamento(),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(flex: 4, child: ultimas),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Nome da empresa, saudação e o avatar de quem está logado.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.membro});

  final MembroAtual? membro;

  static String _saudacao(DateTime agora) {
    if (agora.hour < 12) return 'Bom dia';
    if (agora.hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final membro = this.membro;
    final primeiroNome = membro?.nome.trim().split(RegExp(r'\s+')).first;
    final saudacao = _saudacao(DateTime.now());

    return Row(
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
                primeiroNome == null ? saudacao : '$saudacao, $primeiroNome',
                style: tema.textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        if (membro != null) AvatarIniciais(nome: membro.nome),
      ],
    );
  }
}

/// O cartão de gravar e os botões "Nova OS" e "Buscar OS".
class _Acoes extends StatelessWidget {
  const _Acoes();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CartaoGravarOs(onTap: () => context.push(Rotas.gravarOs)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push(Rotas.novaOs),
                icon: const Icon(Icons.note_add_outlined),
                label: const Text('Nova OS'),
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
    );
  }
}

/// "Hoje na bancada": os três contadores coloridos.
class _Bancada extends StatelessWidget {
  const _Bancada({required this.contagem, required this.aoAbrir});

  final Map<StatusOs, int> contagem;
  final void Function(FiltroStatus filtro) aoAbrir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = context.cores;
    int contar(FiltroStatus filtro) => filtro.contar(contagem);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Hoje na bancada', style: tema.textTheme.titleMedium),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Contador(
                  quantidade: contar(FiltroStatus.pendente),
                  rotulo: 'Pendentes',
                  cor: cores.pendente,
                  aoTocar: () => aoAbrir(FiltroStatus.pendente),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Contador(
                  quantidade: contar(FiltroStatus.emAndamento),
                  rotulo: 'Em andamento',
                  cor: cores.emAndamento,
                  aoTocar: () => aoAbrir(FiltroStatus.emAndamento),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Contador(
                  quantidade: contar(FiltroStatus.pronta),
                  rotulo: 'Prontas p/ retirar',
                  cor: cores.pronta,
                  aoTocar: () => aoAbrir(FiltroStatus.pronta),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// O título "Últimas OS", o "Ver todas" e os cartões.
class _SecaoUltimas extends StatelessWidget {
  const _SecaoUltimas({required this.ladoALado, required this.aoVerTodas});

  final bool ladoALado;
  final VoidCallback aoVerTodas;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Últimas OS', style: tema.textTheme.titleMedium),
            ),
            TextButton(onPressed: aoVerTodas, child: const Text('Ver todas')),
          ],
        ),
        const SizedBox(height: 4),
        _UltimasOs(ladoALado: ladoALado),
      ],
    );
  }
}

/// Um dos três quadros coloridos do "Hoje na bancada".
class _Contador extends StatelessWidget {
  const _Contador({
    required this.quantidade,
    required this.rotulo,
    required this.cor,
    required this.aoTocar,
  });

  final int quantidade;
  final String rotulo;
  final CorStatus cor;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$quantidade $rotulo',
      excludeSemantics: true,
      child: Material(
        color: cor.fundo,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$quantidade',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: cor.texto,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rotulo,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cor.texto,
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

/// Faturamento do mês. Só aparece para administradores.
class _CartaoFaturamento extends ConsumerWidget {
  const _CartaoFaturamento();

  static const _meses = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final secundario = tema.textTheme.bodyMedium?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );

    return ref
        .watch(faturamentoProvider)
        .when(
          loading: () => const SizedBox(height: 96),
          error: (erro, pilha) => const SizedBox.shrink(),
          data: (faturamento) => Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Faturamento de ${_meses[faturamento.mes.month - 1]} · '
                    'só admin',
                    style: tema.textTheme.labelLarge?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatarMoeda(faturamento.total),
                    style: tema.textTheme.headlineSmall,
                  ),
                  Text(
                    faturamento.quantidade == 1
                        ? '1 OS entregue'
                        : '${faturamento.quantidade} OS entregues',
                    style: secundario,
                  ),
                ],
              ),
            ),
          ),
        );
  }
}

/// As 3 OS mais recentes.
class _UltimasOs extends ConsumerWidget {
  const _UltimasOs({required this.ladoALado});

  /// No computador, a OS abre na aba Ordens, ao lado da lista.
  final bool ladoALado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);

    return ref
        .watch(ultimasOsProvider)
        .when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (erro, pilha) => Text(
            'Não foi possível carregar as últimas OS.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
          data: (ordens) => ordens.isEmpty
              ? Text(
                  'Nenhuma OS ainda. Toque em "Nova OS" ou no microfone '
                  'para criar a primeira.',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final os in ordens)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CartaoOs(
                          os: os,
                          aoTocar: () => ladoALado
                              ? context.go(Rotas.osNaLista(os.id))
                              : context.push(Rotas.os(os.id)),
                        ),
                      ),
                  ],
                ),
        );
  }
}
