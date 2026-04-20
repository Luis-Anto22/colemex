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

  const PanelAgentesInmobiliarios({
    super.key,
    required this.agenteId,
  });

  @override
  State<PanelAgentesInmobiliarios> createState() =>
      _PanelAgentesInmobiliariosState();
}

class _PanelAgentesInmobiliariosState extends State<PanelAgentesInmobiliarios> {
  static const Color _accent = Colors.amber;
  String estado = 'Disponible';

  bool get _idValido => widget.agenteId > 0;

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
    return Expanded(
      child: InkWell(
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
        const SnackBar(content: Text('ID de agente no válido')),
      );
      return;
    }
    _go(PantallaHistorialInmuebles(agenteId: widget.agenteId));
  }

  @override
  Widget build(BuildContext context) {
    final headerBg = Colors.black.withValues(alpha: .88);

    final shadow = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: .25),
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
            onPressed: () => _go(
              PantallaNotificacionesInmuebles(agenteId: widget.agenteId),
            ),
          ),
          IconButton(
            tooltip: 'Configuración',
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
            child: Container(color: Colors.black.withValues(alpha: .62)),
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
                      border: Border.all(
                        color: Colors.white54.withValues(alpha: .35),
                      ),
                      color: const Color(0xFF12161C).withValues(alpha: .82),
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
                                  color: _accent.withValues(alpha: .16),
                                  border: Border.all(
                                    color: _accent.withValues(alpha: .55),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.apartment_rounded,
                                  color: _accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Portal profesional',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Propiedades • Agenda • Historial',
                                      style: TextStyle(
                                        color: Colors.white70,
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
                                    color: _accent.withValues(alpha: .48),
                                  ),
                                  color: Colors.white.withValues(alpha: .04),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: _accent,
                                    ),
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
                              'Define tu disponibilidad para recibir nuevos clientes.',
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

                        _sectionHeader('Acciones rápidas'),
                        Row(
                          children: [
                            _quickAction(
                              icon: Icons.calendar_today,
                              label: 'Agenda',
                              onTap: () => _go(const PantallaAgendaInmuebles()),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.home,
                              label: 'Propiedades',
                              onTap: () => _go(
                                PantallaPropiedades(agenteId: widget.agenteId),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.history,
                              label: 'Historial',
                              onTap: _abrirHistorial,
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.location_on_outlined,
                              label: 'Ubicación',
                              onTap: () => _go(
                                LocalizacionPanel(
                                  idProfesional: widget.agenteId,
                                  perfil: 'Agentes inmobiliarios',
                                ),
                              ),
                            ),
                          ],
                        ),

                        _sectionHeader(
                          'Base común',
                          subtitle:
                              'Módulos obligatorios para todos los socios.',
                        ),
                        _tile(
                          icon: Icons.calendar_today,
                          title: 'Agenda',
                          subtitle: 'Organiza citas y recorridos.',
                          onTap: () => _go(const PantallaAgendaInmuebles()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.home,
                          title: 'Propiedades',
                          subtitle: 'Gestiona inmuebles y publicaciones.',
                          onTap: () => _go(
                            PantallaPropiedades(agenteId: widget.agenteId),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.history,
                          title: 'Historial',
                          subtitle: 'Seguimiento de cierres y operaciones.',
                          onTap: _abrirHistorial,
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.attach_money,
                          title: 'Ingresos',
                          subtitle: 'Consulta comisiones y pagos.',
                          onTap: () => _go(
                            PantallaIngresosInmuebles(
                              profesionalId: widget.agenteId,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.star,
                          title: 'Calificaciones',
                          subtitle: 'Opiniones y evaluación de clientes.',
                          onTap: () => _go(
                            PantallaCalificacionesInmuebles(
                              agenteId: widget.agenteId,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.notifications,
                          title: 'Notificaciones',
                          subtitle: 'Avisos y novedades del sistema.',
                          onTap: () => _go(
                            PantallaNotificacionesInmuebles(
                              agenteId: widget.agenteId,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.settings,
                          title: 'Configuración',
                          subtitle: 'Cuenta, privacidad y preferencias.',
                          onTap: () =>
                              _go(const PantallaConfiguracionInmuebles()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.support_agent,
                          title: 'Soporte',
                          subtitle: 'Ayuda y contacto con soporte.',
                          onTap: () =>
                              _go(const PantallaContactoSoporteInmuebles()),
                        ),

                        const SizedBox(height: 12),
                        Text(
                          'Tip: Mantén tus propiedades y ubicación actualizadas para recibir más oportunidades.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: .65),
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