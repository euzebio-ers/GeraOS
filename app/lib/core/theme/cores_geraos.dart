import 'package:flutter/material.dart';

/// Par de cores de uma etiqueta de status.
@immutable
class CorStatus {
  const CorStatus({required this.fundo, required this.texto});

  final Color fundo;
  final Color texto;

  static CorStatus lerp(CorStatus a, CorStatus b, double t) => CorStatus(
    fundo: Color.lerp(a.fundo, b.fundo, t)!,
    texto: Color.lerp(a.texto, b.texto, t)!,
  );
}

/// Cores do GeraOS que não fazem parte do esquema padrão do Material.
@immutable
class CoresGeraOs extends ThemeExtension<CoresGeraOs> {
  const CoresGeraOs({
    required this.microfone,
    required this.cartaoGravarFundo,
    required this.cartaoGravarTexto,
    required this.cartaoGravarSubtexto,
    required this.pendente,
    required this.aguardandoAprovacao,
    required this.emAndamento,
    required this.pronta,
    required this.concluida,
    required this.cancelada,
  });

  /// Botão e ações de áudio.
  final Color microfone;

  /// Cartão "Gravar nova OS" da tela Início.
  final Color cartaoGravarFundo;
  final Color cartaoGravarTexto;
  final Color cartaoGravarSubtexto;

  /// Etiquetas de status da OS.
  final CorStatus pendente;
  final CorStatus aguardandoAprovacao;
  final CorStatus emAndamento;
  final CorStatus pronta;
  final CorStatus concluida;
  final CorStatus cancelada;

  List<CorStatus> get todosOsStatus => [
    pendente,
    aguardandoAprovacao,
    emAndamento,
    pronta,
    concluida,
    cancelada,
  ];

  static const claro = CoresGeraOs(
    microfone: Color(0xFFC2410C),
    cartaoGravarFundo: Color(0xFF0B5C4A),
    cartaoGravarTexto: Color(0xFFFFFFFF),
    cartaoGravarSubtexto: Color(0xFFCFE3DB),
    pendente: CorStatus(fundo: Color(0xFFFFF3D6), texto: Color(0xFF6B4600)),
    aguardandoAprovacao: CorStatus(
      fundo: Color(0xFFEFE7FB),
      texto: Color(0xFF5B2C91),
    ),
    emAndamento: CorStatus(fundo: Color(0xFFE0ECFF), texto: Color(0xFF1A3F9E)),
    pronta: CorStatus(fundo: Color(0xFFDDF3E6), texto: Color(0xFF0A5A3F)),
    concluida: CorStatus(fundo: Color(0xFFECEDEB), texto: Color(0xFF454B50)),
    cancelada: CorStatus(fundo: Color(0xFFFDE8E4), texto: Color(0xFF9A2B12)),
  );

  static const escuro = CoresGeraOs(
    microfone: Color(0xFFE0602A),
    cartaoGravarFundo: Color(0xFF1C2124),
    cartaoGravarTexto: Color(0xFFECEFEC),
    cartaoGravarSubtexto: Color(0xFFA3AAAE),
    pendente: CorStatus(fundo: Color(0xFF33290F), texto: Color(0xFFF5C86A)),
    aguardandoAprovacao: CorStatus(
      fundo: Color(0xFF2A1E40),
      texto: Color(0xFFCDB4F5),
    ),
    emAndamento: CorStatus(fundo: Color(0xFF142545), texto: Color(0xFFA9C7FF)),
    pronta: CorStatus(fundo: Color(0xFF12342A), texto: Color(0xFF7FE0C3)),
    concluida: CorStatus(fundo: Color(0xFF2A3034), texto: Color(0xFFC9CFCB)),
    cancelada: CorStatus(fundo: Color(0xFF3A1A14), texto: Color(0xFFF4A08A)),
  );

  @override
  CoresGeraOs copyWith() => this;

  @override
  CoresGeraOs lerp(CoresGeraOs? outro, double t) {
    if (outro == null) return this;
    return CoresGeraOs(
      microfone: Color.lerp(microfone, outro.microfone, t)!,
      cartaoGravarFundo: Color.lerp(
        cartaoGravarFundo,
        outro.cartaoGravarFundo,
        t,
      )!,
      cartaoGravarTexto: Color.lerp(
        cartaoGravarTexto,
        outro.cartaoGravarTexto,
        t,
      )!,
      cartaoGravarSubtexto: Color.lerp(
        cartaoGravarSubtexto,
        outro.cartaoGravarSubtexto,
        t,
      )!,
      pendente: CorStatus.lerp(pendente, outro.pendente, t),
      aguardandoAprovacao: CorStatus.lerp(
        aguardandoAprovacao,
        outro.aguardandoAprovacao,
        t,
      ),
      emAndamento: CorStatus.lerp(emAndamento, outro.emAndamento, t),
      pronta: CorStatus.lerp(pronta, outro.pronta, t),
      concluida: CorStatus.lerp(concluida, outro.concluida, t),
      cancelada: CorStatus.lerp(cancelada, outro.cancelada, t),
    );
  }
}

/// Atalho: `context.cores.microfone` em vez de
/// `Theme.of(context).extension<CoresGeraOs>()!.microfone`.
extension CoresDoTema on BuildContext {
  CoresGeraOs get cores => Theme.of(this).extension<CoresGeraOs>()!;
}
