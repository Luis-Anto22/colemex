import 'package:flutter/material.dart';

// COMMON SCREENS
import 'package:advocatus/screens/common/agenda/agenda_screen.dart';
import 'package:advocatus/screens/common/calificaciones/calificaciones_screen.dart';
import 'package:advocatus/screens/common/configuracion/configuracion_screen.dart';
import 'package:advocatus/screens/common/historial/historial_screen.dart';
import 'package:advocatus/screens/common/ingresos/ingresos_screen.dart';
import 'package:advocatus/screens/common/notificaciones/notificaciones_screen.dart';
import 'package:advocatus/screens/common/soporte/soporte_screen.dart';
import 'package:advocatus/screens/common/perfil/perfil_verificado_screen.dart';
import 'package:advocatus/widgets/notification_badge_icon.dart';

// UBICACIÓN
import '../localizacion.dart';

// AJUSTADOR MÓDULOS
import 'package:advocatus/screens/ajustadores/ajustador_modulos/siniestros_asignados_screen.dart';
import 'package:advocatus/screens/ajustadores/ajustador_modulos/inspeccion_sitio_screen.dart';
import 'package:advocatus/screens/ajustadores/ajustador_modulos/datos_poliza_screen.dart';
import 'package:advocatus/screens/ajustadores/ajustador_modulos/terceros_involucrados_screen.dart';
import 'package:advocatus/screens/ajustadores/ajustador_modulos/danos_reportados_screen.dart';
import 'package:advocatus/screens/ajustadores/ajustador_modulos/dictamen_preliminar_screen.dart';
import 'package:advocatus/screens/ajustadores/ajustador_modulos/seguimiento_siniestro_screen.dart';
import 'package:advocatus/screens/ajustadores/ajustador_modulos/bitacora_ajustador_screen.dart';

class PanelAjustadorScreen extends StatefulWidget {
  final int ajustadorId;

  const PanelAjustadorScreen({
    super.key,
    required this.ajustadorId,
  });

  @override
  State<PanelAjustadorScreen> createState() => _PanelAjustadorScreenState();
}

class _PanelAjustadorScreenState extends State<PanelAjustadorScreen> {
  String estado = 'Disponible';

  void _go(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
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
    final gold = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: gold.withValues(alpha: 0.18)),
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
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: gold.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: gold.withValues(alpha: 0.10),
                border: Border.all(color: gold.withValues(alpha: 0.18)),
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
    final gold = theme.primaryColor;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: gold.withValues(alpha: 0.14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: gold),
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

  Widget _estadoChip(String label) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
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
      selectedColor: gold,
      backgroundColor: Colors.white.withValues(alpha: 0.06),
      shape: StadiumBorder(
        side: BorderSide(color: gold.withValues(alpha: 0.22)),
      ),
    );
  }

  Widget _estadoActualBadge() {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: gold.withValues(alpha: 0.22),
        ),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: gold,
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

  Widget _gap() => const SizedBox(height: 10);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? theme.primaryColor;
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
        title: const Text('Panel • Ajustador'),
        actions: [
          NotificationBadgeIcon(
            profesionalId: widget.ajustadorId,
            onPressed: () => _go(
              NotificacionesScreen(
                profesionalId: widget.ajustadorId,
              ),
            ),
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
                      border: Border.all(color: gold.withValues(alpha: 0.18)),
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
                                  color: gold.withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: gold.withValues(alpha: 0.20),
                                  ),
                                ),
                                child: Icon(
                                  Icons.assignment_outlined,
                                  color: gold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$saludo, portal del ajustador',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Siniestros • Inspección • Dictamen • Seguimiento',
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
                              'Define tu disponibilidad para recibir servicios y atención en campo.',
                        ),
                        _card(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _estadoChip('Disponible'),
                              _estadoChip('Ocupado'),
                              _estadoChip('En proceso'),
                            ],
                          ),
                        ),

                        _sectionHeader('Acciones rápidas'),
                        Row(
                          children: [
                            _quickAction(
                              icon: Icons.assignment_late_outlined,
                              label: 'Siniestros',
                              onTap: () =>
                                  _go(const SiniestrosAsignadosScreen()),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.search_outlined,
                              label: 'Inspección',
                              onTap: () => _go(const InspeccionSitioScreen()),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.gavel_outlined,
                              label: 'Dictamen',
                              onTap: () => _go(const DictamenPreliminarScreen()),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.event_available_outlined,
                              label: 'Agenda',
                              onTap: () => _go(const AgendaScreen()),
                            ),
                          ],
                        ),

                        _sectionHeader(
                          'Base común',
                          subtitle:
                              'Módulos generales disponibles para todos los portales.',
                        ),
                        _tile(
                          icon: Icons.verified_user_outlined,
                          title: 'Perfil profesional',
                          subtitle: 'Datos personales, perfil y verificación.',
                          onTap: () => _go(const PerfilVerificadoScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.location_on_outlined,
                          title: 'Ubicación',
                          subtitle:
                              'Comparte tu ubicación en tiempo real cuando estés activo.',
                          onTap: () => _go(
                            LocalizacionPanel(
                              idProfesional: widget.ajustadorId,
                              perfil: 'Ajustadores',
                            ),
                          ),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.event_available_outlined,
                          title: 'Agenda',
                          subtitle:
                              'Citas, visitas, recordatorios y programación.',
                          onTap: () => _go(const AgendaScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.history,
                          title: 'Historial',
                          subtitle:
                              'Consulta registros y atenciones realizadas.',
                          onTap: () => _go(const HistorialScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.attach_money,
                          title: 'Ingresos',
                          subtitle:
                              'Pagos, comisiones y resumen de ingresos.',
                          onTap: () => _go(const IngresosScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.star_outline,
                          title: 'Calificaciones',
                          subtitle:
                              'Evaluaciones y comentarios recibidos.',
                          onTap: () => _go(const CalificacionesScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.notifications_none,
                          title: 'Notificaciones',
                          subtitle: 'Alertas y avisos del sistema.',
                          onTap: () => _go(
                            NotificacionesScreen(
                              profesionalId: widget.ajustadorId,
                            ),
                          ),
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
                          title: 'Soporte',
                          subtitle: 'Ayuda técnica y asistencia.',
                          onTap: () => _go(const SoporteScreen()),
                        ),

                        _sectionHeader(
                          'Módulos del ajustador',
                          subtitle:
                              'Herramientas operativas para atención y seguimiento del siniestro.',
                        ),
                        _tile(
                          icon: Icons.assignment_late_outlined,
                          title: 'Siniestros asignados',
                          subtitle:
                              'Consulta siniestros, prioridad, fecha y estado.',
                          onTap: () => _go(const SiniestrosAsignadosScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.search_outlined,
                          title: 'Inspección en sitio',
                          subtitle:
                              'Registro de visita, condiciones y hallazgos.',
                          onTap: () => _go(const InspeccionSitioScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.badge_outlined,
                          title: 'Datos de póliza',
                          subtitle:
                              'Cobertura, vigencia, deducible y asegurado.',
                          onTap: () => _go(const DatosPolizaScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.groups_outlined,
                          title: 'Terceros involucrados',
                          subtitle:
                              'Datos, versiones y participación de terceros.',
                          onTap: () => _go(
                            const TercerosInvolucradosScreen(),
                          ),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.car_crash_outlined,
                          title: 'Daños reportados',
                          subtitle:
                              'Captura de daños, afectaciones y observaciones.',
                          onTap: () => _go(const DanosReportadosScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.gavel_outlined,
                          title: 'Dictamen preliminar',
                          subtitle:
                              'Procedencia, observaciones y resolución inicial.',
                          onTap: () => _go(const DictamenPreliminarScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.track_changes_outlined,
                          title: 'Seguimiento',
                          subtitle:
                              'Control del avance y estatus del siniestro.',
                          onTap: () => _go(
                            const SeguimientoSiniestroScreen(),
                          ),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.edit_note_outlined,
                          title: 'Bitácora',
                          subtitle:
                              'Notas cronológicas y acciones realizadas.',
                          onTap: () => _go(const BitacoraAjustadorScreen()),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tip: Mantén actualizados los siniestros, inspecciones y dictámenes para agilizar la atención y el seguimiento.',
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