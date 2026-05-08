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
  String estado = 'Disponible';

  bool get _idValido => widget.agenteId > 0;

  void _go(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _moduloPendiente(String modulo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$modulo estará disponible cuando creemos su pantalla y API.',
        ),
      ),
    );
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
                color: Colors.white.withValues(alpha: 0.70),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    final theme = Theme.of(context);
    final accent = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
        ),
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
    final accent = theme.primaryColor;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: accent.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: accent.withValues(alpha: 0.10),
                border: Border.all(
                  color: accent.withValues(alpha: 0.18),
                ),
              ),
              child: Icon(icon, color: accent),
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
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.60),
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
    final accent = theme.primaryColor;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: accent.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: accent),
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
    final theme = Theme.of(context);
    final accent = theme.primaryColor;
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
      selectedColor: accent,
      backgroundColor: Colors.white.withValues(alpha: 0.06),
      shape: StadiumBorder(
        side: BorderSide(
          color: accent.withValues(alpha: 0.22),
        ),
      ),
    );
  }

  Widget _estadoActualBadge() {
    final theme = Theme.of(context);
    final accent = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent.withValues(alpha: 0.22),
        ),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: accent,
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

  Widget _gap() => const SizedBox(height: 10);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? Colors.black;
    final saludo = _saludoPorHora();

    final shadow = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
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
              PantallaNotificacionesInmuebles(
                agenteId: widget.agenteId,
              ),
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
            child: Container(
              color: Colors.black.withValues(alpha: 0.62),
            ),
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
                        color: accent.withValues(alpha: 0.18),
                      ),
                      color: const Color(0xFF12161C).withValues(alpha: 0.82),
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
                                  color: accent.withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: accent.withValues(alpha: 0.20),
                                  ),
                                ),
                                child: Icon(
                                  Icons.apartment_rounded,
                                  color: accent,
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
                                      'Propiedades • Clientes • Visitas • Seguimiento',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.72,
                                        ),
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _estadoActualBadge(),
                            ],
                          ),
                        ),

                        _sectionHeader(
                          'Estado profesional',
                          subtitle:
                              'Define tu disponibilidad para recibir nuevos clientes y recorridos.',
                        ),
                        _card(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _estadoChip('Disponible'),
                              _estadoChip('Ocupado'),
                              _estadoChip('En visita'),
                              _estadoChip('Fuera de servicio'),
                            ],
                          ),
                        ),

                        _sectionHeader('Acciones rápidas'),
                        Row(
                          children: [
                            _quickAction(
                              icon: Icons.home_work_outlined,
                              label: 'Propiedades',
                              onTap: () => _go(
                                PantallaPropiedades(
                                  agenteId: widget.agenteId,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.person_search_outlined,
                              label: 'Clientes',
                              onTap: () =>
                                  _moduloPendiente('Clientes interesados'),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.tour_outlined,
                              label: 'Visitas',
                              onTap: () => _moduloPendiente(
                                'Agenda de visitas',
                              ),
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
                              'Módulos generales disponibles para todos los portales.',
                        ),
                        _tile(
                          icon: Icons.location_on_outlined,
                          title: 'Ubicación',
                          subtitle:
                              'Comparte tu ubicación cuando estés disponible para atención.',
                          onTap: () => _go(
                            LocalizacionPanel(
                              idProfesional: widget.agenteId,
                              perfil: 'Agentes inmobiliarios',
                            ),
                          ),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.calendar_today,
                          title: 'Agenda',
                          subtitle: 'Organiza citas, llamadas y recorridos.',
                          onTap: () => _go(const PantallaAgendaInmuebles()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.history,
                          title: 'Historial',
                          subtitle:
                              'Consulta operaciones, servicios y actividades realizadas.',
                          onTap: _abrirHistorial,
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.attach_money,
                          title: 'Ingresos',
                          subtitle: 'Consulta comisiones, pagos y ganancias.',
                          onTap: () => _go(
                            PantallaIngresosInmuebles(
                              profesionalId: widget.agenteId,
                            ),
                          ),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.star_outline,
                          title: 'Calificaciones',
                          subtitle:
                              'Opiniones, reseñas y evaluación de clientes.',
                          onTap: () => _go(
                            PantallaCalificacionesInmuebles(
                              agenteId: widget.agenteId,
                            ),
                          ),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.notifications_none,
                          title: 'Notificaciones',
                          subtitle: 'Avisos de clientes, citas y sistema.',
                          onTap: () => _go(
                            PantallaNotificacionesInmuebles(
                              agenteId: widget.agenteId,
                            ),
                          ),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.settings_outlined,
                          title: 'Configuración',
                          subtitle: 'Cuenta, privacidad y preferencias.',
                          onTap: () =>
                              _go(const PantallaConfiguracionInmuebles()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.support_agent_outlined,
                          title: 'Soporte',
                          subtitle: 'Ayuda técnica y asistencia.',
                          onTap: () =>
                              _go(const PantallaContactoSoporteInmuebles()),
                        ),

                        _sectionHeader(
                          'Módulos del agente inmobiliario',
                          subtitle:
                              'Herramientas para propiedades, prospectos, visitas y documentación.',
                        ),
                        _tile(
                          icon: Icons.home_work_outlined,
                          title: 'Propiedades asignadas',
                          subtitle:
                              'Consulta inmuebles asignados, estado, precio y operación.',
                          onTap: () => _go(
                            PantallaPropiedades(
                              agenteId: widget.agenteId,
                            ),
                          ),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.add_home_work_outlined,
                          title: 'Registro de inmueble',
                          subtitle:
                              'Captura casas, departamentos, terrenos o locales.',
                          onTap: () => _go(
                            PantallaPropiedades(
                              agenteId: widget.agenteId,
                            ),
                          ),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.person_search_outlined,
                          title: 'Clientes interesados',
                          subtitle:
                              'Prospectos, mensajes, nivel de interés y contacto.',
                          onTap: () =>
                              _moduloPendiente('Clientes interesados'),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.tour_outlined,
                          title: 'Agenda de visitas',
                          subtitle:
                              'Programa recorridos presenciales o virtuales.',
                          onTap: () => _moduloPendiente('Agenda de visitas'),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.timeline_outlined,
                          title: 'Seguimiento de prospectos',
                          subtitle:
                              'Etapas, próximo paso, comentarios y cierre.',
                          onTap: () =>
                              _moduloPendiente('Seguimiento de prospectos'),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.folder_copy_outlined,
                          title: 'Documentación del inmueble',
                          subtitle:
                              'Predial, escritura, contrato, comprobantes y validación.',
                          onTap: () =>
                              _moduloPendiente('Documentación del inmueble'),
                        ),

                        const SizedBox(height: 12),
                        Text(
                          'Tip: Mantén actualizadas tus propiedades, prospectos y visitas para generar más oportunidades.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.65),
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