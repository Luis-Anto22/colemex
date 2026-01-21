import 'package:flutter/material.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda / citas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.event_available_outlined, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text('Agenda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text('Aquí mostrarás tus citas, disponibilidad y horarios.', textAlign: TextAlign.center),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.separated(
                itemCount: 6,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) => ListTile(
                  leading: Icon(Icons.calendar_today, color: gold),
                  title: Text('Cita #${i + 1}'),
                  subtitle: const Text('Pendiente de conectar con backend'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
