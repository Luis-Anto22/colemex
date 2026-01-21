import 'package:flutter/material.dart';

class UbicacionTiempoRealScreen extends StatefulWidget {
  const UbicacionTiempoRealScreen({super.key});

  @override
  State<UbicacionTiempoRealScreen> createState() => _UbicacionTiempoRealScreenState();
}

class _UbicacionTiempoRealScreenState extends State<UbicacionTiempoRealScreen> {
  bool compartir = false;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Ubicación en tiempo real')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.location_on_outlined, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text(
              'Compartir ubicación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'Activa la ubicación cuando estés disponible. Esto ayuda a clientes a encontrarte más rápido.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: compartir,
              onChanged: (v) => setState(() => compartir = v),
              title: const Text('Compartir ubicación'),
              subtitle: Text(compartir ? 'Activa' : 'Inactiva'),
              activeThumbColor: gold,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('🧩 Guardado pendiente. Estado: ${compartir ? "activa" : "inactiva"}')),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
