import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Um pedido para colocar o cursor na busca da lista de OS, feito pelo
/// atalho "/". A lista atende o pedido e o limpa.
class BuscaSolicitada extends Notifier<bool> {
  @override
  bool build() => false;

  void pedir() => state = true;

  void limpar() => state = false;
}

final buscaSolicitadaProvider = NotifierProvider<BuscaSolicitada, bool>(
  BuscaSolicitada.new,
);
