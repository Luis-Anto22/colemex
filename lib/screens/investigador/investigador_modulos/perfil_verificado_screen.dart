import 'package:flutter/material.dart';

class PerfilVerificadoScreen extends StatelessWidget {
  const PerfilVerificadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? gold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil profesional verificado'),
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
      ),
      body: _BaseModuleBody(
        title: 'Perfil profesional',
        subtitle: 'Aquí irá la verificación (foto, documentos, datos).',
        icon: Icons.verified_user_outlined,
        gold: gold,
      ),
    );
  }
}

class _BaseModuleBody extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color gold;

  const _BaseModuleBody({
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
          child: Image.asset(
            'assets/iconos/mazo-libro.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(child: Container(color: Colors.black.withOpacity(.62))),
        SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              constraints: const BoxConstraints(maxWidth: 720),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: gold.withOpacity(.22)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF12161C).withOpacity(.88),
                    const Color(0xFF181E26).withOpacity(.92),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.30),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: gold.withOpacity(.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: gold.withOpacity(.25)),
                    ),
                    child: Icon(icon, color: gold, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.72),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
