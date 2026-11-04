import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/config/ambiente.dart';
import 'core/preferences/preferencias.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  _registrarLicencasDasFontes();

  Ambiente.validar();
  Intl.defaultLocale = 'pt_BR';

  final preferencias = await SharedPreferences.getInstance();

  await Supabase.initialize(
    url: Ambiente.supabaseUrl,
    publishableKey: Ambiente.supabasePublishableKey,
  );

  runApp(
    ProviderScope(
      overrides: [preferenciasProvider.overrideWithValue(preferencias)],
      child: const GeraOsApp(),
    ),
  );
}

/// A licença OFL das fontes pede que ela acompanhe o app.
void _registrarLicencasDasFontes() {
  LicenseRegistry.addLicense(() async* {
    const fontes = [
      ('Manrope', 'assets/fonts/OFL-Manrope.txt'),
      ('JetBrains Mono', 'assets/fonts/OFL-JetBrainsMono.txt'),
    ];
    for (final (familia, arquivo) in fontes) {
      yield LicenseEntryWithLineBreaks([
        familia,
      ], await rootBundle.loadString(arquivo));
    }
  });
}
