import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/ambiente.dart';
import 'core/preferences/preferencias.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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