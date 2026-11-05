import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/estado_autenticacao.dart';
import '../domain/membro_atual.dart';
import 'organizacao_repository.dart';

enum SituacaoOrganizacao { carregando, semOrganizacao, pronta, erro }

/// Diz se a pessoa logada já tem organização e avisa quando isso muda.
abstract class EstadoOrganizacao extends ChangeNotifier {
  SituacaoOrganizacao get situacao;
  MembroAtual? get membro;
  Future<void> recarregar();

  /// Busca o membro de novo sem passar por "carregando", para refletir
  /// mudanças (como o nome da empresa) sem tirar a pessoa da tela atual.
  /// A versão real faz a busca; esta, usada nos testes, não faz nada.
  Future<void> atualizarMembro() async {}
}

class EstadoOrganizacaoSupabase extends EstadoOrganizacao {
  EstadoOrganizacaoSupabase(this._repositorio, this._auth) {
    _auth.addListener(_aoMudarLogin);
    _aoMudarLogin();
  }

  final OrganizacaoRepository _repositorio;
  final EstadoAutenticacao _auth;

  SituacaoOrganizacao _situacao = SituacaoOrganizacao.carregando;
  MembroAtual? _membro;
  String? _usuarioCarregado;
  bool _descartado = false;

  @override
  SituacaoOrganizacao get situacao => _situacao;

  @override
  MembroAtual? get membro => _membro;

  void _aoMudarLogin() {
    final usuarioId = _auth.usuarioId;
    if (usuarioId == _usuarioCarregado) return;
    _usuarioCarregado = usuarioId;

    if (usuarioId == null) {
      _membro = null;
      _alterar(SituacaoOrganizacao.carregando);
    } else {
      recarregar();
    }
  }

  @override
  Future<void> recarregar() async {
    _alterar(SituacaoOrganizacao.carregando);
    try {
      _membro = await _repositorio.buscarMembroAtual();
      _alterar(
        _membro == null
            ? SituacaoOrganizacao.semOrganizacao
            : SituacaoOrganizacao.pronta,
      );
    } on Exception catch (erro) {
      if (kDebugMode) {
        debugPrint('EstadoOrganizacao: falha ao buscar o membro: $erro');
      }
      _alterar(SituacaoOrganizacao.erro);
    }
  }

  @override
  Future<void> atualizarMembro() async {
    try {
      final membro = await _repositorio.buscarMembroAtual();
      if (_descartado || membro == null) return;
      _membro = membro;
      notifyListeners();
    } on Exception catch (erro) {
      if (kDebugMode) {
        debugPrint('EstadoOrganizacao: falha ao atualizar o membro: $erro');
      }
    }
  }

  void _alterar(SituacaoOrganizacao nova) {
    if (_descartado) return;
    _situacao = nova;
    notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    _auth.removeListener(_aoMudarLogin);
    super.dispose();
  }
}

final estadoOrganizacaoProvider = Provider<EstadoOrganizacao>((ref) {
  final estado = EstadoOrganizacaoSupabase(
    ref.watch(organizacaoRepositoryProvider),
    ref.watch(estadoAutenticacaoProvider),
  );
  ref.onDispose(estado.dispose);
  return estado;
});

/// O membro logado. Diferente de `estadoOrganizacaoProvider`, as telas
/// que usam este provider são redesenhadas quando o membro muda.
final membroAtualProvider = Provider<MembroAtual?>((ref) {
  final estado = ref.watch(estadoOrganizacaoProvider);
  void aoMudar() => ref.invalidateSelf();
  estado.addListener(aoMudar);
  ref.onDispose(() => estado.removeListener(aoMudar));
  return estado.membro;
});

/// Os dados completos da empresa do membro logado.
final dadosEmpresaProvider = FutureProvider.autoDispose((ref) {
  final membro = ref.watch(membroAtualProvider);
  if (membro == null) throw StateError('Nenhuma empresa carregada.');
  return ref
      .watch(organizacaoRepositoryProvider)
      .buscarDadosEmpresa(membro.organizacaoId);
});
