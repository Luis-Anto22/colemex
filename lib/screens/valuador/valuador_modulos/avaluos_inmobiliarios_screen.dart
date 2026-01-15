import 'package:flutter/material.dart';

class AvaluosInmobiliariosScreen extends StatelessWidget {
  const AvaluosInmobiliariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? gold;

    final avaluos = [
      {'folio': 'AV-1001', 'tipo': 'Casa', 'estatus': 'En proceso'},
      {'folio': 'AV-1002', 'tipo': 'Terreno', 'estatus': 'Entregado'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avalúos inmobiliarios'),
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/iconos/mazo-libro.png', fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(.62))),
          SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: avaluos.length,
              itemBuilder: (_, i) {
                final a = avaluos[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12161C).withOpacity(.88),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: gold.withOpacity(.22)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.home_work_outlined, color: gold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a['folio']!,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${a['tipo']} • ${a['estatus']}',
                              style: TextStyle(color: Colors.white.withOpacity(.75)),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white.withOpacity(.55)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
