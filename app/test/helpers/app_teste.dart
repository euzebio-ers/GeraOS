import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/app.dart';
import 'package:geraos/core/preferences/preferencias.dart';
import 'package:geraos/features/auth/data/auth_repository.dart';
import 'package:geraos/features/auth/data/estado_autenticacao.dart';
import 'package:geraos/features/auth/domain/falha_autenticacao.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Versão falsa do estado de login, controlada pelo próprio teste.
class EstadoAutenticacaoFalso extends EstadoAutenticacao {
  EstadoAutenticacaoFalso({required this.logado});

  @override
  bool logado;

  void alterarLogin(bool valor) {
    logado = valor;
    notifyListeners();
  }
}

/// Versão falsa do repositório: não usa rede e registra as chamadas.
class AuthRepositoryFalso implements AuthRepository {
  AuthRepositoryFalso({this.falha});

  /// Se definida, `entrar` lança esta falha.
  final FalhaAutenticacao? falha;

  int tentativasDeLogin = 0;
  int saidas = 0;

  @override
  Future<void> entrar({required String email, required String senha}) async {
    tentativasDeLogin++;
    if (falha != null) throw falha!;
  }

  @override
  Future<void> sair() async => saidas++;
}

/// Monta o app completo com dependências falsas.
Future<SharedPreferences> montarApp(
  WidgetTester tester,
  EstadoAutenticacao auth, {
  AuthRepository? authRepository,
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
      ],
      child: const GeraOsApp(),
    ),
  );
  await tester.pumpAndSettle();
  return preferencias;
}
