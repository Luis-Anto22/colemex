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

// MÓDULOS PERITO EN CRIMINALÍSTICA
import 'perito_modulos/agenda_inspecciones_screen.dart';
import 'perito_modulos/cadena_custodia_screen.dart';
import 'perito_modulos/casos_asignados_perito_screen.dart';
import 'perito_modulos/dictamenes_periciales_screen.dart';
import 'perito_modulos/evidencias_criminalisticas_screen.dart';
import 'perito_modulos/historial_pericial_screen.dart';
import 'perito_modulos/reporte_fotografico_screen.dart';

class PanelPeritoScreen extends StatefulWidget {
  final int peritoId;

  const PanelPeritoScreen({
    super.key,
    required this.peritoId,
  });

  @override
  State<PanelPeritoScreen> createState() => _PanelPeritoScreenState();
}

class _PanelPeritoScreenState extends State<PanelPeritoScreen> {
  String estado = 'Disponible';

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
        title: const Text('Panel • Perito en Criminalística'),
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () => _go(const NotificacionesScreen()),
            icon: const Icon(Icons.notifications_none),
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
                                  Icons.science_outlined,
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
                                      'Criminalística • Evidencias • Dictámenes',
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
                                CasosAsignadosPeritoScreen(
                                  peritoId: widget.peritoId,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.camera_alt_outlined,
                              label: 'Evidencias',
                              onTap: () => _go(
                                EvidenciasCriminalisticasScreen(
                                  peritoId: widget.peritoId,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.event_available_outlined,
                              label: 'Agenda',
                              onTap: () => _go(
                                AgendaInspeccionesScreen(
                                  peritoId: widget.peritoId,
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
                          subtitle: 'Registros y cierres de peritajes.',
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
                          icon: Icons.notifications_none,
                          title: 'Notificaciones',
                          subtitle: 'Nuevas asignaciones y alertas.',
                          onTap: () => _go(const NotificacionesScreen()),
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
                          'Módulos del perito en criminalística',
                          subtitle:
                              'Herramientas específicas para tu profesión.',
                        ),
                        _tile(
                          icon: Icons.assignment_outlined,
                          title: 'Casos asignados',
                          subtitle: 'Ver, aceptar y gestionar casos periciales.',
                          onTap: () => _go(
                            CasosAsignadosPeritoScreen(
                              peritoId: widget.peritoId,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.search_outlined,
                          title: 'Detalle del caso',
                          subtitle:
                              'Abre primero un caso asignado para consultar su detalle.',
                          onTap: () => _go(
                            CasosAsignadosPeritoScreen(
                              peritoId: widget.peritoId,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.camera_alt_outlined,
                          title: 'Evidencias criminalísticas',
                          subtitle: 'Subir y organizar indicios, fotos y archivos.',
                          onTap: () => _go(
                            EvidenciasCriminalisticasScreen(
                              peritoId: widget.peritoId,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.account_tree_outlined,
                          title: 'Cadena de custodia',
                          subtitle:
                              'Control de entrega, recepción y movimientos.',
                          onTap: () => _go(
                            CadenaCustodiaScreen(
                              peritoId: widget.peritoId,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.description_outlined,
                          title: 'Dictámenes periciales',
                          subtitle: 'Crear, subir y consultar dictámenes.',
                          onTap: () => _go(
                            DictamenesPericialesScreen(
                              peritoId: widget.peritoId,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.photo_library_outlined,
                          title: 'Reporte fotográfico',
                          subtitle:
                              'Organizar fotografías del lugar e indicios.',
                          onTap: () => _go(
                            ReporteFotograficoScreen(
                              peritoId: widget.peritoId,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.event_note_outlined,
                          title: 'Agenda de inspecciones',
                          subtitle:
                              'Programar visitas, inspecciones y peritajes.',
                          onTap: () => _go(
                            AgendaInspeccionesScreen(
                              peritoId: widget.peritoId,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.manage_history_outlined,
                          title: 'Historial pericial',
                          subtitle:
                              'Actividad, cambios y trazabilidad del perito.',
                          onTap: () => _go(
                            HistorialPericialScreen(
                              peritoId: widget.peritoId,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        Text(
                          'Tip: Mantén tu estado, ubicación, evidencias y dictámenes actualizados para recibir más asignaciones.',
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