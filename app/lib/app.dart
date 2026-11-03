import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'core/config/ambiente.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/tema_controller.dart';

class GeraOsApp extends ConsumerWidget {
  const GeraOsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'GeraOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(),
      darkTheme: AppTheme.escuro(),
      themeMode: ref.watch(temaProvider),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const _TelaProvisoria(),
    );
  }
}

/// Tela temporária para conferir tema e idioma. Será substituída pelas rotas na parte 4.3.
class _TelaProvisoria extends ConsumerWidget {
  const _TelaProvisoria();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizacao = MaterialLocalizations.of(context);
    final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

    return Scaffold(
      appBar: AppBar(title: const Text('GeraOS')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Ambiente: ${Ambiente.nome}'),
          const SizedBox(height: 8),
          Text(localizacao.formatFullDate(DateTime.now())),
          Text(moeda.format(1234.56)),
          const SizedBox(height: 24),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Claro'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('Sistema'),
                icon: Icon(Icons.brightness_auto),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Escuro'),
                icon: Icon(Icons.dark_mode),
              ),
            ],
            selected: {ref.watch(temaProvider)},
            onSelectionChanged: (selecao) =>
                ref.read(temaProvider.notifier).alterar(selecao.first),
          ),
          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(labelText: 'Nome do cliente'),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: () {}, child: const Text('Salvar')),
        ],
      ),
    );
  }
}