import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'panel_inicio.dart';
import 'panel_servicios.dart';
import 'panel_sos.dart';
import 'perfil_cliente_screen.dart';
import 'package:advocatus/screens/common/notificaciones/notificaciones_screen.dart';

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

  void _abrirNotificaciones() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificacionesScreen(),
      ),
    );
  }

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

  Future<void> _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  String get _tituloActual {
    switch (_currentIndex) {
      case 0:
        return 'Servicios';
      case 1:
        return 'Casos';
      case 2:
        return 'SOS';
      case 3:
        return 'Ajustes';
      default:
        return 'Cliente';
    }
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
      PanelAjustesCliente(
        nombreUsuario: widget.nombreUsuario,
        onCerrarSesion: _cerrarSesion,
        onAbrirNotificaciones: _abrirNotificaciones,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        title: Text(_tituloActual),
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            icon: const Icon(Icons.notifications_rounded),
            onPressed: _abrirNotificaciones,
          ),
        ],
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
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
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
              icon: Icon(Icons.folder_copy_rounded),
              label: 'Casos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_rounded),
              label: 'SOS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}

class PanelAjustesCliente extends StatelessWidget {
  final String nombreUsuario;
  final VoidCallback onCerrarSesion;
  final VoidCallback onAbrirNotificaciones;

  const PanelAjustesCliente({
    super.key,
    required this.nombreUsuario,
    required this.onCerrarSesion,
    required this.onAbrirNotificaciones,
  });

  static const Color _primaryColor = Color(0xFF0B2545);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD6E1EF)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: _primaryColor,
                child: Icon(Icons.person_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreUsuario,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Cliente',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _AjusteTile(
          icon: Icons.person_outline_rounded,
          title: 'Mi perfil',
          subtitle: 'Ver o editar tus datos',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PerfilClienteScreen(),
              ),
            );
          },
        ),
        _AjusteTile(
          icon: Icons.notifications_none_rounded,
          title: 'Notificaciones',
          subtitle: 'Ver tus avisos recientes',
          onTap: onAbrirNotificaciones,
        ),
        _AjusteTile(
          icon: Icons.history_rounded,
          title: 'Historial',
          subtitle: 'Ver servicios y solicitudes anteriores',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Historial próximamente')),
            );
          },
        ),
        const SizedBox(height: 12),
        _AjusteTile(
          icon: Icons.logout_rounded,
          title: 'Cerrar sesión',
          subtitle: 'Salir de tu cuenta',
          danger: true,
          onTap: onCerrarSesion,
        ),
      ],
    );
  }
}

class _AjusteTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _AjusteTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFDC2626) : const Color(0xFF0B2545);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E1EF)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w800, color: color),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}