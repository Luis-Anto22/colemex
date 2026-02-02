import 'package:flutter/material.dart';
import '../widgets/botones_emergencia.dart';

class PanelSOS extends StatelessWidget {
  const PanelSOS({super.key});

  @override
  Widget build(BuildContext context) {
    return BotonesEmergencia(
      onBuscar: (tipo) {
        // Aquí defines qué hacer según el tipo de emergencia
        if (tipo == 'civil') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🚗 Emergencia Civil activada')),
          );
        } else if (tipo == 'penal') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚖️ Emergencia Penal activada')),
          );
        }
      },
    );
  }
}