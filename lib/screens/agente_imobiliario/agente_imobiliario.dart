import 'package:flutter/material.dart';

import '../localizacion.dart';
import '../universal_menu.dart';
import 'pantalla_agenda_inmuebles.dart';
import 'pantalla_calificaciones_inmuebles.dart';
import 'pantalla_configuracion_inmuebles.dart';
import 'pantalla_contacto_soporte_inmuebles.dart';
import 'pantalla_historial_inmuebles.dart';
import 'pantalla_ingresos_inmuebles.dart';
import 'pantalla_notificaciones_inmuebles.dart';
import 'pantalla_propiedades.dart';
import '../../widgets/notification_badge_icon.dart';

class PanelAgentesInmobiliarios extends StatefulWidget {
  final int agenteId;

  const PanelAgentesInmobiliarios({super.key, required this.agenteId});

  @override
  State<PanelAgentesInmobiliarios> createState() =>
      _PanelAgentesInmobiliariosState();
}

class _PanelAgentesInmobiliariosState extends State<PanelAgentesInmobiliarios> {
  // Paleta tomada de login_screen.dart para evaluar una linea visual unificada.
  static const Color _accent = Colors.amber;
  String estado = 'Disponible';

  bool get _idValido => widget.agenteId > 0;

  // Conexion principal del panel:
  // Aqui solo coordinamos navegacion. Cada pantalla destino contiene
  // su propia logica (widgets/API) para agenda, propiedades, historial, etc.
  void _go(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
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
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              letterSpacing: .2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: .7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: .06),
        border: Border.all(color: Colors.white54.withValues(alpha: .45)),
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
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: .05),
          border: Border.all(color: Colors.white54.withValues(alpha: .40)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _accent.withValues(alpha: .16),
                border: Border.all(color: _accent.withValues(alpha: .55)),
              ),
              child: Icon(icon, color: _accent),
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
                      color: Colors.white.withValues(alpha: .72),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: .6),
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
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: .05),
          border: Border.all(color: Colors.white54.withValues(alpha: .40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _accent),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _estadoChip(String label) {
    final active = estado == label;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: active ? Colors.black : Colors.white,
        ),
      ),
      selected: active,
      onSelected: (_) => setState(() => estado = label),
      selectedColor: _accent,
      backgroundColor: Colors.white.withValues(alpha: .06),
      shape: StadiumBorder(
        side: BorderSide(color: _accent.withValues(alpha: .48)),
      ),
    );
  }

  void _abrirHistorial() {
    if (!_idValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID de agente no valido')),
      );
      return;
    }
    _go(PantallaHistorialInmuebles(agenteId: widget.agenteId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerBg = Colors.black.withValues(alpha: .88);

    final shadow = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: .25),
        blurRadius: 22,
        offset: const Offset(0, 10),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
        title: const Text('Panel - Agente inmobiliario'),
        actions: [
          NotificationBadgeIcon(
            profesionalId: widget.agenteId,
            onPressed: () => _go(
              PantallaNotificacionesInmuebles(agenteId: widget.agenteId),
            ),
          ),
          IconButton(
            tooltip: 'Configuracion',
            onPressed: () => _go(const PantallaConfiguracionInmuebles()),
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
            child: Container(color: Colors.black.withValues(alpha: .65)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Theme(
                    data: theme.copyWith(
                      textTheme: theme.textTheme.apply(
                        bodyColor: Colors.white,
                        displayColor: Colors.white,
                      ),
                      iconTheme: theme.iconTheme.copyWith(color: Colors.white),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white54.withValues(alpha: .45),
                        ),
                        color: Colors.black.withValues(alpha: .74),
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
                                    color: _accent.withValues(alpha: .18),
                                    border: Border.all(
                                      color: _accent.withValues(alpha: .58),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.apartment_outlined,
                                    color: _accent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        'Propiedades - Agenda - Comisiones',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: .72),
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
                                      color: _accent.withValues(alpha: .52),
                                    ),
                                    color: Colors.white.withValues(alpha: .04),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.circle,
                                          size: 10, color: _accent),
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
                                'Define si estas disponible para nuevos clientes.',
                          ),
                          _card(
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _estadoChip('Disponible'),
                                _estadoChip('Ocupado'),
                                _estadoChip('Fuera de servicio'),
                              ],
                            ),
                          ),
                          _sectionHeader(
                            'Acciones rapidas',
                            subtitle:
                                'Distribuidas en grid responsivo para evitar botones amontonados.',
                          ),
                          _card(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final columns = constraints.maxWidth >= 760
                                    ? 4
                                    : (constraints.maxWidth >= 520 ? 3 : 2);
                                final spacing = 10.0;
                                final itemWidth = (constraints.maxWidth -
                                        ((columns - 1) * spacing)) /
                                    columns;

                                final actions = <Widget>[
                                  SizedBox(
                                    width: itemWidth,
                                    child: _quickAction(
                                      icon: Icons.event_available_outlined,
                                      label: 'Agenda',
                                      onTap: () =>
                                          _go(const PantallaAgendaInmuebles()),
                                    ),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _quickAction(
                                      icon: Icons.home_work_outlined,
                                      label: 'Propiedades',
                                      onTap: () => _go(
                                        PantallaPropiedades(
                                            agenteId: widget.agenteId),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _quickAction(
                                      icon: Icons.history_outlined,
                                      label: 'Historial',
                                      onTap: _abrirHistorial,
                                    ),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _quickAction(
                                      icon: Icons.attach_money_outlined,
                                      label: 'Ingresos',
                                      onTap: () => _go(
                                        PantallaIngresosInmuebles(
                                          profesionalId: widget.agenteId,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _quickAction(
                                      icon: Icons.star_outline_rounded,
                                      label: 'Calificaciones',
                                      onTap: () => _go(
                                        PantallaCalificacionesInmuebles(
                                          agenteId: widget.agenteId,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _quickAction(
                                      icon: Icons.notifications_none_outlined,
                                      label: 'Alertas',
                                      onTap: () => _go(
                                        PantallaNotificacionesInmuebles(
                                          agenteId: widget.agenteId,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _quickAction(
                                      icon: Icons.location_on_outlined,
                                      label: 'Ubicacion',
                                      // Conexion con localizacion.dart para guardar
                                      // coordenadas del agente inmobiliario.
                                      onTap: () => _go(
                                        LocalizacionPanel(
                                          idProfesional: widget.agenteId,
                                          perfil: 'Agentes inmobiliarios',
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _quickAction(
                                      icon: Icons.support_agent_outlined,
                                      label: 'Soporte',
                                      onTap: () => _go(
                                        const PantallaContactoSoporteInmuebles(),
                                      ),
                                    ),
                                  ),
                                ];

                                return Wrap(
                                  spacing: spacing,
                                  runSpacing: spacing,
                                  children: actions,
                                );
                              },
                            ),
                          ),
                          _sectionHeader(
                            'Modulos principales',
                            subtitle: 'Accesos completos por area de trabajo.',
                          ),
                          _tile(
                            icon: Icons.event_available_outlined,
                            title: 'Agenda / citas',
                            subtitle: 'Gestion de visitas y disponibilidad.',
                            onTap: () => _go(const PantallaAgendaInmuebles()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.home_work_outlined,
                            title: 'Propiedades listadas',
                            subtitle:
                                'Inventario, edicion y estatus de inmuebles.',
                            onTap: () => _go(
                              PantallaPropiedades(agenteId: widget.agenteId),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.history_outlined,
                            title: 'Historial de operaciones',
                            subtitle: _idValido
                                ? 'Cierres, rentas y ventas registradas.'
                                : 'Se requiere un ID valido para abrir el modulo.',
                            onTap: _abrirHistorial,
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.attach_money_outlined,
                            title: 'Ingresos y comisiones',
                            subtitle: 'Resumen financiero del agente.',
                            onTap: () => _go(
                              PantallaIngresosInmuebles(
                                profesionalId: widget.agenteId,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.star_outline_rounded,
                            title: 'Calificaciones',
                            subtitle: 'Valoraciones y comentarios de clientes.',
                            onTap: () => _go(
                              PantallaCalificacionesInmuebles(
                                agenteId: widget.agenteId,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.location_on_outlined,
                            title: 'Ubicacion profesional',
                            subtitle:
                                'Registra tu punto en el mapa para aparecer cercano.',
                            onTap: () => _go(
                              LocalizacionPanel(
                                idProfesional: widget.agenteId,
                                perfil: 'Agentes inmobiliarios',
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.notifications_none_outlined,
                            title: 'Notificaciones',
                            subtitle: 'Avisos de actividad y seguimiento.',
                            onTap: () => _go(
                              PantallaNotificacionesInmuebles(
                                agenteId: widget.agenteId,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.settings_outlined,
                            title: 'Configuracion',
                            subtitle: 'Preferencias y ajustes de cuenta.',
                            onTap: () =>
                                _go(const PantallaConfiguracionInmuebles()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.support_agent_outlined,
                            title: 'Contacto y soporte',
                            subtitle: 'Atencion tecnica y ayuda del sistema.',
                            onTap: () => _go(
                              const PantallaContactoSoporteInmuebles(),
                            ),
                          ),
                        ],
                      ),
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
