import 'package:flutter/material.dart';
import 'panel_inicio.dart';
import 'panel_servicios.dart';
import 'panel_mis_casos.dart';
import 'panel_sos.dart';

class PanelClienteUI extends StatefulWidget {
  final String nombreUsuario;
  final List<Map<String, dynamic>> listaCasos;

  const PanelClienteUI({
    Key? key,
    required this.nombreUsuario,
    required this.listaCasos,
  }) : super(key: key);

  @override
  State<PanelClienteUI> createState() => _PanelClienteUIState();
}

class _PanelClienteUIState extends State<PanelClienteUI> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final panels = [
      PanelInicio(nombreUsuario: widget.nombreUsuario),
      const PanelServicios(),
      PanelMisCasos(listaCasos: widget.listaCasos),
      const PanelSOS(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Bienvenido ${widget.nombreUsuario}')),
      body: IndexedStack(
        index: _currentIndex,
        children: panels,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.miscellaneous_services), label: 'Servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Mis Casos'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded, color: Colors.red), label: 'SOS'),
        ],
      ),
    );
  }
}