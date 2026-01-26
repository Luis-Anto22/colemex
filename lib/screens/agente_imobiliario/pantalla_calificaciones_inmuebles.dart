import 'package:flutter/material.dart';
import 'package:colemex/widgets_global/calificaciones_widget.dart';

class PantallaCalificacionesInmuebles extends StatelessWidget {
  final int agenteId; // 👈 ID del agente inmobiliario

  const PantallaCalificacionesInmuebles({super.key, required this.agenteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calificaciones"),
        backgroundColor: const Color(0xFFD4AF37), // Dorado institucional
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CalificacionesWidget(profesionalId: agenteId), // ✅ igual que Ingresos
      ),
    );
  }
}