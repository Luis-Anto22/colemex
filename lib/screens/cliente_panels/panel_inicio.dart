import 'package:flutter/material.dart';

class PanelInicio extends StatelessWidget {
  final String nombreUsuario;

  const PanelInicio({super.key, required this.nombreUsuario});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Hola $nombreUsuario 👋',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/buscar-abogado');
          },
          child: const Text('Buscar Abogado'),
        ),
      ],
    );
  }
}