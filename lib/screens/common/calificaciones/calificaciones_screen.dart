import 'package:flutter/material.dart';

class CalificacionesScreen extends StatelessWidget {
  const CalificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Calificaciones de usuarios')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.star_outline, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text('Calificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text('Promedio y comentarios de usuarios.', textAlign: TextAlign.center),
            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: Icon(Icons.star, color: gold),
                title: const Text('Promedio'),
                subtitle: const Text('0.0 / 5.0 (demo)'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (_, i) => ListTile(
                  leading: Icon(Icons.person, color: gold),
                  title: Text('Usuario #${i + 1}'),
                  subtitle: const Text('Comentario demo'),
                  trailing: const Text('⭐ 5'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
