import 'package:flutter/material.dart';
import 'package:colemex/widgets_global/notificaciones_widget.dart';

class PantallaNotificacionesPsicologos extends StatelessWidget {
  final int psicologoId; // 👈 ID del psicólogo

  const PantallaNotificacionesPsicologos({super.key, required this.psicologoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones"),
        backgroundColor: const Color(0xFF6A1B9A), // 💜 color institucional psicólogos
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: NotificacionesWidget(profesionalId: psicologoId), // ✅ conectado al API
      ),
    );
  }
}