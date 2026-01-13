import 'package:flutter/material.dart';
import 'lista_abogados_screen.dart';
import 'estadisticas_general_screen.dart';

class PanelAdminHome extends StatelessWidget {
  const PanelAdminHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrador'),
        backgroundColor: Colors.indigo,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenido, admin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Acciones principales
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Acciones rápidas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.people),
                                label: const Text('Lista de abogados'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ListaAbogadosScreen(),
                                    ),
                                  );
                                  // Alternativa con rutas nombradas:
                                  // Navigator.pushNamed(context, '/lista-abogados');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.bar_chart),
                                label: const Text('Estadísticas generales'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EstadisticasGeneralScreen(),
                                    ),
                                  );
                                  // Alternativa con rutas nombradas:
                                  // Navigator.pushNamed(context, '/estadisticas-generales');
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sugerencia de módulos futuros (placeholder)
                Card(
                  elevation: 1,
                  color: Colors.indigo.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Próximamente: Notificaciones, gestión avanzada de tipos de abogados y filtros por fecha.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}