import 'package:flutter/material.dart';

import '../../../../core/formatting/moeda.dart';
import '../../domain/dados_item.dart';
import '../../domain/os_detalhe.dart';

/// O que a pessoa decidiu na janela do item.
sealed class ResultadoItem {
  const ResultadoItem();
}

class SalvarItem extends ResultadoItem {
  const SalvarItem(this.dados);

  final DadosItem dados;
}

class RemoverItem extends ResultadoItem {
  const RemoverItem();
}

/// Janela para incluir (sem `item`) ou editar (com `item`) um item da OS.
Future<ResultadoItem?> editarItem(BuildContext context, {ItemOs? item}) {
  return showDialog<ResultadoItem>(
    context: context,
    builder: (context) => _DialogoItem(item: item),
  );
}

class _DialogoItem extends StatefulWidget {
  const _DialogoItem({this.item});

  final ItemOs? item;

  @override
  State<_DialogoItem> createState() => _DialogoItemState();
}

class _DialogoItemState extends State<_DialogoItem> {
  final _formKey = GlobalKey<FormState>();

  late String _tipo = widget.item?.tipo ?? 'servico';
  late final _descricao = TextEditingController(text: widget.item?.descricao);
  late final _quantidade = TextEditingController(
    text: _textoQuantidade(widget.item?.quantidade ?? 1),
  );
  late final _valor = TextEditingController(
    text: switch (widget.item) {
      final ItemOs item => valorParaMascara(item.valorUnitario),
      null => '',
    },
  );

  bool get _editando => widget.item != null;

  /// 1.0 → "1"; 1.5 → "1,5".
  static String _textoQuantidade(double valor) => valor == valor.roundToDouble()
      ? valor.toInt().toString()
      : valor.toString().replaceAll('.', ',');

  @override
  void dispose() {
    _descricao.dispose();
    _quantidade.dispose();
    _valor.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      SalvarItem(
        DadosItem(
          id: widget.item?.id,
          tipo: _tipo,
          descricao: _descricao.text.trim(),
          quantidade: textoParaValor(_quantidade.text)!,
          valorUnitario: textoParaValor(_valor.text)!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return AlertDialog(
      title: Text(_editando ? 'Editar item' : 'Adicionar item'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'servico', label: Text('Serviço')),
                    ButtonSegment(value: 'peca', label: Text('Peça')),
                  ],
                  selected: {_tipo},
                  onSelectionChanged: (selecao) =>
                      setState(() => _tipo = selecao.first),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricao,
                  autofocus: !_editando,
                  decoration: const InputDecoration(
                    labelText: 'Descrição *',
                    hintText: 'Ex.: Troca de tela',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (valor) {
                    final texto = valor?.trim() ?? '';
                    if (texto.length < 2) return 'Descreva o item.';
                    if (texto.length > 300) {
                      return 'Use no máximo 300 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 88,
                      child: TextFormField(
                        controller: _quantidade,
                        decoration: const InputDecoration(labelText: 'Qtd.'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (valor) {
                          final quantidade = textoParaValor(valor ?? '');
                          return quantidade == null || quantidade <= 0
                              ? 'Inválida'
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _valor,
                        decoration: const InputDecoration(
                          labelText: 'Valor unitário *',
                          prefixText: 'R\$ ',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [MascaraMoeda()],
                        validator: (valor) =>
                            textoParaValor(valor ?? '') == null
                            ? 'Informe o valor.'
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (_editando)
          TextButton(
            onPressed: () => Navigator.of(context).pop(const RemoverItem()),
            style: TextButton.styleFrom(
              foregroundColor: tema.colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvar,
          style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
