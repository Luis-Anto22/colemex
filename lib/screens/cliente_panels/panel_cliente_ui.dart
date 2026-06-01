import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services/api_client.dart';
import 'calificar_profesional_screen.dart';
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

  final ApiClient _api = ApiClient();

  int _currentIndex = 0;
  String? _servicioSeleccionado;
  String _especialidadBusqueda = '';
  bool _popupCalificacionMostrado = false;

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarCalificacionesPendientes();
    });
  }

  Map<String, dynamic> _parseData(dynamic raw) {
    try {
      if (raw is String && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      }

      if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      }
    } catch (_) {}

    return {};
  }

  Future<bool> _yaCalificoProfesional({
    required int clienteId,
    required int profesionalId,
  }) async {
    try {
      final res = await _api.get(
        '/common/calificaciones',
        params: {
          'profesional_id': profesionalId,
        },
      );

      if (res['success'] != true) return false;

      final data = res['data'];
      if (data is! Map) return false;

      final items = data['items'];
      if (items is! List) return false;

      return items.any((item) {
        if (item is! Map) return false;
        final itemClienteId = int.tryParse('${item['cliente_id']}') ?? 0;
        return itemClienteId == clienteId;
      });
    } catch (_) {
      return false;
    }
  }

  Future<void> _verificarCalificacionesPendientes() async {
    if (_popupCalificacionMostrado) return;

    final prefs = await SharedPreferences.getInstance();
    final clienteId = prefs.getInt('id') ?? 0;

    if (clienteId <= 0) return;

    try {
      final res = await _api.get(
        '/notificaciones',
        params: {
          'cliente_id': clienteId,
          'solo_no_leidas': 1,
        },
      );

      if (res['success'] != true) return;

      final data = res['data'];
      if (data is! List || data.isEmpty) return;

      Map<String, dynamic>? notificacionSeleccionada;
      int profesionalIdSeleccionado = 0;
      int casoIdSeleccionado = 0;
      int notificacionIdSeleccionada = 0;

      for (final item in data) {
        if (item is! Map) continue;

        final map = Map<String, dynamic>.from(item);

        final tipo = (map['tipo'] ?? '').toString();
        final leido = int.tryParse('${map['leido'] ?? 0}') ?? 0;

        if (tipo != 'caso_finalizado_calificacion') continue;
        if (leido == 1) continue;

        final extra = _parseData(map['data']);

        final profesionalId =
            int.tryParse('${extra['profesional_id'] ?? ''}') ?? 0;
        final casoId = int.tryParse('${extra['caso_id'] ?? ''}') ?? 0;
        final notificacionId = int.tryParse('${map['id'] ?? ''}') ?? 0;

        if (profesionalId <= 0) continue;

        final yaCalifico = await _yaCalificoProfesional(
          clienteId: clienteId,
          profesionalId: profesionalId,
        );

        if (yaCalifico) continue;

        notificacionSeleccionada = map;
        profesionalIdSeleccionado = profesionalId;
        casoIdSeleccionado = casoId;
        notificacionIdSeleccionada = notificacionId;
        break;
      }

      if (notificacionSeleccionada == null || !mounted) return;

      _popupCalificacionMostrado = true;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Color(0xFFF59E0B),
                ),
                SizedBox(width: 8),
                Text('Califica tu experiencia'),
              ],
            ),
            content: const Text(
              'Tu caso fue finalizado. Ayúdanos calificando al profesional que te atendió.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Después'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.star_rounded),
                label: const Text('Calificar'),
                onPressed: () async {
                  Navigator.pop(context);

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CalificarProfesionalScreen(
                        profesionalId: profesionalIdSeleccionado,
                        casoId: casoIdSeleccionado,
                        notificacionId: notificacionIdSeleccionada,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    } catch (_) {}
  }

  Future<void> _abrirNotificaciones() async {
    final prefs = await SharedPreferences.getInstance();
    final clienteId = prefs.getInt('id') ?? 0;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificacionesScreen(
          clienteId: clienteId > 0 ? clienteId : null,
        ),
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
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 30,
                ),
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
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}