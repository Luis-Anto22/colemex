import 'package:flutter/material.dart';

// API NOTIFICACIONES
import 'package:advocatus/services/api_services/api_client.dart';
import 'package:advocatus/services/api_services/notificaciones_api.dart';

// COMMON
import 'package:advocatus/screens/common/agenda/agenda_screen.dart';
import 'package:advocatus/screens/common/calificaciones/calificaciones_screen.dart';
import 'package:advocatus/screens/common/configuracion/configuracion_screen.dart';
import 'package:advocatus/screens/common/historial/historial_screen.dart';
import 'package:advocatus/screens/common/ingresos/ingresos_screen.dart';
import 'package:advocatus/screens/common/notificaciones/notificaciones_screen.dart';
import 'package:advocatus/screens/common/perfil/perfil_verificado_screen.dart';
import 'package:advocatus/screens/common/soporte/soporte_screen.dart';
import 'package:advocatus/screens/common/ubicacion/ubicacion_tiempo_real_screen.dart';

// WIDGET COMÚN
import 'package:advocatus/screens/common/estado_profesional/estado_profesional_widget.dart';

// INVESTIGADOR
import 'investigador_modulos/bitacora_screen.dart';
import 'investigador_modulos/casos_asignados_screen.dart';
import 'investigador_modulos/evidencias_screen.dart';

class PanelInvestigadorScreen extends StatefulWidget {
  final int investigadorId;

  const PanelInvestigadorScreen({
    super.key,
    required this.investigadorId,
  });

  @override
  State<PanelInvestigadorScreen> createState() =>
      _PanelInvestigadorScreenState();
}

class _PanelInvestigadorScreenState extends State<PanelInvestigadorScreen> {
  final NotificacionesApi _notificacionesApi = NotificacionesApi(ApiClient());

  String estado = 'Disponible';
  int notificacionesPendientes = 0;
  bool _cargandoNotificaciones = false;

  @override
  void initState() {
    super.initState();
    _cargarContadorNotificaciones();
  }

  bool _esLeida(Map<String, dynamic> n) {
    final value = n['leido'] ?? n['leida'] ?? n['visto'] ?? n['vista'] ?? 0;
    final text = value.toString().toLowerCase().trim();

    return text == '1' || text == 'true' || text == 'si' || text == 'sí';
  }

  Future<void> _cargarContadorNotificaciones() async {
    if (_cargandoNotificaciones) return;

    setState(() {
      _cargandoNotificaciones = true;
    });

    try {
      final items = await _notificacionesApi.listar(
        profesionalId: widget.investigadorId,
        clienteId: null,
        limit: 80,
      );

      int pendientes = 0;

      for (final item in items) {
        if (!_esLeida(item)) {
          pendientes++;
        }
      }

      if (!mounted) return;

      setState(() {
        notificacionesPendientes = pendientes;
        _cargandoNotificaciones = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        notificacionesPendientes = 0;
        _cargandoNotificaciones = false;
      });
    }
  }

  Future<void> _go(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    if (!mounted) return;

    await _cargarContadorNotificaciones();
  }

  Future<void> _abrirNotificaciones() async {
    await _go(
      NotificacionesScreen(
        profesionalId: widget.investigadorId,
      ),
    );
  }

  Widget _campanitaNotificaciones() {
    final hayPendientes = notificacionesPendientes > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          hayPendientes
              ? Icons.notifications_active
              : Icons.notifications_none,
          // ✅ Siempre blanca para que no se pierda en la barra dorada
          color: Colors.white,
        ),
        if (hayPendientes)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                notificacionesPendientes > 99
                    ? '99+'
                    : '$notificacionesPendientes',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _sectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              letterSpacing: .2,
              color: Colors.white,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withOpacity(.70),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(.06),
        border: Border.all(color: gold.withOpacity(.18)),
      ),
      child: child,
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final tieneBadge = badge > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color:
              tieneBadge ? gold.withOpacity(.08) : Colors.white.withOpacity(.05),
          border: Border.all(
            color: tieneBadge ? gold.withOpacity(.32) : gold.withOpacity(.14),
          ),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: gold.withOpacity(.10),
                    border: Border.all(color: gold.withOpacity(.18)),
                  ),
                  child: Icon(icon, color: gold),
                ),
                if (tieneBadge)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.2,
                      color: Colors.white.withOpacity(.72),
                    ),
                  ),
                ],
              ),
            ),
            if (tieneBadge)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.redAccent.withOpacity(.28),
                  ),
                ),
                child: Text(
                  '$badge nueva${badge == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(.60),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final tieneBadge = badge > 0;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color:
                tieneBadge ? gold.withOpacity(.08) : Colors.white.withOpacity(.05),
            border: Border.all(
              color: tieneBadge ? gold.withOpacity(.30) : gold.withOpacity(.14),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: gold),
                  if (tieneBadge)
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          badge > 99 ? '99+' : '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contadorMiniCard(Color gold) {
    final hayPendientes = notificacionesPendientes > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _abrirNotificaciones,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: hayPendientes
              ? Colors.redAccent.withOpacity(.12)
              : Colors.white.withOpacity(.04),
          border: Border.all(
            color: hayPendientes
                ? Colors.redAccent.withOpacity(.32)
                : gold.withOpacity(.18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hayPendientes
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: hayPendientes ? Colors.redAccent : gold,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              hayPendientes
                  ? '$notificacionesPendientes pendiente${notificacionesPendientes == 1 ? '' : 's'}'
                  : 'Sin pendientes',
              style: TextStyle(
                color: hayPendientes ? Colors.redAccent : Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? theme.primaryColor;

    final shadow = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withOpacity(.25),
        blurRadius: 22,
        offset: const Offset(0, 10),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
        title: const Text('Panel • Investigador'),
        actions: [
          IconButton(
            tooltip: notificacionesPendientes > 0
                ? 'Tienes $notificacionesPendientes notificación(es) pendiente(s)'
                : 'Notificaciones',
            onPressed: _abrirNotificaciones,
            icon: _campanitaNotificaciones(),
          ),
          IconButton(
            tooltip: 'Configuración',
            onPressed: () => _go(const ConfiguracionScreen()),
            icon: const Icon(Icons.settings_outlined),
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
            child: Container(color: Colors.black.withOpacity(.62)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: gold.withOpacity(.18)),
                      color: const Color(0xFF12161C).withOpacity(.82),
                      boxShadow: shadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _card(
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: gold.withOpacity(.12),
                                  border: Border.all(
                                    color: gold.withOpacity(.20),
                                  ),
                                ),
                                child: Icon(
                                  Icons.search_outlined,
                                  color: gold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Portal profesional',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Investigación • Evidencias • Bitácora',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.72),
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              _contadorMiniCard(gold),
                            ],
                          ),
                        ),

                        _sectionHeader(
                          'Estado profesional',
                          subtitle:
                              'Define tu disponibilidad para recibir asignaciones.',
                        ),
                        _card(
                          child: EstadoProfesionalWidget(
                            estadoActual: estado,
                            color: gold,
                            onChanged: (nuevoEstado) =>
                                setState(() => estado = nuevoEstado),
                          ),
                        ),

                        _sectionHeader('Acciones rápidas'),
                        Row(
                          children: [
                            _quickAction(
                              icon: Icons.assignment_outlined,
                              label: 'Casos',
                              onTap: () => _go(
                                CasosAsignadosScreen(
                                  investigadorId: widget.investigadorId,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.notifications_none,
                              label: 'Avisos',
                              badge: notificacionesPendientes,
                              onTap: _abrirNotificaciones,
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.camera_alt_outlined,
                              label: 'Evidencias',
                              onTap: () => _go(
                                EvidenciasScreen(
                                  investigadorId: widget.investigadorId,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.support_agent_outlined,
                              label: 'Soporte',
                              onTap: () => _go(const SoporteScreen()),
                            ),
                          ],
                        ),

                        _sectionHeader(
                          'Base común',
                          subtitle:
                              'Módulos obligatorios para todos los socios.',
                        ),
                        _tile(
                          icon: Icons.verified_user_outlined,
                          title: 'Perfil profesional verificado',
                          subtitle: 'Datos, foto, documentos y verificación.',
                          onTap: () => _go(const PerfilVerificadoScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.location_on_outlined,
                          title: 'Ubicación en tiempo real',
                          subtitle: 'Comparte ubicación cuando estés activo.',
                          onTap: () => _go(const UbicacionTiempoRealScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.event_available_outlined,
                          title: 'Agenda / citas',
                          subtitle: 'Disponibilidad, horarios y visitas.',
                          onTap: () => _go(const AgendaScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.history,
                          title: 'Historial de servicios',
                          subtitle: 'Registros y cierres de investigaciones.',
                          onTap: () => _go(const HistorialScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.attach_money,
                          title: 'Ingresos / comisiones',
                          subtitle: 'Resumen, pagos y facturación.',
                          onTap: () => _go(const IngresosScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.star_outline,
                          title: 'Calificaciones',
                          subtitle: 'Promedio y comentarios.',
                          onTap: () => _go(const CalificacionesScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: notificacionesPendientes > 0
                              ? Icons.notifications_active
                              : Icons.notifications_none,
                          title: notificacionesPendientes > 0
                              ? 'Notificaciones ($notificacionesPendientes)'
                              : 'Notificaciones',
                          subtitle: notificacionesPendientes > 0
                              ? 'Tienes $notificacionesPendientes alerta${notificacionesPendientes == 1 ? '' : 's'} o asignación${notificacionesPendientes == 1 ? '' : 'es'} pendiente${notificacionesPendientes == 1 ? '' : 's'}.'
                              : 'Nuevas asignaciones y alertas.',
                          badge: notificacionesPendientes,
                          onTap: _abrirNotificaciones,
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.settings_outlined,
                          title: 'Configuración',
                          subtitle: 'Cuenta, privacidad y preferencias.',
                          onTap: () => _go(const ConfiguracionScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.support_agent_outlined,
                          title: 'Soporte técnico',
                          subtitle: 'Ayuda técnica y soporte.',
                          onTap: () => _go(const SoporteScreen()),
                        ),

                        _sectionHeader(
                          'Módulos del investigador',
                          subtitle:
                              'Herramientas específicas para tu profesión.',
                        ),
                        _tile(
                          icon: Icons.assignment_outlined,
                          title: 'Casos asignados',
                          subtitle: 'Ver, aceptar y gestionar casos.',
                          onTap: () => _go(
                            CasosAsignadosScreen(
                              investigadorId: widget.investigadorId,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.notes_outlined,
                          title: 'Bitácora / seguimiento',
                          subtitle: 'Notas, avances y estatus del caso.',
                          onTap: () => _go(
                            BitacoraScreen(
                              investigadorId: widget.investigadorId,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.camera_alt_outlined,
                          title: 'Evidencias (fotos / archivos)',
                          subtitle: 'Subir y organizar evidencias.',
                          onTap: () => _go(
                            EvidenciasScreen(
                              investigadorId: widget.investigadorId,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        Text(
                          'Tip: Mantén tu estado y ubicación actualizados para recibir más asignaciones.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(.65),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}