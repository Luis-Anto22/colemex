import 'package:flutter/material.dart';
import 'package:colemex/widgets_global/agenda_widget.dart';

class PantallaAgendaInmuebles extends StatelessWidget {
  const PantallaAgendaInmuebles({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agenda / Citas"),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: AgendaWidget(), // ✅ widget global
      ),
    );
  }
}