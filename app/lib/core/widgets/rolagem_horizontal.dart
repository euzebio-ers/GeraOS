import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lista deitada que também anda com a roda do mouse.
///
/// Por padrão a roda do mouse só rola para cima e para baixo, então numa
/// lista horizontal (como os filtros) ela não fazia nada. Aqui a roda
/// move a lista para o lado. Use só onde não há rolagem vertical por perto,
/// senão a roda deixaria de rolar a tela.
class RolagemHorizontal extends StatefulWidget {
  const RolagemHorizontal({super.key, required this.children, this.padding});

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  State<RolagemHorizontal> createState() => _RolagemHorizontalState();
}

class _RolagemHorizontalState extends State<RolagemHorizontal> {
  final _controle = ScrollController();

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  void _aoRolar(PointerSignalEvent evento) {
    if (evento is! PointerScrollEvent || !_controle.hasClients) return;

    // Gesto já horizontal (touchpad) ou Shift + roda: o Flutter resolve.
    final delta = evento.scrollDelta;
    if (delta.dx.abs() >= delta.dy.abs()) return;
    if (HardwareKeyboard.instance.isShiftPressed) return;

    final posicao = _controle.position;
    final destino = (posicao.pixels + delta.dy)
        .clamp(posicao.minScrollExtent, posicao.maxScrollExtent)
        .toDouble();
    _controle.jumpTo(destino);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _aoRolar,
      child: ListView(
        controller: _controle,
        scrollDirection: Axis.horizontal,
        padding: widget.padding,
        children: widget.children,
      ),
    );
  }
}
