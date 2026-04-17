import 'package:flutter/material.dart';
import 'widgets/historial_inmuebles_widget.dart';

class PantallaHistorialInmuebles extends StatelessWidget {
  final int agenteId;

  const PantallaHistorialInmuebles({super.key, required this.agenteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Operaciones"),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: HistorialInmueblesWidget(agenteId: agenteId), // ✅ widget nuevo
      ),
    );
  }
}