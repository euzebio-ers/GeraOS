import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/app.dart';
import 'package:geraos/core/preferences/preferencias.dart';
import 'package:geraos/features/auth/data/auth_repository.dart';
import 'package:geraos/features/auth/data/estado_autenticacao.dart';
import 'package:geraos/features/auth/domain/falha_autenticacao.dart';
import 'package:geraos/features/auth/domain/resultado_cadastro.dart';
import 'package:geraos/features/clientes/data/clientes_repository.dart';
import 'package:geraos/features/clientes/domain/cliente.dart';
import 'package:geraos/features/clientes/domain/cliente_resumo.dart';
import 'package:geraos/features/ordens_servico/data/ordens_servico_repository.dart';
import 'package:geraos/features/ordens_servico/domain/dados_item.dart';
import 'package:geraos/features/ordens_servico/domain/faturamento.dart';
import 'package:geraos/features/ordens_servico/domain/filtro_status.dart';
import 'package:geraos/features/ordens_servico/domain/nova_os.dart';
import 'package:geraos/features/ordens_servico/domain/os_detalhe.dart';
import 'package:geraos/features/ordens_servico/domain/os_resumo.dart';
import 'package:geraos/features/ordens_servico/domain/status_os.dart';
import 'package:geraos/features/organizacao/data/estado_organizacao.dart';
import 'package:geraos/features/organizacao/data/organizacao_repository.dart';
import 'package:geraos/features/organizacao/domain/dados_empresa.dart';
import 'package:geraos/features/organizacao/domain/membro_atual.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Versão falsa do estado de login, controlada pelo próprio teste.
class EstadoAutenticacaoFalso extends EstadoAutenticacao {
  EstadoAutenticacaoFalso({
    required this.logado,
    this.recuperandoSenha = false,
  });

  @override
  bool logado;

  @override
  bool recuperandoSenha;

  @override
  String? get usuarioId => logado ? 'usuario-teste' : null;

  void alterarLogin(bool valor) {
    logado = valor;
    notifyListeners();
  }

  @override
  void concluirRecuperacao() {
    recuperandoSenha = false;
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
  String? novaSenhaDefinida;

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
  Future<void> definirNovaSenha(String senha) async {
    novaSenhaDefinida = senha;
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

  /// O que `buscarDadosEmpresa` devolve.
  DadosEmpresa dadosEmpresa = const DadosEmpresa(nome: 'TecFix Assistência');

  /// Os últimos dados enviados para `salvarDadosEmpresa`.
  DadosEmpresa? dadosSalvos;

  @override
  Future<DadosEmpresa> buscarDadosEmpresa(String organizacaoId) async =>
      dadosEmpresa;

  @override
  Future<void> salvarDadosEmpresa(
    String organizacaoId,
    DadosEmpresa dados,
  ) async {
    dadosSalvos = dados;
  }

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

/// Versão falsa do repositório de clientes, com uma lista fixa.
class ClientesRepositoryFalso implements ClientesRepository {
  ClientesRepositoryFalso({this.clientes = const []});

  final List<ClienteResumo> clientes;

  /// O último cliente enviado para `salvar`.
  Cliente? salvo;

  @override
  Future<List<ClienteResumo>> listar({String busca = ''}) async {
    final termo = busca.toLowerCase();
    return clientes
        .where((cliente) => cliente.nome.toLowerCase().contains(termo))
        .toList();
  }

  @override
  Future<Cliente> buscarPorId(String id) async {
    final resumo = clientes.firstWhere((cliente) => cliente.id == id);
    return Cliente(
      id: resumo.id,
      nome: resumo.nome,
      telefone: resumo.telefone,
      email: resumo.email,
    );
  }

  @override
  Future<String> salvar(Cliente cliente) async {
    salvo = cliente;
    return cliente.id ?? 'id-novo';
  }
}

/// Versão falsa do repositório de OS, com dados fixos.
/// As alterações ficam registradas para o teste conferir.
class OrdensServicoRepositoryFalso implements OrdensServicoRepository {
  OrdensServicoRepositoryFalso({
    this.ordens = const [],
    this.detalhes = const {},
  });

  final List<OsResumo> ordens;

  /// O detalhe de cada OS, pelo id.
  final Map<String, OsDetalhe> detalhes;

  NovaOs? criada;
  StatusOs? statusAlterado;
  String? motivo;
  String? diagnosticoSalvo;
  double? descontoSalvo;
  DadosItem? itemSalvo;
  String? itemRemovido;

  /// O que `faturamentoDoMes` devolve (zero, se não for definido).
  Faturamento? faturamento;

  @override
  Future<OsCriada> criarDigitada(NovaOs os) async {
    criada = os;
    return (id: 'os-teste', numero: 42);
  }

  @override
  Future<List<OsResumo>> listar({
    FiltroStatus filtro = FiltroStatus.todas,
    String busca = '',
    int pagina = 0,
    int? limite,
  }) async {
    final termo = busca.toLowerCase();
    final filtradas = ordens.where((os) {
      final noFiltro =
          filtro == FiltroStatus.todas || filtro.status.contains(os.status);
      final naBusca =
          os.clienteNome.toLowerCase().contains(termo) ||
          os.equipamento.toLowerCase().contains(termo);
      return noFiltro && naBusca;
    }).toList();

    final tamanho = limite ?? OrdensServicoRepository.tamanhoPagina;
    return filtradas.skip(pagina * tamanho).take(tamanho).toList();
  }

  @override
  Future<Map<StatusOs, int>> contarPorStatus() async {
    final contagem = <StatusOs, int>{};
    for (final os in ordens) {
      contagem[os.status] = (contagem[os.status] ?? 0) + 1;
    }
    return contagem;
  }

  @override
  Future<Faturamento> faturamentoDoMes() async =>
      faturamento ??
      Faturamento(mes: DateTime(2026, 11), total: 0, quantidade: 0);

  @override
  Future<OsDetalhe> buscarDetalhe(String id) async {
    final detalhe = detalhes[id];
    if (detalhe == null) throw const OsNaoEncontrada();
    return detalhe;
  }

  @override
  Future<void> alterarStatus(
    String osId,
    StatusOs novo, {
    String? observacao,
  }) async {
    statusAlterado = novo;
    motivo = observacao;
  }

  @override
  Future<void> salvarDiagnostico(String osId, String? diagnostico) async {
    diagnosticoSalvo = diagnostico;
  }

  @override
  Future<void> salvarDesconto(String osId, double desconto) async {
    descontoSalvo = desconto;
  }

  @override
  Future<void> salvarItem(String osId, DadosItem item) async {
    itemSalvo = item;
  }

  @override
  Future<void> removerItem(String itemId) async {
    itemRemovido = itemId;
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
  ClientesRepository? clientesRepository,
  OrdensServicoRepository? ordensServicoRepository,
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
        clientesRepositoryProvider.overrideWithValue(
          clientesRepository ?? ClientesRepositoryFalso(),
        ),
        ordensServicoRepositoryProvider.overrideWithValue(
          ordensServicoRepository ?? OrdensServicoRepositoryFalso(),
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
