import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/app.dart';
import 'package:geraos/core/preferences/preferencias.dart';
import 'package:geraos/features/auth/data/auth_repository.dart';
import 'package:geraos/features/auth/data/estado_autenticacao.dart';
import 'package:geraos/features/auth/domain/falha_autenticacao.dart';
import 'package:geraos/features/auth/domain/resultado_cadastro.dart';
import 'package:geraos/features/organizacao/data/estado_organizacao.dart';
import 'package:geraos/features/organizacao/data/organizacao_repository.dart';
import 'package:geraos/features/organizacao/domain/membro_atual.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Versão falsa do estado de login, controlada pelo próprio teste.
class EstadoAutenticacaoFalso extends EstadoAutenticacao {
  EstadoAutenticacaoFalso({required this.logado});

  @override
  bool logado;

  @override
  String? get usuarioId => logado ? 'usuario-teste' : null;

  void alterarLogin(bool valor) {
    logado = valor;
    notifyListeners();
  }
}

/// Versão falsa do estado da organização.
class EstadoOrganizacaoFalso extends EstadoOrganizacao {
  EstadoOrganizacaoFalso({
    this.situacao = SituacaoOrganizacao.pronta,
    this.membro,
  });

  @override
  SituacaoOrganizacao situacao;

  @override
  MembroAtual? membro;

  int recarregamentos = 0;

  /// Simula uma recarga bem-sucedida: a organização fica pronta.
  @override
  Future<void> recarregar() async {
    recarregamentos++;
    situacao = SituacaoOrganizacao.pronta;
    notifyListeners();
  }
}

/// Versão falsa do repositório de autenticação.
class AuthRepositoryFalso implements AuthRepository {
  AuthRepositoryFalso({
    this.falha,
    this.resultadoCadastro = ResultadoCadastro.logado,
  });

  /// Se definida, `entrar` e `cadastrar` lançam esta falha.
  final FalhaAutenticacao? falha;

  /// O que `cadastrar` deve devolver quando não há falha.
  final ResultadoCadastro resultadoCadastro;

  int tentativasDeLogin = 0;
  int saidas = 0;
  int recuperacoesEnviadas = 0;
  String? nomeCadastrado;
  String? organizacaoCadastrada;

  @override
  Future<void> entrar({required String email, required String senha}) async {
    tentativasDeLogin++;
    if (falha != null) throw falha!;
  }

  @override
  Future<ResultadoCadastro> cadastrar({
    required String nomeOrganizacao,
    required String nome,
    required String email,
    required String senha,
  }) async {
    if (falha != null) throw falha!;
    nomeCadastrado = nome;
    organizacaoCadastrada = nomeOrganizacao;
    return resultadoCadastro;
  }

  @override
  Future<void> enviarRecuperacaoSenha(String email) async {
    recuperacoesEnviadas++;
  }

  @override
  Future<void> sair() async => saidas++;
}

/// Versão falsa do repositório da organização.
class OrganizacaoRepositoryFalso implements OrganizacaoRepository {
  OrganizacaoRepositoryFalso({this.nome, this.nomeOrganizacao});

  /// Dados que "vieram do cadastro".
  final String? nome;
  final String? nomeOrganizacao;

  String? organizacaoCriada;

  @override
  Future<MembroAtual?> buscarMembroAtual() async => null;

  @override
  DadosCadastro dadosDoCadastro() =>
      (nome: nome, nomeOrganizacao: nomeOrganizacao);

  @override
  Future<void> criarOrganizacao({
    required String nomeOrganizacao,
    required String nomeMembro,
  }) async {
    organizacaoCriada = nomeOrganizacao;
  }
}

/// Monta o app completo com dependências falsas.
///
/// Use `esperarAnimacoes: false` em telas com animação contínua
/// (como um indicador de carregamento), que nunca "terminam".
Future<SharedPreferences> montarApp(
  WidgetTester tester,
  EstadoAutenticacao auth, {
  AuthRepository? authRepository,
  EstadoOrganizacao? organizacao,
  OrganizacaoRepository? organizacaoRepository,
  bool esperarAnimacoes = true,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferencias = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        preferenciasProvider.overrideWithValue(preferencias),
        estadoAutenticacaoProvider.overrideWithValue(auth),
        authRepositoryProvider.overrideWithValue(
          authRepository ?? AuthRepositoryFalso(),
        ),
        estadoOrganizacaoProvider.overrideWithValue(
          organizacao ?? EstadoOrganizacaoFalso(),
        ),
        organizacaoRepositoryProvider.overrideWithValue(
          organizacaoRepository ?? OrganizacaoRepositoryFalso(),
        ),
      ],
      child: const GeraOsApp(),
    ),
  );

  if (esperarAnimacoes) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 100));
  }
  return preferencias;
}
