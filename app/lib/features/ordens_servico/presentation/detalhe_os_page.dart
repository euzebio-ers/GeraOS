import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/formatting/datas.dart';
import '../../../core/formatting/moeda.dart';
import '../../../core/formatting/telefone.dart';
import '../../../core/widgets/avatar_iniciais.dart';
import '../../../core/widgets/lista_formulario.dart';
import '../data/ordens_servico_repository.dart';
import '../domain/formatos_os.dart';
import '../domain/os_detalhe.dart';
import '../domain/status_os.dart';
import 'widgets/etiqueta_status.dart';

class DetalheOsPage extends ConsumerWidget {
  const DetalheOsPage({super.key, required this.osId});

  final String osId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(detalheOsProvider(osId))
        .when(
          loading: () => Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (erro, pilha) => Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      erro is OsNaoEncontrada
                          ? 'Esta OS não foi encontrada.'
                          : 'Não foi possível carregar a OS. '
                                'Verifique sua conexão.',
                      textAlign: TextAlign.center,
                    ),
                    if (erro is! OsNaoEncontrada) ...[
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () =>
                            ref.invalidate(detalheOsProvider(osId)),
                        child: const Text('Tentar de novo'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          data: (os) => _Detalhe(os: os),
        );
  }
}

class _Detalhe extends StatelessWidget {
  const _Detalhe({required this.os});

  final OsDetalhe os;

  void _emBreve(BuildContext context, String oQue) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$oQue chega na próxima parte.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OS ${formatarNumeroOs(os.numero)}')),
      body: ListaFormulario(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          _Cabecalho(os: os),
          const SizedBox(height: 16),
          _CartaoCliente(cliente: os.cliente),
          const SizedBox(height: 12),
          _CartaoEquipamento(os: os),
          const SizedBox(height: 12),
          _CartaoOrcamento(os: os),
          const SizedBox(height: 24),
          _Historico(os: os),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _emBreve(context, 'O envio da OS'),
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Enviar OS'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => _emBreve(context, 'A mudança de status'),
                  child: const Text('Mudar status'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status, quando e por quem a OS foi aberta, e as etapas.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.os});

  final OsDetalhe os;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final por = os.criadoPorNome == null ? '' : ' · por ${os.criadoPorNome}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            EtiquetaStatus(os.status),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aberta ${dataHoraCurta(os.criadoEm)}$por',
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (os.status == StatusOs.cancelada)
          Text(
            'Esta OS foi cancelada.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          )
        else
          _Etapas(status: os.status),
      ],
    );
  }
}

/// Barra de progresso em 4 etapas: Pendente, Em andamento, Pronta, Concluída.
class _Etapas extends StatelessWidget {
  const _Etapas({required this.status});

  final StatusOs status;

  static const _rotulos = ['Pendente', 'Em andamento', 'Pronta', 'Concluída'];

  int get _etapaAtual => switch (status) {
    StatusOs.aberta || StatusOs.emAnalise || StatusOs.aguardandoAprovacao => 0,
    StatusOs.emAndamento => 1,
    StatusOs.pronta => 2,
    StatusOs.entregue => 3,
    StatusOs.cancelada => -1,
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final atual = _etapaAtual;

    return Semantics(
      label: 'Etapa ${atual + 1} de 4: ${_rotulos[atual]}',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < _rotulos.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i < _rotulos.length - 1 ? 6 : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= atual
                            ? tema.colorScheme.primary
                            : tema.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _rotulos[i],
                      style: tema.textTheme.labelSmall?.copyWith(
                        fontWeight: i <= atual
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: i <= atual
                            ? tema.colorScheme.onSurface
                            : tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Título pequeno em maiúsculas: "EQUIPAMENTO", "ORÇAMENTO".
class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        texto.toUpperCase(),
        style: tema.textTheme.labelMedium?.copyWith(
          color: tema.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _CartaoCliente extends StatelessWidget {
  const _CartaoCliente({required this.cliente});

  final ClienteDaOs cliente;

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
    final tema = Theme.of(context);
    final telefone = cliente.telefone;
    final quantidade = cliente.quantidadeOs == 1
        ? '1 OS'
        : '${cliente.quantidadeOs} OS';
    final contato = telefone != null
        ? '${formatarTelefone(telefone)} · $quantidade'
        : quantidade;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                AvatarIniciais(nome: cliente.nome),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cliente.nome, style: tema.textTheme.titleMedium),
                      Text(
                        contato,
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: telefone == null
                        ? null
                        : () => _abrir(
                            context,
                            Uri(scheme: 'tel', path: telefone),
                          ),
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Ligar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: telefone == null
                        ? null
                        : () => _abrir(
                            context,
                            Uri.https('wa.me', '/${apenasDigitos(telefone)}'),
                          ),
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Conversar'),
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

class _CartaoEquipamento extends StatelessWidget {
  const _CartaoEquipamento({required this.os});

  final OsDetalhe os;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final secundario = tema.textTheme.bodyMedium?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
      fontStyle: FontStyle.italic,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Rotulo('Equipamento'),
            Text(os.equipamento, style: tema.textTheme.titleMedium),
            const SizedBox(height: 14),
            const _Rotulo('Defeito relatado'),
            Text(os.descricaoProblema),
            const SizedBox(height: 14),
            const _Rotulo('Diagnóstico'),
            if (os.diagnostico == null)
              Text('Ainda sem diagnóstico.', style: secundario)
            else
              Text(os.diagnostico!),
            if (os.acessorios != null) ...[
              const SizedBox(height: 14),
              const _Rotulo('Acessórios deixados'),
              Text(os.acessorios!),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartaoOrcamento extends StatelessWidget {
  const _CartaoOrcamento({required this.os});

  final OsDetalhe os;

  /// 1.0 → "1"; 1.5 → "1,5".
  static String _quantidade(double valor) => valor == valor.roundToDouble()
      ? valor.toInt().toString()
      : valor.toString().replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Rotulo('Orçamento'),
            if (os.itens.isEmpty)
              Text(
                'Ainda sem orçamento (a orçar).',
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              )
            else ...[
              for (final item in os.itens)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.quantidade == 1
                              ? item.descricao
                              : '${_quantidade(item.quantidade)} × '
                                    '${item.descricao}',
                        ),
                      ),
                      Text(formatarMoeda(item.total)),
                    ],
                  ),
                ),
              if (os.desconto > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Expanded(child: Text('Desconto')),
                      Text('− ${formatarMoeda(os.desconto)}'),
                    ],
                  ),
                ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text('Total', style: tema.textTheme.titleLarge),
                  ),
                  Text(
                    formatarMoeda(os.valorTotal),
                    style: tema.textTheme.titleLarge,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Historico extends StatelessWidget {
  const _Historico({required this.os});

  final OsDetalhe os;

  String _titulo(RegistroHistorico registro) {
    final anterior = registro.statusAnterior;
    if (anterior == null) {
      return os.origem == 'audio' ? 'OS criada por áudio' : 'OS criada';
    }
    return '${anterior.rotuloDetalhado} → '
        '${registro.statusNovo.rotuloDetalhado}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final secundario = tema.textTheme.bodyMedium?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Histórico', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final registro in os.historico)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: tema.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_titulo(registro), style: tema.textTheme.titleSmall),
                      Text(
                        [
                          if (registro.alteradoPorNome != null)
                            registro.alteradoPorNome!,
                          dataHoraCurta(registro.alteradoEm),
                        ].join(' · '),
                        style: secundario,
                      ),
                      if (registro.observacao != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(registro.observacao!),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
