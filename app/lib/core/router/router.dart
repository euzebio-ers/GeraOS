import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/estado_autenticacao.dart';
import '../../features/auth/presentation/cadastro_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/configuracoes/presentation/configuracoes_page.dart';
import '../../features/ordens_servico/presentation/lista_os_page.dart';
import 'rotas.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(estadoAutenticacaoProvider);

  final router = GoRouter(
    initialLocation: Rotas.ordensServico,
    refreshListenable: auth,
    redirect: (context, state) {
      final telaPublica = Rotas.publicas.contains(state.matchedLocation);

      if (!auth.logado && !telaPublica) return Rotas.login;
      if (auth.logado && telaPublica) return Rotas.ordensServico;
      return null;
    },
    routes: [
      GoRoute(
        path: Rotas.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Rotas.cadastro,
        builder: (context, state) => const CadastroPage(),
      ),
      GoRoute(
        path: Rotas.ordensServico,
        builder: (context, state) => const ListaOsPage(),
      ),
      GoRoute(
        path: Rotas.configuracoes,
        builder: (context, state) => const ConfiguracoesPage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
