import 'package:flutter/material.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? gold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de servicios'),
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
      ),
      body: _Simple(title: 'Historial', subtitle: 'Aquí verás servicios finalizados.', icon: Icons.history, gold: gold),
    );
  }
}

class _Simple extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color gold;

  const _Simple({required this.title, required this.subtitle, required this.icon, required this.gold});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF12161C),
            border: Border.all(color: gold.withOpacity(.22)),
          ),
          child: Row(
            children: [
              Icon(icon, color: gold, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(.72))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
