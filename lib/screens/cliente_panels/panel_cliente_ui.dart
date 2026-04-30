import 'package:flutter/material.dart';
import 'panel_inicio.dart';
import 'panel_servicios.dart';
import 'panel_sos.dart';

class PanelClienteUI extends StatefulWidget {
  final String nombreUsuario;

  const PanelClienteUI({
    super.key,
    required this.nombreUsuario,
  });

  @override
  State<PanelClienteUI> createState() => _PanelClienteUIState();
}

class _PanelClienteUIState extends State<PanelClienteUI> {
  static const Color _primaryColor = Color(0xFF0B2545);

  int _currentIndex = 0;
  String? _servicioSeleccionado;
  String _especialidadBusqueda = '';

  static const List<String> _serviciosDisponibles = [
    'Abogados',
    'Ajustadores',
    'Peritos en criminalistica',
    'Valuadores',
    'Investigadores',
    'Psicologos',
    'Agentes inmobiliarios',
    'Contadores',
    'Agentes crediticios',
    'Asistencia vial',
  ];

  void _cambiarServicio(String servicio) {
    final normalizado = servicio.trim();
    setState(() {
      _servicioSeleccionado = normalizado.isEmpty ? null : normalizado;
    });
  }

  void _buscarPorEspecialidad(String texto) {
    final valor = texto.trim();
    setState(() {
      _especialidadBusqueda = valor;
      if (valor.isNotEmpty) {
        _currentIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final panels = [
      PanelServicios(
        nombreUsuario: widget.nombreUsuario,
        serviciosDisponibles: _serviciosDisponibles,
        servicioSeleccionado: _servicioSeleccionado,
        especialidadBusqueda: _especialidadBusqueda,
        onSeleccionarServicio: _cambiarServicio,
      ),
      PanelInicio(
        nombreUsuario: widget.nombreUsuario,
        servicioSeleccionado: _servicioSeleccionado,
        serviciosDisponibles: _serviciosDisponibles,
        especialidadBusqueda: _especialidadBusqueda,
        onAbrirServicios: () {
          setState(() {
            _currentIndex = 0;
          });
        },
        onSeleccionarServicio: _cambiarServicio,
        onBuscarEspecialidad: _buscarPorEspecialidad,
      ),
      const PanelSOS(),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          _currentIndex == 0
              ? 'Servicios'
              : _currentIndex == 1
                  ? 'Casos'
                  : 'SOS',
        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/iconos/mazo-libro.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),

          IndexedStack(
            index: _currentIndex,
            children: panels,
          ),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white.withValues(alpha: 0.95),
          selectedItemColor: _primaryColor,
          unselectedItemColor: const Color(0xFF6B7280),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.miscellaneous_services_rounded),
              label: 'Servicios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Casos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_rounded),
              label: 'SOS',
            ),
          ],
        ),
      ),
    );
  }
}