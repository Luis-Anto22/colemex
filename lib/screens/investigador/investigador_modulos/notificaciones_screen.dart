import 'package:flutter/material.dart';

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? gold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(18),
          constraints: const BoxConstraints(maxWidth: 720),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF12161C),
            border: Border.all(color: gold.withOpacity(.22)),
          ),
          child: Row(
            children: [
              Icon(Icons.notifications_none, color: gold, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Aquí verás asignaciones nuevas y alertas.',
                  style: TextStyle(color: Colors.white.withOpacity(.72)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
