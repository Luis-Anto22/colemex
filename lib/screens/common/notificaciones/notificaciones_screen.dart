import 'package:flutter/material.dart';

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.notifications_none, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text('Notificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text('Avisos de asignaciones, mensajes y alertas.', textAlign: TextAlign.center),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.separated(
                itemCount: 8,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) => ListTile(
                  leading: Icon(Icons.circle, color: gold, size: 12),
                  title: Text('Notificación #${i + 1}'),
                  subtitle: const Text('Contenido demo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
