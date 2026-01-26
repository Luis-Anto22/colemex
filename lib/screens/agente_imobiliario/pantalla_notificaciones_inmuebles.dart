import 'package:flutter/material.dart';
import 'package:colemex/widgets_global/notificaciones_widget.dart';

class PantallaNotificacionesInmuebles extends StatelessWidget {
  final int agenteId; // 👈 ID del agente inmobiliario

  const PantallaNotificacionesInmuebles({super.key, required this.agenteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones"),
        backgroundColor: const Color(0xFFD4AF37), // Dorado institucional
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: NotificacionesWidget(profesionalId: agenteId), // ✅ conectado al API
      ),
    );
  }
}