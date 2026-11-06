import 'package:flutter/material.dart';

import '../layout/larguras.dart';

/// Área rolável para formulários e telas de leitura.
///
/// Diferente do `ListView`, monta todos os campos de uma vez. Num `ListView`,
/// campos fora da tela ainda não existem, e o `Form` não os valida: um campo
/// obrigatório no fim do formulário poderia passar sem ser conferido.
///
/// Em telas largas, o conteúdo fica centralizado, com no máximo
/// [larguraMaxima] de largura, para a leitura continuar confortável.
class ListaFormulario extends StatelessWidget {
  const ListaFormulario({
    super.key,
    required this.children,
    this.padding,
    this.larguraMaxima = Larguras.conteudo,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double larguraMaxima;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: larguraMaxima),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
