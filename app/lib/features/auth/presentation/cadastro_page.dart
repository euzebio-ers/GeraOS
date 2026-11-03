import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/rotas.dart';
import '../../../core/validation/validadores.dart';
import '../data/auth_repository.dart';
import '../domain/falha_autenticacao.dart';
import '../domain/resultado_cadastro.dart';

class CadastroPage extends ConsumerStatefulWidget {
  const CadastroPage({super.key});

  @override
  ConsumerState<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends ConsumerState<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();

  bool _carregando = false;
  bool _senhaVisivel = false;
  String? _erro;

  /// Preenchido quando o cadastro exige confirmação por e-mail.
  String? _emailEnviado;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final resultado = await ref
          .read(authRepositoryProvider)
          .cadastrar(nome: _nome.text, email: _email.text, senha: _senha.text);
      if (resultado == ResultadoCadastro.confirmarEmail && mounted) {
        setState(() => _emailEnviado = _email.text.trim());
      }
    } on FalhaAutenticacao catch (falha) {
      if (mounted) setState(() => _erro = falha.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _emailEnviado == null
                  ? _formulario(context)
                  : _confirmacaoEnviada(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formulario(BuildContext context) {
    final tema = Theme.of(context);

    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nome,
              decoration: const InputDecoration(labelText: 'Seu nome'),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: Validadores.nome,
              enabled: !_carregando,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validadores.email,
              enabled: !_carregando,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _senha,
              decoration: InputDecoration(
                labelText: 'Senha',
                helperText: 'Mínimo de 8 caracteres, com letras e números.',
                suffixIcon: IconButton(
                  tooltip: _senhaVisivel ? 'Ocultar senha' : 'Mostrar senha',
                  icon: Icon(
                    _senhaVisivel ? Icons.visibility_off : Icons.visibility,
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
              decoration: const InputDecoration(labelText: 'Confirme a senha'),
              obscureText: !_senhaVisivel,
              textInputAction: TextInputAction.done,
              validator: Validadores.confirmacaoSenha(() => _senha.text),
              enabled: !_carregando,
              onFieldSubmitted: (_) => _cadastrar(),
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
              onPressed: _carregando ? null : _cadastrar,
              child: _carregando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Criar conta'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _carregando ? null : () => context.go(Rotas.login),
              child: const Text('Já tenho conta'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmacaoEnviada(BuildContext context) {
    final tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: tema.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Confirme seu e-mail',
          style: tema.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enviamos um link de confirmação para $_emailEnviado. '
          'Abra o e-mail e toque no link para ativar sua conta.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.go(Rotas.login),
          child: const Text('Voltar para o login'),
        ),
      ],
    );
  }
}
