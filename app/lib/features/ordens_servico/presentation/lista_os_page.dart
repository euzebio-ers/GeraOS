import 'package:flutter/material.dart';

class ListaOsPage extends StatelessWidget {
  const ListaOsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ordens')),
      body: const Center(child: Text('Nenhuma OS cadastrada ainda.')),
    );
  }
}
