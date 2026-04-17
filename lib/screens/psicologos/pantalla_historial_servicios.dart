import 'package:flutter/material.dart';
import 'widgets/historial_servicios_widget.dart';

class PantallaHistorialServicios extends StatelessWidget {
  final int psicologoId;

  const PantallaHistorialServicios({super.key, required this.psicologoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Servicios"),
        backgroundColor: const Color(0xFFD4AF37), // Dorado institucional
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: HistorialServiciosWidget(psicologoId: psicologoId),
      ),
    );
  }
}