import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/core/theme/app_theme.dart';
import 'package:geraos/core/theme/cores_geraos.dart';

/// Contraste entre duas cores, pela fórmula da norma WCAG.
double contraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (maisClara, maisEscura) = la > lb ? (la, lb) : (lb, la);
  return (maisClara + 0.05) / (maisEscura + 0.05);
}

void main() {
  const temas = [('claro', CoresGeraOs.claro), ('escuro', CoresGeraOs.escuro)];

  for (final (nome, cores) in temas) {
    test('Etiquetas de status legíveis no tema $nome (WCAG AA)', () {
      for (final status in cores.todosOsStatus) {
        expect(
          contraste(status.texto, status.fundo),
          greaterThanOrEqualTo(4.5),
        );
      }
    });

    test('Cartão "Gravar nova OS" legível no tema $nome', () {
      expect(
        contraste(cores.cartaoGravarTexto, cores.cartaoGravarFundo),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contraste(cores.cartaoGravarSubtexto, cores.cartaoGravarFundo),
        greaterThanOrEqualTo(4.5),
      );
    });
  }

  test('Os dois temas trazem as cores do GeraOS', () {
    expect(AppTheme.claro().extension<CoresGeraOs>(), isNotNull);
    expect(AppTheme.escuro().extension<CoresGeraOs>(), isNotNull);
  });
}
