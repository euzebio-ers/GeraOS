import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/moeda.dart';
import '../../../core/formatting/telefone.dart';
import '../../../core/router/rotas.dart';
import '../../../core/theme/cores_geraos.dart';
import '../../../core/validation/validadores.dart';
import '../../../core/widgets/lista_formulario.dart';
import '../../../core/widgets/avatar_iniciais.dart';
import '../../clientes/data/clientes_repository.dart';
import '../../clientes/domain/cliente_resumo.dart';
import '../data/ordens_servico_repository.dart';
import '../domain/formatos_os.dart';
import '../domain/nova_os.dart';

class NovaOsPage extends ConsumerStatefulWidget {
  const NovaOsPage({super.key});

  @override
  ConsumerState<NovaOsPage> createState() => _NovaOsPageState();
}

class _NovaOsPageState extends ConsumerState<NovaOsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _focoNome = FocusNode();
  final _telefone = TextEditingController();
  final _email = TextEditingController();
  final _equipamento = TextEditingController();
  final _defeito = TextEditingController();
  final _acessorios = TextEditingController();
  final _valor = TextEditingController();

  /// Cliente escolhido na busca. `null` quando é um cliente novo.
  ClienteResumo? _cliente;
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _focoNome.dispose();
    _telefone.dispose();
    _email.dispose();
    _equipamento.dispose();
    _defeito.dispose();
    _acessorios.dispose();
    _valor.dispose();
    super.dispose();
  }

  /// Sugestões de clientes já cadastrados enquanto o nome é digitado.
  Future<Iterable<ClienteResumo>> _sugerir(TextEditingValue valor) async {
    final termo = valor.text.trim();
    if (termo.length < 2) return const [];
    try {
      final clientes = await ref
          .read(clientesRepositoryProvider)
          .listar(busca: termo);
      return clientes.take(5);
    } on Exception {
      return const [];
    }
  }

  void _trocarCliente() {
    setState(() {
      _cliente = null;
      _nome.clear();
      _telefone.clear();
      _email.clear();
    });
  }

  /// Cliente novo: telefone válido e, sem e-mail, obrigatório (RN003).
  String? _validarTelefone(String? valor) {
    final erro = Validadores.telefoneOpcional(valor);
    if (erro != null) return erro;
    final semTelefone = (valor ?? '').trim().isEmpty;
    final semEmail = _email.text.trim().isEmpty;
    return semTelefone && semEmail ? 'Informe o telefone ou o e-mail.' : null;
  }

  Future<void> _criar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });

    String? ouNulo(String texto) => texto.trim().isEmpty ? null : texto.trim();
    final cliente = _cliente;

    final os = NovaOs(
      clienteId: cliente?.id,
      clienteNome: cliente == null ? _nome.text.trim() : null,
      clienteTelefone: cliente == null
          ? telefoneParaE164(_telefone.text)
          : null,
      clienteEmail: cliente == null ? ouNulo(_email.text) : null,
      equipamento: _equipamento.text.trim(),
      descricaoProblema: _defeito.text.trim(),
      acessorios: ouNulo(_acessorios.text),
      valorEstimado: textoParaValor(_valor.text),
    );

    final mensagens = ScaffoldMessenger.of(context);

    try {
      final criada = await ref
          .read(ordensServicoRepositoryProvider)
          .criarDigitada(os);
      ref.invalidate(listaClientesProvider);
      ref.read(atualizacaoOsProvider.notifier).avisar();
      mensagens.showSnackBar(
        SnackBar(
          content: Text('OS ${formatarNumeroOs(criada.numero)} criada.'),
        ),
      );
      if (mounted) context.pushReplacement(Rotas.os(criada.id));
    } on Exception {
      if (mounted) {
        setState(() {
          _salvando = false;
          _erro =
              'Não foi possível criar a OS. '
              'Verifique sua conexão e tente novamente.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cliente = _cliente;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova OS'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => context.push(Rotas.gravarOs),
              style: TextButton.styleFrom(
                foregroundColor: context.cores.microfone,
              ),
              icon: const Icon(Icons.mic_none_rounded),
              label: const Text('Falar'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: ListaFormulario(
                padding: const EdgeInsets.all(20),
                children: [
                  const _TituloSecao('Cliente'),
                  if (cliente != null)
                    _ClienteEscolhido(
                      cliente: cliente,
                      aoTrocar: _salvando ? null : _trocarCliente,
                    )
                  else ...[
                    RawAutocomplete<ClienteResumo>(
                      textEditingController: _nome,
                      focusNode: _focoNome,
                      optionsBuilder: _sugerir,
                      displayStringForOption: (cliente) => cliente.nome,
                      onSelected: (cliente) =>
                          setState(() => _cliente = cliente),
                      fieldViewBuilder:
                          (context, controlador, foco, aoEnviar) =>
                              TextFormField(
                                controller: controlador,
                                focusNode: foco,
                                decoration: const InputDecoration(
                                  labelText: 'Nome completo *',
                                  hintText: 'Digite para buscar ou cadastrar',
                                ),
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                validator: Validadores.nomeCliente,
                                enabled: !_salvando,
                              ),
                      optionsViewBuilder: (context, aoEscolher, opcoes) =>
                          _SugestoesClientes(
                            opcoes: opcoes,
                            aoEscolher: aoEscolher,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefone,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp / telefone com DDD',
                        hintText: '(71) 99999-9999',
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [MascaraTelefone()],
                      textInputAction: TextInputAction.next,
                      validator: _validarTelefone,
                      enabled: !_salvando,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'opcional',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validadores.emailOpcional,
                      enabled: !_salvando,
                    ),
                  ],
                  const SizedBox(height: 28),
                  const _TituloSecao('Equipamento'),
                  TextFormField(
                    controller: _equipamento,
                    decoration: const InputDecoration(
                      labelText: 'Aparelho, marca e modelo *',
                      hintText: 'Ex.: Notebook Dell Inspiron 15',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator: Validadores.equipamento,
                    enabled: !_salvando,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _defeito,
                    decoration: const InputDecoration(
                      labelText: 'Defeito relatado *',
                      hintText: 'O que o cliente disse?',
                      alignLabelWithHint: true,
                    ),
                    minLines: 3,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    validator: Validadores.defeito,
                    enabled: !_salvando,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _acessorios,
                    decoration: const InputDecoration(
                      labelText: 'Acessórios deixados',
                      hintText: 'Ex.: carregador, capinha',
                    ),
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    enabled: !_salvando,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _valor,
                    decoration: const InputDecoration(
                      labelText: 'Valor estimado (R\$)',
                      hintText: 'a orçar',
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [MascaraMoeda()],
                    validator: Validadores.valorOpcional,
                    enabled: !_salvando,
                    onFieldSubmitted: (_) => _criar(),
                  ),
                  if (_erro != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _erro!,
                      style: TextStyle(color: tema.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _salvando ? null : _criar,
                    child: _salvando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Criar OS'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Título de seção em letras maiúsculas, como no protótipo ("CLIENTE").
class _TituloSecao extends StatelessWidget {
  const _TituloSecao(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto.toUpperCase(),
        style: tema.textTheme.labelLarge?.copyWith(
          color: tema.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Lista de sugestões que aparece abaixo do campo de nome.
class _SugestoesClientes extends StatelessWidget {
  const _SugestoesClientes({required this.opcoes, required this.aoEscolher});

  final Iterable<ClienteResumo> opcoes;
  final AutocompleteOnSelected<ClienteResumo> aoEscolher;

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width - 40;

    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 280,
            maxWidth: largura > 600 ? 600 : largura,
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              for (final cliente in opcoes)
                ListTile(
                  leading: AvatarIniciais(nome: cliente.nome, tamanho: 36),
                  title: Text(cliente.nome),
                  subtitle: cliente.telefone == null
                      ? null
                      : Text(formatarTelefone(cliente.telefone!)),
                  onTap: () => aoEscolher(cliente),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cartão do cliente escolhido na busca, com a opção de trocar.
class _ClienteEscolhido extends StatelessWidget {
  const _ClienteEscolhido({required this.cliente, required this.aoTrocar});

  final ClienteResumo cliente;
  final VoidCallback? aoTrocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final contato = cliente.telefone != null
        ? formatarTelefone(cliente.telefone!)
        : cliente.email;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AvatarIniciais(nome: cliente.nome),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cliente.nome, style: tema.textTheme.titleMedium),
                  if (contato != null)
                    Text(
                      contato,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            TextButton(onPressed: aoTrocar, child: const Text('Trocar')),
          ],
        ),
      ),
    );
  }
}
