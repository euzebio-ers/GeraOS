import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/telefone.dart';
import '../../../core/validation/validadores.dart';
import '../../../core/widgets/lista_formulario.dart';
import '../data/clientes_repository.dart';
import '../domain/cliente.dart';

/// Cadastro (sem `clienteId`) ou edição (com `clienteId`) de cliente.
class ClienteFormPage extends ConsumerWidget {
  const ClienteFormPage({super.key, this.clienteId});

  final String? clienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = clienteId;
    if (id == null) return const _FormularioCliente();

    return ref
        .watch(clienteProvider(id))
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (erro, pilha) => Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Não foi possível carregar o cliente.'),
            ),
          ),
          data: (cliente) => _FormularioCliente(cliente: cliente),
        );
  }
}

class _FormularioCliente extends ConsumerStatefulWidget {
  const _FormularioCliente({this.cliente});

  /// `null` no cadastro de um cliente novo.
  final Cliente? cliente;

  @override
  ConsumerState<_FormularioCliente> createState() => _FormularioClienteState();
}

class _FormularioClienteState extends ConsumerState<_FormularioCliente> {
  final _formKey = GlobalKey<FormState>();

  late final _nome = TextEditingController(text: widget.cliente?.nome);
  late final _telefone = TextEditingController(
    text: switch (widget.cliente?.telefone) {
      final String telefone => formatarTelefone(telefone),
      null => '',
    },
  );
  late final _email = TextEditingController(text: widget.cliente?.email);
  late final _documento = TextEditingController(
    text: widget.cliente?.documento,
  );
  late final _observacoes = TextEditingController(
    text: widget.cliente?.observacoes,
  );

  bool _salvando = false;
  String? _erro;

  bool get _editando => widget.cliente != null;

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    _email.dispose();
    _documento.dispose();
    _observacoes.dispose();
    super.dispose();
  }

  /// Telefone: formato válido e, sem e-mail, obrigatório (RN003).
  String? _validarTelefone(String? valor) {
    final erro = Validadores.telefoneOpcional(valor);
    if (erro != null) return erro;
    final semTelefone = (valor ?? '').trim().isEmpty;
    final semEmail = _email.text.trim().isEmpty;
    return semTelefone && semEmail ? 'Informe o telefone ou o e-mail.' : null;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });

    String? ouNulo(String texto) => texto.trim().isEmpty ? null : texto.trim();

    final cliente = Cliente(
      id: widget.cliente?.id,
      nome: _nome.text.trim(),
      telefone: telefoneParaE164(_telefone.text),
      email: ouNulo(_email.text),
      documento: ouNulo(apenasDigitos(_documento.text)),
      observacoes: ouNulo(_observacoes.text),
    );

    final mensagens = ScaffoldMessenger.of(context);

    try {
      await ref.read(clientesRepositoryProvider).salvar(cliente);
      ref.invalidate(listaClientesProvider);
      mensagens.showSnackBar(
        SnackBar(
          content: Text(
            _editando ? 'Cliente atualizado.' : 'Cliente cadastrado.',
          ),
        ),
      );
      if (mounted) context.pop();
    } on Exception {
      if (mounted) {
        setState(() {
          _salvando = false;
          _erro =
              'Não foi possível salvar o cliente. '
              'Verifique sua conexão e tente novamente.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar cliente' : 'Novo cliente'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListaFormulario(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(labelText: 'Nome completo *'),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: Validadores.nomeCliente,
                enabled: !_salvando,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _documento,
                decoration: const InputDecoration(
                  labelText: 'CPF ou CNPJ',
                  hintText: 'opcional, só números',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(14),
                ],
                textInputAction: TextInputAction.next,
                validator: Validadores.documento,
                enabled: !_salvando,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacoes,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  hintText: 'Ex.: prefere contato por WhatsApp à tarde',
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: 5,
                maxLength: 1000,
                textCapitalization: TextCapitalization.sentences,
                enabled: !_salvando,
              ),
              if (_erro != null) ...[
                const SizedBox(height: 8),
                Text(
                  _erro!,
                  style: TextStyle(color: tema.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _editando ? 'Salvar alterações' : 'Cadastrar cliente',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
