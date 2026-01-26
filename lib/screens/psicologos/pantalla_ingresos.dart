import 'package:flutter/material.dart';
import 'package:colemex/widgets_global/ingresos_widget.dart';

class PantallaIngresosPsicologos extends StatelessWidget {
  final int profesionalId; // 👈 ID del psicólogo

  const PantallaIngresosPsicologos({super.key, required this.profesionalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ingresos y Comisiones"),
        backgroundColor: const Color(0xFF6A1B9A), // 💜 color institucional para psicólogos
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: IngresosWidget(profesionalId: profesionalId), // ✅ conectado al API
      ),
    );
  }
}