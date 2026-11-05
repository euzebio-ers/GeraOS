import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/telefone.dart';
import '../../../core/validation/validadores.dart';
import '../../../core/widgets/lista_formulario.dart';
import '../data/estado_organizacao.dart';
import '../data/organizacao_repository.dart';
import '../domain/dados_empresa.dart';

/// Texto inicial sugerido para os termos de garantia.
const termosGarantiaSugeridos =
    'Garantia de 90 dias para o serviço executado e as peças substituídas, '
    'contados a partir da data de entrega, conforme o Código de Defesa do '
    'Consumidor. A garantia não cobre danos causados por queda, contato com '
    'líquidos, mau uso ou intervenção de terceiros.';

class DadosEmpresaPage extends ConsumerWidget {
  const DadosEmpresaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ehAdmin = ref.watch(membroAtualProvider)?.ehAdmin ?? false;

    return ref
        .watch(dadosEmpresaProvider)
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
                    const Text(
                      'Não foi possível carregar os dados da empresa. '
                      'Verifique sua conexão.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.invalidate(dadosEmpresaProvider),
                      child: const Text('Tentar de novo'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (dados) => _Formulario(dados: dados, podeEditar: ehAdmin),
        );
  }
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({required this.dados, required this.podeEditar});

  final DadosEmpresa dados;
  final bool podeEditar;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  final _formKey = GlobalKey<FormState>();

  late final _nome = TextEditingController(text: widget.dados.nome);
  late final _documento = TextEditingController(text: widget.dados.documento);
  late final _telefone = TextEditingController(
    text: switch (widget.dados.telefone) {
      final String telefone => formatarTelefone(telefone),
      null => '',
    },
  );
  late final _email = TextEditingController(text: widget.dados.email);
  late final _endereco = TextEditingController(text: widget.dados.endereco);
  late final _termos = TextEditingController(text: widget.dados.termosGarantia);

  bool _salvando = false;
  String? _erro;

  bool get _habilitado => widget.podeEditar && !_salvando;

  @override
  void dispose() {
    _nome.dispose();
    _documento.dispose();
    _telefone.dispose();
    _email.dispose();
    _endereco.dispose();
    _termos.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final membro = ref.read(membroAtualProvider);
    if (membro == null) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });

    String? ouNulo(String texto) => texto.trim().isEmpty ? null : texto.trim();

    final dados = DadosEmpresa(
      nome: _nome.text.trim(),
      documento: ouNulo(apenasDigitos(_documento.text)),
      telefone: telefoneParaE164(_telefone.text),
      email: ouNulo(_email.text),
      endereco: ouNulo(_endereco.text),
      termosGarantia: ouNulo(_termos.text),
    );

    final mensagens = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(organizacaoRepositoryProvider)
          .salvarDadosEmpresa(membro.organizacaoId, dados);
      await ref.read(estadoOrganizacaoProvider).atualizarMembro();
      ref.invalidate(dadosEmpresaProvider);
      mensagens.showSnackBar(
        const SnackBar(content: Text('Dados da empresa salvos.')),
      );
      if (mounted) context.pop();
    } on SemPermissaoEmpresa {
      _falhar('Só administradores podem alterar os dados da empresa.');
    } on Exception {
      _falhar(
        'Não foi possível salvar. Verifique sua conexão e tente novamente.',
      );
    }
  }

  void _falhar(String mensagem) {
    if (!mounted) return;
    setState(() {
      _salvando = false;
      _erro = mensagem;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Dados da empresa')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListaFormulario(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                widget.podeEditar
                    ? 'Estes dados aparecem no cabeçalho e no rodapé da OS '
                          'impressa ou enviada ao cliente.'
                    : 'Só administradores podem alterar os dados da empresa.',
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(
                  labelText: 'Nome da empresa *',
                ),
                textCapitalization: TextCapitalization.words,
                validator: Validadores.nomeOrganizacao,
                enabled: _habilitado,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _documento,
                decoration: const InputDecoration(
                  labelText: 'CNPJ ou CPF',
                  hintText: 'só números',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(14),
                ],
                validator: Validadores.documento,
                enabled: _habilitado,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefone,
                decoration: const InputDecoration(
                  labelText: 'Telefone / WhatsApp',
                  hintText: '(71) 99999-9999',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [MascaraTelefone()],
                validator: Validadores.telefoneOpcional,
                enabled: _habilitado,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: Validadores.emailOpcional,
                enabled: _habilitado,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endereco,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  hintText: 'Rua, número, bairro, cidade',
                  alignLabelWithHint: true,
                ),
                minLines: 2,
                maxLines: 3,
                maxLength: 300,
                textCapitalization: TextCapitalization.words,
                enabled: _habilitado,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _termos,
                decoration: const InputDecoration(
                  labelText: 'Termos de garantia',
                  hintText: 'Prazo e condições da garantia',
                  alignLabelWithHint: true,
                ),
                minLines: 4,
                maxLines: 10,
                maxLength: 2000,
                textCapitalization: TextCapitalization.sentences,
                enabled: _habilitado,
              ),
              if (widget.podeEditar)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _salvando
                        ? null
                        : () => setState(
                            () => _termos.text = termosGarantiaSugeridos,
                          ),
                    child: const Text('Usar texto sugerido'),
                  ),
                ),
              if (_erro != null) ...[
                const SizedBox(height: 8),
                Text(
                  _erro!,
                  style: TextStyle(color: tema.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              if (widget.podeEditar) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
