import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/busca_solicitada.dart';

/// Atalhos de teclado das telas com menu lateral:
/// "N" abre uma nova OS e "/" vai para a busca de OS.
///
/// Escuta o teclado diretamente, independentemente de onde esteja o foco.
/// Os atalhos não valem enquanto a pessoa digita num campo de texto, nem
/// quando outra tela ou janela está aberta por cima.
class AtalhosTeclado extends ConsumerStatefulWidget {
  const AtalhosTeclado({
    super.key,
    required this.child,
    required this.aoNovaOs,
    required this.aoBuscar,
  });

  final Widget child;
  final VoidCallback aoNovaOs;

  /// Troca para a aba Ordens. O cursor vai para a busca pelo pedido.
  final VoidCallback aoBuscar;

  @override
  ConsumerState<AtalhosTeclado> createState() => _AtalhosTecladoState();
}

class _AtalhosTecladoState extends ConsumerState<AtalhosTeclado> {
  /// A tela onde os atalhos estão. Só vale quando ela está na frente.
  ModalRoute<Object?>? _tela;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_aoTeclar);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tela = ModalRoute.of(context);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_aoTeclar);
    super.dispose();
  }

  /// O foco está num campo de texto?
  static bool _digitando() {
    final contexto = FocusManager.instance.primaryFocus?.context;
    if (contexto == null) return false;
    return contexto.widget is EditableText ||
        contexto.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  /// Devolve `true` quando a tecla foi usada por um atalho.
  bool _aoTeclar(KeyEvent evento) {
    if (evento is! KeyDownEvent || !mounted) return false;
    if (!(_tela?.isCurrent ?? true)) return false;
    if (_digitando()) return false;

    final teclado = HardwareKeyboard.instance;
    if (teclado.isControlPressed ||
        teclado.isMetaPressed ||
        teclado.isAltPressed) {
      return false;
    }

    if (evento.logicalKey == LogicalKeyboardKey.keyN) {
      widget.aoNovaOs();
      return true;
    }
    if (evento.logicalKey == LogicalKeyboardKey.slash) {
      widget.aoBuscar();
      ref.read(buscaSolicitadaProvider.notifier).pedir();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
