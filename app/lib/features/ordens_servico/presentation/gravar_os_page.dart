import 'package:flutter/material.dart';

class GravarOsPage extends StatelessWidget {
  const GravarOsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova OS por áudio')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'A gravação por áudio chega na Fase 2.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
