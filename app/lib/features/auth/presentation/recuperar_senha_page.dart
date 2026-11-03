import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/rotas.dart';
import '../../../core/validation/validadores.dart';
import '../data/auth_repository.dart';
import '../domain/falha_autenticacao.dart';

class RecuperarSenhaPage extends ConsumerStatefulWidget {
  const RecuperarSenhaPage({super.key});

  @override
  ConsumerState<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends ConsumerState<RecuperarSenhaPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  bool _carregando = false;
  bool _enviado = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .enviarRecuperacaoSenha(_email.text);
      if (mounted) setState(() => _enviado = true);
    } on FalhaAutenticacao catch (falha) {
      if (mounted) setState(() => _erro = falha.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_enviado)
                      const Text(
                        'Se existir uma conta com este e-mail, você vai receber '
                        'um link para criar uma nova senha.',
                        textAlign: TextAlign.center,
                      )
                    else ...[
                      const Text(
                        'Informe o e-mail da sua conta. Vamos enviar um link '
                        'para você criar uma nova senha.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(labelText: 'E-mail'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.email],
                        validator: Validadores.email,
                        enabled: !_carregando,
                        onFieldSubmitted: (_) => _enviar(),
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
                        onPressed: _carregando ? null : _enviar,
                        child: _carregando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Enviar link'),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _carregando
                          ? null
                          : () => context.go(Rotas.login),
                      child: const Text('Voltar para o login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
