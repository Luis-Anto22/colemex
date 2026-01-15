import 'package:flutter/material.dart';

class EvidenciaFotograficaScreen extends StatelessWidget {
  const EvidenciaFotograficaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? gold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencia fotográfica'),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF12161C).withOpacity(.88),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: gold.withOpacity(.22)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Fotos del inmueble',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Aquí conectaremos cámara/galería para subir evidencia ligada a un avalúo.',
                      style: TextStyle(color: Colors.white.withOpacity(.75), height: 1.35),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('📷 Cámara (pendiente)'), backgroundColor: headerBg),
                              );
                            },
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Cámara'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: gold.withOpacity(.65)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('🖼️ Galería (pendiente)'), backgroundColor: headerBg),
                              );
                            },
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Galería'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: gold,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
