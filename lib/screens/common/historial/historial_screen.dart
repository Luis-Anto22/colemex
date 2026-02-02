import 'package:flutter/material.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de servicios')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.history, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text('Historial', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text('Servicios anteriores, cierres y detalles.', textAlign: TextAlign.center),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (_, i) => Card(
                  child: ListTile(
                    leading: Icon(Icons.folder_open, color: gold),
                    title: Text('Servicio #${i + 1}'),
                    subtitle: const Text('Estado: Finalizado (demo)'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
