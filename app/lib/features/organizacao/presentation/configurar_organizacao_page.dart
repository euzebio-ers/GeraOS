import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/validation/validadores.dart';
import '../../auth/data/auth_repository.dart';
import '../data/estado_organizacao.dart';
import '../data/organizacao_repository.dart';

class ConfigurarOrganizacaoPage extends ConsumerStatefulWidget {
  const ConfigurarOrganizacaoPage({super.key});

  @override
  ConsumerState<ConfigurarOrganizacaoPage> createState() =>
      _ConfigurarOrganizacaoPageState();
}

class _ConfigurarOrganizacaoPageState
    extends ConsumerState<ConfigurarOrganizacaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeOrganizacao = TextEditingController();
  final _nomeMembro = TextEditingController();

  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();

    final dados = ref.read(organizacaoRepositoryProvider).dadosDoCadastro();
    _nomeOrganizacao.text = dados.nomeOrganizacao ?? '';
    _nomeMembro.text = dados.nome ?? '';

    // Com os dois nomes do cadastro, a empresa é criada sem pedir nada.
    final podeCriarSozinho =
        Validadores.nomeOrganizacao(_nomeOrganizacao.text) == null &&
        Validadores.nome(_nomeMembro.text) == null;
    if (podeCriarSozinho) {
      _carregando = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _criar());
    }
  }

  @override
  void dispose() {
    _nomeOrganizacao.dispose();
    _nomeMembro.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _carregando = false);
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await ref
          .read(organizacaoRepositoryProvider)
          .criarOrganizacao(
            nomeOrganizacao: _nomeOrganizacao.text,
            nomeMembro: _nomeMembro.text,
          );
      await ref.read(estadoOrganizacaoProvider).recarregar();
    } on Exception catch (erro) {
      // Já existe empresa (ex.: dois toques seguidos): só recarrega.
      if (erro is PostgrestException && erro.message.contains('já pertence')) {
        await ref.read(estadoOrganizacaoProvider).recarregar();
        return;
      }
      if (mounted) {
        setState(
          () => _erro = 'Não foi possível criar sua empresa. Verifique sua conexão e tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
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
                    Text(
                      'Sua empresa',
                      style: tema.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Falta só um passo para começar a usar o GeraOS.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nomeOrganizacao,
                      decoration: const InputDecoration(
                        labelText: 'Nome da empresa',
                        hintText: 'Ex.: TecFix Assistência',
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: Validadores.nomeOrganizacao,
                      enabled: !_carregando,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeMembro,
                      decoration: const InputDecoration(labelText: 'Seu nome'),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      validator: Validadores.nome,
                      enabled: !_carregando,
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
                      onPressed: _carregando ? null : _criar,
                      child: _carregando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Começar a usar'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _carregando
                          ? null
                          : () => ref.read(authRepositoryProvider).sair(),
                      child: const Text('Sair da conta'),
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
