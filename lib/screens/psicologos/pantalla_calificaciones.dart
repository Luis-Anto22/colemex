import 'package:flutter/material.dart';
import 'package:colemex/widgets_global/calificaciones_widget.dart';

class PantallaCalificacionesPsicologos extends StatelessWidget {
  final int psicologoId; // 👈 ID del psicólogo

  const PantallaCalificacionesPsicologos({super.key, required this.psicologoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calificaciones"),
        backgroundColor: const Color(0xFF6A1B9A), // 💜 color institucional psicólogos
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CalificacionesWidget(profesionalId: psicologoId), // ✅ conectado al API
      ),
    );
  }
}