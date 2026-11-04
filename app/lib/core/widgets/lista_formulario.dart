import 'package:flutter/material.dart';

/// Área rolável para formulários.
///
/// Diferente do `ListView`, monta todos os campos de uma vez. Num `ListView`,
/// campos fora da tela ainda não existem, e o `Form` não os valida: um campo
/// obrigatório no fim do formulário poderia passar sem ser conferido.
class ListaFormulario extends StatelessWidget {
  const ListaFormulario({super.key, required this.children, this.padding});

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
