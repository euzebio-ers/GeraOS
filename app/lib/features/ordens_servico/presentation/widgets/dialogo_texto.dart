import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Abre uma janela com um campo de texto e devolve o que foi digitado,
/// ou `null` se a pessoa cancelar.
Future<String?> pedirTexto(
  BuildContext context, {
  required String titulo,
  required String rotulo,
  String? inicial,
  String? ajuda,
  bool obrigatorio = false,
  int minLinhas = 1,
  int? maximoCaracteres,
  String textoConfirmar = 'Salvar',
  String textoDesistir = 'Cancelar',
  String? prefixo,
  TextInputType? teclado,
  List<TextInputFormatter>? formatadores,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _DialogoTexto(
      titulo: titulo,
      rotulo: rotulo,
      inicial: inicial,
      ajuda: ajuda,
      obrigatorio: obrigatorio,
      minLinhas: minLinhas,
      maximoCaracteres: maximoCaracteres,
      textoConfirmar: textoConfirmar,
      textoDesistir: textoDesistir,
      prefixo: prefixo,
      teclado: teclado,
      formatadores: formatadores,
    ),
  );
}

class _DialogoTexto extends StatefulWidget {
  const _DialogoTexto({
    required this.titulo,
    required this.rotulo,
    required this.obrigatorio,
    required this.minLinhas,
    required this.textoConfirmar,
    required this.textoDesistir,
    this.inicial,
    this.ajuda,
    this.maximoCaracteres,
    this.prefixo,
    this.teclado,
    this.formatadores,
  });

  final String titulo;
  final String rotulo;
  final String? inicial;
  final String? ajuda;
  final bool obrigatorio;
  final int minLinhas;
  final int? maximoCaracteres;
  final String textoConfirmar;
  final String textoDesistir;
  final String? prefixo;
  final TextInputType? teclado;
  final List<TextInputFormatter>? formatadores;

  @override
  State<_DialogoTexto> createState() => _DialogoTextoState();
}

class _DialogoTextoState extends State<_DialogoTexto> {
  final _formKey = GlobalKey<FormState>();
  late final _campo = TextEditingController(text: widget.inicial);

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_campo.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _campo,
            autofocus: true,
            minLines: widget.minLinhas,
            maxLines: widget.minLinhas > 1 ? 6 : 1,
            maxLength: widget.maximoCaracteres,
            keyboardType: widget.teclado,
            inputFormatters: widget.formatadores,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: widget.rotulo,
              helperText: widget.ajuda,
              prefixText: widget.prefixo,
              alignLabelWithHint: true,
            ),
            validator: widget.obrigatorio
                ? (valor) => (valor ?? '').trim().isEmpty
                      ? 'Preencha este campo.'
                      : null
                : null,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.textoDesistir),
        ),
        FilledButton(
          onPressed: _confirmar,
          style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
          child: Text(widget.textoConfirmar),
        ),
      ],
    );
  }
}
