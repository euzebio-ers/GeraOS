/// Número da OS como aparece na tela: 42 → "#0042".
String formatarNumeroOs(int numero) => '#${numero.toString().padLeft(4, '0')}';
