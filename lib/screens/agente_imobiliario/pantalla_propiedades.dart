import 'package:flutter/material.dart';
import 'widgets/propiedades_widget.dart';

class PantallaPropiedades extends StatelessWidget {
  final int agenteId;

  const PantallaPropiedades({super.key, required this.agenteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Propiedades Listadas"),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: PropiedadesWidget(agenteId: agenteId),
      ),
    );
  }
}