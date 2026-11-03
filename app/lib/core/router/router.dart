import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/estado_autenticacao.dart';
import '../../features/auth/presentation/cadastro_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/recuperar_senha_page.dart';
import '../../features/configuracoes/presentation/configuracoes_page.dart';
import '../../features/ordens_servico/presentation/lista_os_page.dart';
import '../../features/organizacao/data/estado_organizacao.dart';
import '../../features/organizacao/presentation/configurar_organizacao_page.dart';
import '../../features/organizacao/presentation/preparando_page.dart';
import 'rotas.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(estadoAutenticacaoProvider);
  final organizacao = ref.watch(estadoOrganizacaoProvider);

  final router = GoRouter(
    initialLocation: Rotas.ordensServico,
    refreshListenable: Listenable.merge([auth, organizacao]),
    redirect: (context, state) {
      final local = state.matchedLocation;
      final telaPublica = Rotas.publicas.contains(local);

      // 1. Sem login: só as telas públicas.
      if (!auth.logado) return telaPublica ? null : Rotas.login;

      // 2. Logado, mas a empresa ainda não está pronta.
      final destino = switch (organizacao.situacao) {
        SituacaoOrganizacao.carregando ||
        SituacaoOrganizacao.erro => Rotas.preparando,
        SituacaoOrganizacao.semOrganizacao => Rotas.configurarOrganizacao,
        SituacaoOrganizacao.pronta => null,
      };
      if (destino != null) return local == destino ? null : destino;

      // 3. Tudo pronto: não faz sentido ficar nas telas de entrada.
      final telaDeEntrada = telaPublica || Rotas.entrada.contains(local);
      return telaDeEntrada ? Rotas.ordensServico : null;
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
        path: Rotas.recuperarSenha,
        builder: (context, state) => const RecuperarSenhaPage(),
      ),
      GoRoute(
        path: Rotas.preparando,
        builder: (context, state) => const PreparandoPage(),
      ),
      GoRoute(
        path: Rotas.configurarOrganizacao,
        builder: (context, state) => const ConfigurarOrganizacaoPage(),
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
