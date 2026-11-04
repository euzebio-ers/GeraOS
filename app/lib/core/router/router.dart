import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/estado_autenticacao.dart';
import '../../features/auth/presentation/cadastro_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/nova_senha_page.dart';
import '../../features/auth/presentation/recuperar_senha_page.dart';
import '../../features/clientes/presentation/clientes_page.dart';
import '../../features/configuracoes/presentation/configuracoes_page.dart';
import '../../features/inicio/presentation/inicio_page.dart';
import '../../features/ordens_servico/presentation/gravar_os_page.dart';
import '../../features/ordens_servico/presentation/lista_os_page.dart';
import '../../features/organizacao/data/estado_organizacao.dart';
import '../../features/organizacao/presentation/configurar_organizacao_page.dart';
import '../../features/organizacao/presentation/preparando_page.dart';
import '../widgets/casca_app.dart';
import 'rotas.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(estadoAutenticacaoProvider);
  final organizacao = ref.watch(estadoOrganizacaoProvider);

  final router = GoRouter(
    initialLocation: Rotas.paginaInicial,
    refreshListenable: Listenable.merge([auth, organizacao]),
    redirect: (context, state) {
      final local = state.matchedLocation;
      final telaPublica = Rotas.publicas.contains(local);

      // 1. Sem login: só as telas públicas.
      if (!auth.logado) return telaPublica ? null : Rotas.login;

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
      if (destino != null) return local == destino ? null : destino;

      // 4. Tudo pronto: não faz sentido ficar nas telas de entrada.
      final telaDeEntrada = telaPublica || Rotas.entrada.contains(local);
      return telaDeEntrada ? Rotas.paginaInicial : null;
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
                builder: (context, state) => const ListaOsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rotas.clientes,
                builder: (context, state) => const ClientesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rotas.mais,
                builder: (context, state) => const ConfiguracoesPage(),
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
