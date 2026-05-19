import 'package:flutter/material.dart';

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

// WIDGETS
import 'package:advocatus/widgets/notification_badge_icon.dart';

// MENÚ UNIVERSAL
import 'package:advocatus/screens/universal_menu.dart';

// AGENTE INMOBILIARIO
import 'pantalla_propiedades.dart';
import 'clientes_interesados_screen.dart';

class PanelAgentesInmobiliarios extends StatefulWidget {
  final int agenteId;

  const PanelAgentesInmobiliarios({
    super.key,
    required this.agenteId,
  });

  @override
  State<PanelAgentesInmobiliarios> createState() =>
      _PanelAgentesInmobiliariosState();
}

class _PanelAgentesInmobiliariosState extends State<PanelAgentesInmobiliarios> {
  String estado = 'Disponible';

  void _go(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  String _saludoPorHora() {
    final hora = DateTime.now().hour;

    if (hora >= 5 && hora < 12) {
      return 'Buenos días';
    } else if (hora >= 12 && hora < 19) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
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
  }) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(.05),
          border: Border.all(color: gold.withOpacity(.14)),
        ),
        child: Row(
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
  }) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(.05),
            border: Border.all(color: gold.withOpacity(.14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: gold),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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

  Widget _gap() => const SizedBox(height: 10);

  void _abrirPropiedades() {
    _go(
      PantallaPropiedades(
        agenteId: widget.agenteId,
      ),
    );
  }

  void _abrirClientesInteresados() {
    _go(
      ClientesInteresadosScreen(
        agenteId: widget.agenteId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? theme.primaryColor;
    final saludo = _saludoPorHora();

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
        title: const Text('Panel • Agente Inmobiliario'),
        actions: [
          NotificationBadgeIcon(
            profesionalId: widget.agenteId,
            onPressed: () => _go(const NotificacionesScreen()),
          ),
          IconButton(
            tooltip: 'Configuración',
            onPressed: () => _go(const ConfiguracionScreen()),
            icon: const Icon(Icons.settings_outlined),
          ),
          UniversalMenu(
            onSelected: (value) {
              if (value == 'cerrar') {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
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
                                  Icons.apartment_rounded,
                                  color: gold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$saludo, portal inmobiliario',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Propiedades • Clientes interesados',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.72),
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: gold.withOpacity(.22),
                                  ),
                                  color: Colors.white.withOpacity(.04),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.circle, size: 10, color: gold),
                                    const SizedBox(width: 8),
                                    Text(
                                      estado,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        _sectionHeader(
                          'Estado profesional',
                          subtitle:
                              'Define tu disponibilidad para recibir clientes, recorridos y solicitudes.',
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
                              icon: Icons.home_work_outlined,
                              label: 'Propiedades',
                              onTap: _abrirPropiedades,
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.person_search_outlined,
                              label: 'Clientes',
                              onTap: _abrirClientesInteresados,
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.event_available_outlined,
                              label: 'Agenda',
                              onTap: () => _go(const AgendaScreen()),
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
                        _gap(),
                        _tile(
                          icon: Icons.location_on_outlined,
                          title: 'Ubicación en tiempo real',
                          subtitle: 'Comparte ubicación cuando estés activo.',
                          onTap: () => _go(const UbicacionTiempoRealScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.event_available_outlined,
                          title: 'Agenda / citas',
                          subtitle: 'Disponibilidad, horarios y visitas.',
                          onTap: () => _go(const AgendaScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.history,
                          title: 'Historial de servicios',
                          subtitle: 'Registros, cambios y operaciones.',
                          onTap: () => _go(const HistorialScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.attach_money,
                          title: 'Ingresos / comisiones',
                          subtitle: 'Resumen, pagos y facturación.',
                          onTap: () => _go(const IngresosScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.star_outline,
                          title: 'Calificaciones',
                          subtitle: 'Promedio y comentarios.',
                          onTap: () => _go(const CalificacionesScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.notifications_none,
                          title: 'Notificaciones',
                          subtitle: 'Nuevas asignaciones y alertas.',
                          onTap: () => _go(const NotificacionesScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.settings_outlined,
                          title: 'Configuración',
                          subtitle: 'Cuenta, privacidad y preferencias.',
                          onTap: () => _go(const ConfiguracionScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.support_agent_outlined,
                          title: 'Soporte técnico',
                          subtitle: 'Ayuda técnica y soporte.',
                          onTap: () => _go(const SoporteScreen()),
                        ),

                        _sectionHeader(
                          'Módulos del agente inmobiliario',
                          subtitle:
                              'Herramientas específicas para propiedades y clientes interesados.',
                        ),
                        _tile(
                          icon: Icons.home_work_outlined,
                          title: 'Propiedades asignadas',
                          subtitle:
                              'Consulta inmuebles asignados, estado, precio y operación.',
                          onTap: _abrirPropiedades,
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.person_search_outlined,
                          title: 'Clientes interesados',
                          subtitle:
                              'Prospectos, mensajes, nivel de interés y contacto.',
                          onTap: _abrirClientesInteresados,
                        ),

                        const SizedBox(height: 10),
                        Text(
                          'Tip: Mantén tu estado, ubicación y propiedades actualizadas para generar más oportunidades.',
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
