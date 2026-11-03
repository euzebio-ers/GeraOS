import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/ambiente.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Ambiente.validar();

  await Supabase.initialize(
    url: Ambiente.supabaseUrl,
    anonKey: Ambiente.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: GeraOsApp()));
}