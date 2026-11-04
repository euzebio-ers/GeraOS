import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/rotas.dart';
import '../../../core/validation/validadores.dart';
import '../data/auth_repository.dart';
import '../data/estado_autenticacao.dart';
import '../domain/falha_autenticacao.dart';

class NovaSenhaPage extends ConsumerStatefulWidget {
  const NovaSenhaPage({super.key});

  @override
  ConsumerState<NovaSenhaPage> createState() => _NovaSenhaPageState();
}

class _NovaSenhaPageState extends ConsumerState<NovaSenhaPage> {
  final _formKey = GlobalKey<FormState>();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();

  bool _carregando = false;
  bool _senhaVisivel = false;
  String? _erro;

  @override
  void dispose() {
    _senha.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    final mensagens = ScaffoldMessenger.of(context);

    try {
      await ref.read(authRepositoryProvider).definirNovaSenha(_senha.text);
      ref.read(estadoAutenticacaoProvider).concluirRecuperacao();
      mensagens.showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso.')),
      );
      if (mounted) context.go(Rotas.paginaInicial);
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
      appBar: AppBar(title: const Text('Nova senha')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Escolha uma nova senha para a sua conta.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _senha,
                        decoration: InputDecoration(
                          labelText: 'Nova senha',
                          helperText:
                              'Mínimo de 8 caracteres, com letras e números.',
                          suffixIcon: IconButton(
                            tooltip: _senhaVisivel
                                ? 'Ocultar senha'
                                : 'Mostrar senha',
                            icon: Icon(
                              _senhaVisivel
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _senhaVisivel = !_senhaVisivel),
                          ),
                        ),
                        obscureText: !_senhaVisivel,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: Validadores.senhaCadastro,
                        enabled: !_carregando,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmacao,
                        decoration: const InputDecoration(
                          labelText: 'Confirme a nova senha',
                        ),
                        obscureText: !_senhaVisivel,
                        textInputAction: TextInputAction.done,
                        validator: Validadores.confirmacaoSenha(
                          () => _senha.text,
                        ),
                        enabled: !_carregando,
                        onFieldSubmitted: (_) => _salvar(),
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
                        onPressed: _carregando ? null : _salvar,
                        child: _carregando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Salvar nova senha'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
