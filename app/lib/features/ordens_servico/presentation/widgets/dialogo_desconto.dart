import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/formatting/moeda.dart';

/// O desconto escolhido: em reais (`valor`) ou em porcentagem (`percentual`).
/// Valor 0 e porcentagem nula significam "sem desconto".
typedef Desconto = ({double? valor, double? percentual});

/// 10.0 → "10%"; 12.5 → "12,5%".
String formatarPercentual(double valor) {
  final numero = valor == valor.roundToDouble()
      ? valor.toInt().toString()
      : valor.toString().replaceAll('.', ',');
  return '$numero%';
}

/// Janela para dar ou alterar o desconto da OS. Devolve `null` se a
/// pessoa cancelar.
Future<Desconto?> editarDesconto(
  BuildContext context, {
  required double subtotal,
  required double descontoAtual,
  double? percentualAtual,
}) {
  return showDialog<Desconto>(
    context: context,
    builder: (context) => _DialogoDesconto(
      subtotal: subtotal,
      descontoAtual: descontoAtual,
      percentualAtual: percentualAtual,
    ),
  );
}

class _DialogoDesconto extends StatefulWidget {
  const _DialogoDesconto({
    required this.subtotal,
    required this.descontoAtual,
    this.percentualAtual,
  });

  final double subtotal;
  final double descontoAtual;
  final double? percentualAtual;

  @override
  State<_DialogoDesconto> createState() => _DialogoDescontoState();
}

class _DialogoDescontoState extends State<_DialogoDesconto> {
  final _formKey = GlobalKey<FormState>();
  late final _campo = TextEditingController(text: _textoInicial());

  /// Começa em porcentagem, a não ser que já exista um desconto em reais.
  late bool _emPercentual =
      widget.percentualAtual != null || widget.descontoAtual == 0;

  String _textoInicial() {
    final percentual = widget.percentualAtual;
    if (percentual != null) {
      return formatarPercentual(percentual).replaceAll('%', '');
    }
    if (widget.descontoAtual > 0) return valorParaMascara(widget.descontoAtual);
    return '';
  }

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  /// O desconto em reais do que está digitado, ou `null` se vazio/inválido.
  double? get _descontoEmReais {
    final numero = textoParaValor(_campo.text);
    if (numero == null) return null;
    if (!_emPercentual) return numero;
    return (widget.subtotal * numero / 100 * 100).round() / 100;
  }

  String? _validar(String? texto) {
    if ((texto ?? '').trim().isEmpty) return null;
    final numero = textoParaValor(texto!);
    if (numero == null || numero <= 0) return 'Valor inválido.';
    if (_emPercentual && numero > 100) return 'Use no máximo 100%.';
    if (!_emPercentual && numero > widget.subtotal) {
      return 'O desconto não pode passar do subtotal.';
    }
    return null;
  }

  void _trocarModo(bool emPercentual) {
    setState(() {
      _emPercentual = emPercentual;
      _campo.clear();
    });
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    final numero = textoParaValor(_campo.text);
    final Desconto resultado = numero == null
        ? (valor: 0.0, percentual: null)
        : _emPercentual
        ? (valor: null, percentual: numero)
        : (valor: numero, percentual: null);
    Navigator.of(context).pop(resultado);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final emReais = _descontoEmReais;

    return AlertDialog(
      title: const Text('Desconto'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('%')),
                  ButtonSegment(value: false, label: Text('R\$')),
                ],
                selected: {_emPercentual},
                onSelectionChanged: (selecao) => _trocarModo(selecao.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: ValueKey(_emPercentual),
                controller: _campo,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: _emPercentual
                      ? 'Porcentagem de desconto'
                      : 'Valor do desconto',
                  prefixText: _emPercentual ? null : 'R\$ ',
                  suffixText: _emPercentual ? '%' : null,
                  helperText: 'Deixe vazio para remover o desconto.',
                ),
                keyboardType: _emPercentual
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.number,
                inputFormatters: _emPercentual
                    ? [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                        LengthLimitingTextInputFormatter(5),
                      ]
                    : [MascaraMoeda()],
                validator: _validar,
                onChanged: (_) => setState(() {}),
              ),
              if (_emPercentual && emReais != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Desconto de ${formatarMoeda(emReais)} sobre '
                  '${formatarMoeda(widget.subtotal)}. O valor acompanha '
                  'o orçamento se itens mudarem.',
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
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
