import 'package:flutter/material.dart';
import 'package:colemex/widgets_global/ingresos_widget.dart';

class PantallaIngresosInmuebles extends StatelessWidget {
  final int profesionalId; // 👈 ID del agente inmobiliario

  const PantallaIngresosInmuebles({super.key, required this.profesionalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ingresos y Comisiones"),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: IngresosWidget(profesionalId: profesionalId), // ✅ ahora sí conectado
      ),
    );
  }
}