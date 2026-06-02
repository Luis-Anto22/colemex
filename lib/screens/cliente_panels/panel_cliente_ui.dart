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
  static const Color _bg = Color(0xFF050B14);

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

      if (normalizado.isNotEmpty) {
        _currentIndex = 1;
      }
    });
  }

  void _buscarPorEspecialidad(String texto) {
    final valor = texto.trim();

    setState(() {
      _especialidadBusqueda = valor;

      if (valor.isNotEmpty) {
        _currentIndex = 1;
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

  void _irAInicio() {
    setState(() {
      _currentIndex = 0;
    });
  }

  void _irAServicios() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void _irASOS() {
    setState(() {
      _currentIndex = 2;
    });
  }

  void _irAMensajes() {
    setState(() {
      _currentIndex = 3;
    });
  }

  void _irAPerfil() {
    setState(() {
      _currentIndex = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final panels = [
      PanelInicio(
        nombreUsuario: widget.nombreUsuario,
        servicioSeleccionado: _servicioSeleccionado,
        serviciosDisponibles: _serviciosDisponibles,
        especialidadBusqueda: _especialidadBusqueda,
        onAbrirServicios: _irAServicios,
        onSeleccionarServicio: _cambiarServicio,
        onBuscarEspecialidad: _buscarPorEspecialidad,
      ),
      PanelServicios(
        nombreUsuario: widget.nombreUsuario,
        serviciosDisponibles: _serviciosDisponibles,
        servicioSeleccionado: _servicioSeleccionado,
        especialidadBusqueda: _especialidadBusqueda,
        onSeleccionarServicio: _cambiarServicio,
      ),
      const PanelSOS(),
      const _MensajesClientePlaceholder(),
      PanelAjustesCliente(
        nombreUsuario: widget.nombreUsuario,
        onCerrarSesion: _cerrarSesion,
        onAbrirNotificaciones: _abrirNotificaciones,
      ),
    ];

    return Scaffold(
      backgroundColor: _bg,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: panels,
      ),
      bottomNavigationBar: _PremiumBottomNav(
        currentIndex: _currentIndex,
        onInicio: _irAInicio,
        onServicios: _irAServicios,
        onSOS: _irASOS,
        onMensajes: _irAMensajes,
        onPerfil: _irAPerfil,
      ),
    );
  }
}

class _PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onInicio;
  final VoidCallback onServicios;
  final VoidCallback onSOS;
  final VoidCallback onMensajes;
  final VoidCallback onPerfil;

  const _PremiumBottomNav({
    required this.currentIndex,
    required this.onInicio,
    required this.onServicios,
    required this.onSOS,
    required this.onMensajes,
    required this.onPerfil,
  });

  static const Color _bar = Color(0xFF101A27);
  static const Color _red = Color(0xFFB8322D);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 98 + bottom,
      padding: EdgeInsets.fromLTRB(18, 8, 18, bottom > 0 ? bottom : 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 26,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: _bar.withValues(alpha: 0.98),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.055),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Inicio',
                      active: currentIndex == 0,
                      onTap: onInicio,
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.business_center_outlined,
                      label: 'Servicios',
                      active: currentIndex == 1,
                      onTap: onServicios,
                    ),
                  ),
                  const SizedBox(width: 86),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Mensajes',
                      active: currentIndex == 3,
                      onTap: onMensajes,
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Perfil',
                      active: currentIndex == 4,
                      onTap: onPerfil,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 22,
            child: InkWell(
              onTap: onSOS,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: _red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF7F1D1D).withValues(alpha: 0.55),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _red.withValues(alpha: 0.45),
                      blurRadius: 22,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.call_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.96),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  static const Color _gold = Color(0xFFD6A84F);
  static const Color _muted = Color(0xFF8290A3);

  @override
  Widget build(BuildContext context) {
    final color = active ? _gold : _muted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 27),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: active ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MensajesClientePlaceholder extends StatelessWidget {
  const _MensajesClientePlaceholder();

  static const Color _bg = Color(0xFF050B14);
  static const Color _card = Color(0xFF111B28);
  static const Color _gold = Color(0xFFD6A84F);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 120),
          children: [
            const Text(
              'Mensajes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aquí aparecerán tus conversaciones con profesionales.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.58),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.055),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: _gold,
                    size: 54,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Mensajes próximamente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cuando actives el chat, tus conversaciones se mostrarán aquí.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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

  static const Color _bg = Color(0xFF050B14);
  static const Color _card = Color(0xFF111B28);
  static const Color _gold = Color(0xFFD6A84F);
  static const Color _red = Color(0xFFEF4444);
  static const Color _green = Color(0xFF54C26B);
  static const Color _blue = Color(0xFF7CA9FF);
  static const Color _purple = Color(0xFF9B5CFF);

  String _primerNombre() {
    final nombre = nombreUsuario.trim();
    if (nombre.isEmpty) return 'Cliente';
    return nombre.split(' ').first;
  }

  void _proximamente(BuildContext context, String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$texto próximamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 380;

    return Container(
      color: _bg,
      child: Stack(
        children: [
          Positioned(
            top: -90,
            left: -80,
            right: -80,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.95,
                  colors: [
                    const Color(0xFF233653).withValues(alpha: 0.86),
                    const Color(0xFF0B1420).withValues(alpha: 0.74),
                    _bg.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 175,
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/iconos/mazo-libro.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 128),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Perfil',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 31,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Administra tu cuenta y preferencias.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _card,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                      child: Icon(
                        Icons.settings_rounded,
                        color: Colors.white.withValues(alpha: 0.82),
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _ProfileHeroCard(
                  nombreUsuario: nombreUsuario,
                  primerNombre: _primerNombre(),
                  compact: compact,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ProfileStatCard(
                        icon: Icons.verified_user_rounded,
                        title: 'Cuenta',
                        value: 'Activa',
                        color: _green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ProfileStatCard(
                        icon: Icons.notifications_active_rounded,
                        title: 'Avisos',
                        value: 'Al día',
                        color: _gold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ProfileStatCard(
                        icon: Icons.security_rounded,
                        title: 'Seguridad',
                        value: 'OK',
                        color: _blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const _ProfileSectionTitle(title: 'Accesos principales'),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: compact ? 1.55 : 1.86,
                  children: [
                    _ProfileActionCard(
                      icon: Icons.person_rounded,
                      title: 'Mi perfil',
                      subtitle: 'Datos personales',
                      color: _gold,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PerfilClienteScreen(),
                          ),
                        );
                      },
                    ),
                    _ProfileActionCard(
                      icon: Icons.notifications_rounded,
                      title: 'Notificaciones',
                      subtitle: 'Avisos recientes',
                      color: _blue,
                      onTap: onAbrirNotificaciones,
                    ),
                    _ProfileActionCard(
                      icon: Icons.receipt_long_rounded,
                      title: 'Historial',
                      subtitle: 'Servicios anteriores',
                      color: _purple,
                      onTap: () => _proximamente(context, 'Historial'),
                    ),
                    _ProfileActionCard(
                      icon: Icons.credit_card_rounded,
                      title: 'Pagos',
                      subtitle: 'Suscripciones',
                      color: _green,
                      onTap: () => _proximamente(context, 'Pagos'),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const _ProfileSectionTitle(title: 'Configuración'),
                const SizedBox(height: 12),
                _AjusteTile(
                  icon: Icons.folder_copy_rounded,
                  title: 'Mis documentos',
                  subtitle: 'Identificación, contratos y archivos guardados',
                  color: _blue,
                  onTap: () => _proximamente(context, 'Mis documentos'),
                ),
                _AjusteTile(
                  icon: Icons.lock_rounded,
                  title: 'Seguridad de la cuenta',
                  subtitle: 'Contraseña, biometría y acceso seguro',
                  color: _green,
                  onTap: () => _proximamente(context, 'Seguridad'),
                ),
                _AjusteTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Ayuda y soporte',
                  subtitle: 'Resolver dudas o contactar soporte',
                  color: _gold,
                  onTap: () => _proximamente(context, 'Ayuda y soporte'),
                ),
                const SizedBox(height: 10),
                _LogoutCard(
                  onTap: onCerrarSesion,
                  color: _red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final String nombreUsuario;
  final String primerNombre;
  final bool compact;

  const _ProfileHeroCard({
    required this.nombreUsuario,
    required this.primerNombre,
    required this.compact,
  });

  static const Color _gold = Color(0xFFD6A84F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.075)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172437), Color(0xFF0D1623)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 70 : 78,
            height: compact ? 70 : 78,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _gold.withValues(alpha: 0.95),
                  const Color(0xFF7C5B22),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                color: const Color(0xFF0B111B),
                child: Image.asset(
                  'assets/iconos/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 40,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $primerNombre',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.64),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  nombreUsuario.trim().isEmpty ? 'Cliente' : nombreUsuario,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 18 : 20,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _MiniChip(
                      icon: Icons.person_pin_rounded,
                      label: 'Cliente AppBogator',
                      color: _gold,
                    ),
                    const _MiniChip(
                      icon: Icons.check_circle_rounded,
                      label: 'Cuenta activa',
                      color: Color(0xFF54C26B),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _ProfileStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF111B28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 23),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  final String title;

  const _ProfileSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ProfileActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ProfileActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF111B28),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.50),
                        fontSize: 11.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AjusteTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  const _AjusteTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF111B28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.055),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.52),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.white.withValues(alpha: 0.42),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;

  const _LogoutCard({
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.logout_rounded, color: color, size: 23),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Salir de tu cuenta de forma segura',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: color.withValues(alpha: 0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
