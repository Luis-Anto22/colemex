import 'package:flutter/material.dart';

class EstadoWidget extends StatelessWidget {
  const EstadoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = "Disponible"; // luego vendrá de la API

    return Card(
      child: ListTile(
        leading: Icon(
          estado == "Disponible" ? Icons.circle : Icons.remove_circle,
          color: estado == "Disponible" ? Colors.green : Colors.red,
        ),
        title: const Text("Estado"),
        subtitle: Text(estado),
      ),
    );
  }
}