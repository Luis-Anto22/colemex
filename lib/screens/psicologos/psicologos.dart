import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Base común
import 'package:advocatus/screens/common/agenda/agenda_screen.dart';
import 'package:advocatus/screens/common/ubicacion/ubicacion_tiempo_real_screen.dart';
import 'package:advocatus/screens/common/historial/historial_screen.dart';
import 'package:advocatus/screens/common/ingresos/ingresos_screen.dart';
import 'package:advocatus/screens/common/calificaciones/calificaciones_screen.dart';
import 'package:advocatus/screens/common/notificaciones/notificaciones_screen.dart';
import 'package:advocatus/screens/common/configuracion/configuracion_screen.dart';
import 'package:advocatus/screens/common/soporte/soporte_screen.dart';
import 'package:advocatus/screens/common/perfil/perfil_verificado_screen.dart';

// Módulos del psicólogo
import 'package:advocatus/screens/psicologos/pantalla_pacientes.dart';
import 'package:advocatus/screens/psicologos/pantalla_expediente_clinico.dart';
import 'package:advocatus/screens/psicologos/pantalla_notas_sesion.dart';
import 'package:advocatus/screens/psicologos/pantalla_evaluaciones.dart';
import 'package:advocatus/screens/psicologos/pantalla_plan_terapeutico.dart';
import 'package:advocatus/screens/psicologos/pantalla_reportes_psicologicos.dart';
import 'package:advocatus/screens/psicologos/pantalla_tareas_terapeuticas.dart';
import 'package:advocatus/screens/psicologos/pantalla_seguimiento_emocional.dart';

class PanelPsicologos extends StatefulWidget {
  final int? psicologoId;

  const PanelPsicologos({
    super.key,
    this.psicologoId,
  });

  @override
  State<PanelPsicologos> createState() => _PanelPsicologosState();
}

class _PanelPsicologosState extends State<PanelPsicologos> {
  String estado = 'Disponible';
  String nombrePsicologo = 'Psicólogo';

  @override
  void initState() {
    super.initState();
    _cargarNombre();
  }

  Future<void> _cargarNombre() async {
    final prefs = await SharedPreferences.getInstance();
    final nombreGuardado = (prefs.getString('nombre') ?? '').trim();

    if (!mounted) return;

    setState(() {
      nombrePsicologo =
          nombreGuardado.isNotEmpty ? nombreGuardado : 'Psicólogo';
    });
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

  String _nombreConTitulo(String nombre) {
    final n = nombre.trim();

    if (n.isEmpty) return 'Psicólogo';

    final lower = n.toLowerCase();
    if (lower.startsWith('psic. ') ||
        lower.startsWith('psic ') ||
        lower.startsWith('psicólogo ') ||
        lower.startsWith('psicologa ') ||
        lower.startsWith('psicóloga ')) {
      return n;
    }

    return 'Psic. $n';
  }

  void _go(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
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
        border: Border.all(color: accent.withValues(alpha: 0.18)),
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
          border: Border.all(color: accent.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: accent.withValues(alpha: 0.10),
                border: Border.all(color: accent.withValues(alpha: 0.18)),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: accent.withValues(alpha: 0.14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: accent),
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
        side: BorderSide(color: accent.withValues(alpha: 0.22)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? theme.primaryColor;

    final saludo = _saludoPorHora();
    final nombreMostrado = _nombreConTitulo(nombrePsicologo);

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
        title: const Text('Panel • Psicólogo'),
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
                                    Icons.psychology_outlined,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$saludo, $nombreMostrado',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Pacientes • Sesiones • Seguimiento terapéutico',
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
                                Container(
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
                                ),
                              ],
                            ),
                          ),

                          _sectionHeader(
                            'Estado profesional',
                            subtitle:
                                'Define tu disponibilidad para recibir pacientes y dar seguimiento terapéutico.',
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
                                icon: Icons.people_alt_outlined,
                                label: 'Pacientes',
                                onTap: () =>
                                    _go(PantallaPacientes(psicologoId: widget.psicologoId ?? 0)),
                              ),
                              const SizedBox(width: 10),
                              _quickAction(
                                icon: Icons.folder_shared_outlined,
                                label: 'Expediente',
                                onTap: () => _go(
                                  PantallaExpedienteClinico(
                                    psicologoId: widget.psicologoId ?? 0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _quickAction(
                                icon: Icons.edit_note_outlined,
                                label: 'Sesiones',
                                onTap: () => _go(
                                  PantallaNotasSesion(
                                    psicologoId: widget.psicologoId ?? 0,
                                  ),
                                ),
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
                                'Módulos obligatorios para todos los socios.',
                          ),
                          _tile(
                            icon: Icons.verified_user_outlined,
                            title: 'Perfil profesional verificado',
                            subtitle:
                                'Completa datos, documentos y validación.',
                            onTap: () => _go(const PerfilVerificadoScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.location_on_outlined,
                            title: 'Ubicación en tiempo real',
                            subtitle:
                                'Comparte ubicación cuando estés activo.',
                            onTap: () =>
                                _go(const UbicacionTiempoRealScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.event_available_outlined,
                            title: 'Agenda / citas',
                            subtitle:
                                'Organiza sesiones, consultas y seguimientos.',
                            onTap: () => _go(const AgendaScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.history,
                            title: 'Historial de servicios',
                            subtitle:
                                'Consulta atenciones y movimientos previos.',
                            onTap: () => _go(const HistorialScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.attach_money,
                            title: 'Ingresos / comisiones',
                            subtitle:
                                'Revisa cobros, pagos y resumen de ingresos.',
                            onTap: () => _go(const IngresosScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.star_outline,
                            title: 'Calificaciones',
                            subtitle:
                                'Promedio y comentarios de tus pacientes.',
                            onTap: () => _go(const CalificacionesScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.notifications_none,
                            title: 'Notificaciones',
                            subtitle:
                                'Alertas importantes y novedades del sistema.',
                            onTap: () => _go(const NotificacionesScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.settings_outlined,
                            title: 'Configuración',
                            subtitle:
                                'Cuenta, seguridad y preferencias.',
                            onTap: () => _go(const ConfiguracionScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.support_agent_outlined,
                            title: 'Soporte técnico',
                            subtitle:
                                'Ayuda y contacto con soporte.',
                            onTap: () => _go(const SoporteScreen()),
                          ),

                          _sectionHeader(
                            'Módulos del psicólogo',
                            subtitle:
                                'Herramientas especializadas para la atención terapéutica.',
                          ),
                          _tile(
                            icon: Icons.people_alt_outlined,
                            title: 'Pacientes',
                            subtitle:
                                'Lista de pacientes con información general y seguimiento.',
                            onTap: () => _go(
                              PantallaPacientes(
                                psicologoId: widget.psicologoId ?? 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.folder_shared_outlined,
                            title: 'Expediente clínico',
                            subtitle:
                                'Antecedentes, evolución y registro clínico.',
                            onTap: () => _go(
                              PantallaExpedienteClinico(
                                psicologoId: widget.psicologoId ?? 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.edit_note_outlined,
                            title: 'Notas de sesión',
                            subtitle:
                                'Guarda observaciones y avances por consulta.',
                            onTap: () => _go(
                              PantallaNotasSesion(
                                psicologoId: widget.psicologoId ?? 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.quiz_outlined,
                            title: 'Evaluaciones',
                            subtitle:
                                'Tests, escalas y resultados de valoración.',
                            onTap: () => _go(
                              PantallaEvaluaciones(
                                psicologoId: widget.psicologoId ?? 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.flag_outlined,
                            title: 'Plan terapéutico',
                            subtitle:
                                'Objetivos, metas y estrategia de intervención.',
                            onTap: () => _go(
                              PantallaPlanTerapeutico(
                                psicologoId: widget.psicologoId ?? 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.description_outlined,
                            title: 'Reportes psicológicos',
                            subtitle:
                                'Constancias, informes y documentos clínicos.',
                            onTap: () => _go(
                              PantallaReportesPsicologicos(
                                psicologoId: widget.psicologoId ?? 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.assignment_outlined,
                            title: 'Tareas terapéuticas',
                            subtitle:
                                'Ejercicios y actividades para el paciente.',
                            onTap: () => _go(
                              PantallaTareasTerapeuticas(
                                psicologoId: widget.psicologoId ?? 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.monitor_heart_outlined,
                            title: 'Seguimiento emocional',
                            subtitle:
                                'Monitoreo del estado emocional y avances.',
                            onTap: () => _go(
                              PantallaSeguimientoEmocional(
                                psicologoId: widget.psicologoId ?? 0,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          Text(
                            'Tip: Mantén actualizados tus expedientes, notas de sesión y seguimiento para brindar una mejor atención a tus pacientes.',
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
          ),
        ],
      ),
    );
  }
}