import 'package:flutter/material.dart';
import 'package:colemex/widgets_global/contacto_soporte_widget.dart';

class PantallaContactoSoporte extends StatelessWidget {
  const PantallaContactoSoporte({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacto / Soporte"),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: ContactoSoporteWidget(),
      ),
    );
  }
}