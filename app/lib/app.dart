import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/tema_controller.dart';

class GeraOsApp extends ConsumerWidget {
  const GeraOsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'GeraOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(),
      darkTheme: AppTheme.escuro(),
      themeMode: ref.watch(temaProvider),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      scrollBehavior: const _ComArrasteDeMouse(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

/// Deixa arrastar listas com o mouse (por padrão só o toque arrasta).
class _ComArrasteDeMouse extends MaterialScrollBehavior {
  const _ComArrasteDeMouse();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}
