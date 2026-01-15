import 'package:flutter/material.dart';

class SolicitudesAvaluoScreen extends StatelessWidget {
  const SolicitudesAvaluoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? gold;

    // 🔧 Dummy data (después lo conectamos a tu API)
    final solicitudes = [
      {'cliente': 'Juan Pérez', 'tipo': 'Casa habitación', 'zona': 'CDMX', 'estado': 'Pendiente'},
      {'cliente': 'María López', 'tipo': 'Terreno', 'zona': 'Edo. Méx', 'estado': 'Pendiente'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de avalúo'),
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
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: solicitudes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final s = solicitudes[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12161C).withOpacity(.88),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: gold.withOpacity(.22)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['cliente']!,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${s['tipo']} • ${s['zona']}',
                        style: TextStyle(color: Colors.white.withOpacity(.75)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('❌ Rechazado (demo)'), backgroundColor: headerBg),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: gold.withOpacity(.65)),
                              ),
                              child: const Text('Rechazar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('✅ Aceptado (demo)'), backgroundColor: headerBg),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gold,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Aceptar'),
                            ),
                          ),
                        ],
                      ),
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
