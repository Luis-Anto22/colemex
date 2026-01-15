import 'package:flutter/material.dart';

class DictamenesReportesScreen extends StatelessWidget {
  const DictamenesReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? gold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictámenes / reportes'),
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
                      'Genera y sube tu dictamen',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Aquí conectaremos la subida de archivos (PDF/DOCX) al avalúo seleccionado.',
                      style: TextStyle(color: Colors.white.withOpacity(.75), height: 1.35),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('🧩 Pendiente de conectar'), backgroundColor: headerBg),
                        );
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Subir reporte'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
