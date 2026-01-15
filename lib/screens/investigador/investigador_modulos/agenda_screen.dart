import 'package:flutter/material.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? gold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda / Citas'),
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
      ),
      body: _SimpleModule(
        title: 'Agenda',
        subtitle: 'Aquí irán tus citas, horarios y disponibilidad.',
        icon: Icons.event_available_outlined,
        gold: gold,
      ),
    );
  }
}

class _SimpleModule extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color gold;

  const _SimpleModule({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/iconos/mazo-libro.png', fit: BoxFit.cover),
        ),
        Positioned.fill(child: Container(color: Colors.black.withOpacity(.62))),
        Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            constraints: const BoxConstraints(maxWidth: 720),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: gold.withOpacity(.22)),
              color: const Color(0xFF12161C).withOpacity(.88),
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
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(subtitle,
                          style: TextStyle(color: Colors.white.withOpacity(.72))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
