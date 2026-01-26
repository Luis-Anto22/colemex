import 'package:flutter/material.dart';
import 'package:colemex/widgets_global/configuracion_widget.dart';

class PantallaConfiguracionInmuebles extends StatelessWidget {
  const PantallaConfiguracionInmuebles({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: ConfiguracionWidget(), // ✅ widget global
      ),
    );
  }
}