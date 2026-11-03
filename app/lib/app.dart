import 'package:flutter/material.dart';

import 'core/config/ambiente.dart';

class GeraOsApp extends StatelessWidget {
  const GeraOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeraOS',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'GeraOS\nAmbiente: ${Ambiente.nome}\n${Ambiente.supabaseUrl}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}