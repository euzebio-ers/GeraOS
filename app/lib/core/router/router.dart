import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/estado_autenticacao.dart';
import '../../features/auth/presentation/cadastro_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/nova_senha_page.dart';
import '../../features/auth/presentation/recuperar_senha_page.dart';
import '../../features/clientes/presentation/cliente_form_page.dart';
import '../../features/clientes/presentation/clientes_page.dart';
import '../../features/clientes/presentation/ficha_cliente_page.dart';
import '../../features/configuracoes/presentation/configuracoes_page.dart';
import '../../features/inicio/presentation/inicio_page.dart';
import '../../features/ordens_servico/presentation/detalhe_os_page.dart';
import '../../features/ordens_servico/presentation/gravar_os_page.dart';
import '../../features/ordens_servico/presentation/lista_os_page.dart';
import '../../features/ordens_servico/presentation/nova_os_page.dart';
import '../../features/ordens_servico/presentation/pdf_os_page.dart';
import '../../features/organizacao/data/estado_organizacao.dart';
import '../../features/organizacao/presentation/configurar_organizacao_page.dart';
import '../../features/organizacao/presentation/dados_empresa_page.dart';
import '../../features/organizacao/presentation/preparando_page.dart';
import '../widgets/casca_app.dart';
import 'destino.dart';
import 'rotas.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(estadoAutenticacaoProvider);
  final organizacao = ref.watch(estadoOrganizacaoProvider);

  /// Navegador principal, acima das abas. Telas abertas nele
  /// ocupam a tela inteira, sem a barra de abas embaixo.
  final chaveRaiz = GlobalKey<NavigatorState>();

  final router = GoRouter(
    navigatorKey: chaveRaiz,
    initialLocation: Rotas.paginaInicial,
    refreshListenable: Listenable.merge([auth, organizacao]),
    redirect: (context, state) {
      final local = state.matchedLocation;
      final telaPublica = Rotas.publicas.contains(local);
      final telaDeEntrada = telaPublica || Rotas.entrada.contains(local);

      // Para onde a pessoa queria ir. Nas telas de entrada, ele vem guardado
      // no parâmetro "de"; nas outras, é o próprio endereço pedido.
      final pedido = destinoSeguro(
        telaDeEntrada ? state.uri.queryParameters['de'] : state.uri.toString(),
      );

      // Vai para uma tela de entrada levando o destino junto.
      String irPara(String rota) => pedido == null
          ? rota
          : Uri(path: rota, queryParameters: {'de': pedido}).toString();

      // 1. Sem login: só as telas públicas.
      if (!auth.logado) return telaPublica ? null : irPara(Rotas.login);

      // 2. Veio pelo link de nova senha: primeiro troca a senha.
      if (auth.recuperandoSenha) {
        return local == Rotas.novaSenha ? null : Rotas.novaSenha;
      }
      if (local == Rotas.novaSenha) return null;

      // 3. Logado, mas a empresa ainda não está pronta.
      final destino = switch (organizacao.situacao) {
        SituacaoOrganizacao.carregando ||
        SituacaoOrganizacao.erro => Rotas.preparando,
        SituacaoOrganizacao.semOrganizacao => Rotas.configurarOrganizacao,
        SituacaoOrganizacao.pronta => null,
      };
      if (destino != null) return local == destino ? null : irPara(destino);

      // 4. Tudo pronto: das telas de entrada, segue para onde a pessoa
      //    queria ir, ou para a página inicial.
      return telaDeEntrada ? (pedido ?? Rotas.paginaInicial) : null;
    },
    routes: [
      GoRoute(
        path: Rotas.raiz,
        redirect: (context, state) => Rotas.paginaInicial,
      ),

      // Entrada
      GoRoute(
        path: Rotas.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Rotas.cadastro,
        builder: (context, state) => const CadastroPage(),
      ),
      GoRoute(
        path: Rotas.recuperarSenha,
        builder: (context, state) => const RecuperarSenhaPage(),
      ),
      GoRoute(
        path: Rotas.novaSenha,
        builder: (context, state) => const NovaSenhaPage(),
      ),
      GoRoute(
        path: Rotas.preparando,
        builder: (context, state) => const PreparandoPage(),
      ),
      GoRoute(
        path: Rotas.configurarOrganizacao,
        builder: (context, state) => const ConfigurarOrganizacaoPage(),
      ),

      // Abas
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            CascaApp(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rotas.inicio,
                builder: (context, state) => const InicioPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rotas.ordensServico,
                builder: (context, state) =>
                    ListaOsPage(selecionada: state.uri.queryParameters['os']),
                routes: [
                  // "nova" vem antes de ":id", senão seria lido como um id.
                  GoRoute(
                    path: 'nova',
                    parentNavigatorKey: chaveRaiz,
                    builder: (context, state) => const NovaOsPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: chaveRaiz,
                    builder: (context, state) =>
                        DetalheOsPage(osId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'pdf',
                        parentNavigatorKey: chaveRaiz,
                        builder: (context, state) =>
                            PdfOsPage(osId: state.pathParameters['id']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rotas.clientes,
                builder: (context, state) => ClientesPage(
                  selecionado: state.uri.queryParameters['cliente'],
                ),
                routes: [
                  // "novo" vem antes de ":id", senão seria lido como um id.
                  GoRoute(
                    path: 'novo',
                    parentNavigatorKey: chaveRaiz,
                    builder: (context, state) => const ClienteFormPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: chaveRaiz,
                    builder: (context, state) => FichaClientePage(
                      clienteId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'editar',
                        parentNavigatorKey: chaveRaiz,
                        builder: (context, state) => ClienteFormPage(
                          clienteId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rotas.mais,
                builder: (context, state) => const ConfiguracoesPage(),
                routes: [
                  GoRoute(
                    path: 'empresa',
                    parentNavigatorKey: chaveRaiz,
                    builder: (context, state) => const DadosEmpresaPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Por cima das abas
      GoRoute(
        path: Rotas.gravarOs,
        builder: (context, state) => const GravarOsPage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
