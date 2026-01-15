import 'package:flutter/material.dart';

// ✅ Reutiliza módulos base (los que ya hicimos para investigador)
import '../investigador/investigador_modulos/perfil_verificado_screen.dart';
import '../investigador/investigador_modulos/ubicacion_tiempo_real_screen.dart';
import '../investigador/investigador_modulos/agenda_screen.dart';
import '../investigador/investigador_modulos/historial_screen.dart';
import '../investigador/investigador_modulos/ingresos_screen.dart';
import '../investigador/investigador_modulos/calificaciones_screen.dart';
import '../investigador/investigador_modulos/notificaciones_screen.dart';
import '../investigador/investigador_modulos/configuracion_screen.dart';
import '../investigador/investigador_modulos/soporte_screen.dart';
import '../investigador/investigador_modulos/contacto_profesional_screen.dart';

// ✅ Módulos propios de Valuador
import 'valuador_modulos/solicitudes_avaluo_screen.dart';
import 'valuador_modulos/avaluos_inmobiliarios_screen.dart';
import 'valuador_modulos/dictamenes_reportes_screen.dart';
import 'valuador_modulos/evidencia_fotografica_screen.dart';

class PanelValuadorScreen extends StatefulWidget {
  const PanelValuadorScreen({super.key});

  @override
  State<PanelValuadorScreen> createState() => _PanelValuadorScreenState();
}

class _PanelValuadorScreenState extends State<PanelValuadorScreen> {
  String estado = 'Disponible';

  void _toast(String msg) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
      ),
    );
  }

  void _go(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _sectionTitle(String text, Color gold) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Row(
        children: [
          Container(width: 6, height: 18, color: gold),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(.92),
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    required Color gold,
  }) {
    return InkWell(
      onTap: onTap ?? () => _toast('🧩 "$title" (pendiente de conectar)'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: gold.withOpacity(.20)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: gold.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gold.withOpacity(.25)),
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
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.72),
                        fontSize: 12.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(.55)),
          ],
        ),
      ),
    );
  }

  Widget _estadoChip(String label, Color gold) {
    final active = estado == label;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => setState(() => estado = label),
      labelStyle: TextStyle(
        color: active ? Colors.black : Colors.white.withOpacity(.88),
        fontWeight: FontWeight.w800,
      ),
      selectedColor: gold,
      backgroundColor: Colors.white.withOpacity(.06),
      shape: StadiumBorder(
        side: BorderSide(color: gold.withOpacity(.25)),
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
        color: Colors.black.withOpacity(.30),
        blurRadius: 24,
        offset: const Offset(0, 10),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel • Valuador'),
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/iconos/mazo-libro.png', fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(.62))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: gold.withOpacity(.22)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF12161C).withOpacity(.88),
                          const Color(0xFF181E26).withOpacity(.92),
                        ],
                      ),
                      boxShadow: shadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // HEADER
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: gold.withOpacity(.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: gold.withOpacity(.25)),
                              ),
                              child: Icon(Icons.assessment, color: gold),
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
                                  Text(
                                    'Avalúos • Dictámenes • Reportes',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(.70),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        Container(height: 1, color: gold.withOpacity(.18)),
                        const SizedBox(height: 14),

                        // BASE COMÚN
                        _sectionTitle('BASE COMÚN (todos los socios)', gold),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _estadoChip('Disponible', gold),
                            _estadoChip('Ocupado', gold),
                            _estadoChip('Fuera de servicio', gold),
                          ],
                        ),

                        const SizedBox(height: 12),
                        _tile(
                          icon: Icons.verified_user_outlined,
                          title: 'Perfil profesional verificado',
                          subtitle: 'Datos, documentos y validación.',
                          gold: gold,
                          onTap: () => _go(const PerfilVerificadoScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.location_on_outlined,
                          title: 'Ubicación en tiempo real',
                          subtitle: 'Ubicación activa cuando estés disponible.',
                          gold: gold,
                          onTap: () => _go(const UbicacionTiempoRealScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.event_available_outlined,
                          title: 'Agenda / citas',
                          subtitle: 'Disponibilidad y visitas.',
                          gold: gold,
                          onTap: () => _go(const AgendaScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.history,
                          title: 'Historial de servicios',
                          subtitle: 'Avalúos realizados.',
                          gold: gold,
                          onTap: () => _go(const HistorialScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.attach_money,
                          title: 'Ingresos / comisiones',
                          subtitle: 'Pagos y facturación.',
                          gold: gold,
                          onTap: () => _go(const IngresosScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.star_outline,
                          title: 'Calificaciones de usuarios',
                          subtitle: 'Opiniones y promedio.',
                          gold: gold,
                          onTap: () => _go(const CalificacionesScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.notifications_none,
                          title: 'Notificaciones',
                          subtitle: 'Asignaciones y alertas.',
                          gold: gold,
                          onTap: () => _go(const NotificacionesScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.settings_outlined,
                          title: 'Configuración',
                          subtitle: 'Cuenta y preferencias.',
                          gold: gold,
                          onTap: () => _go(const ConfiguracionScreen()),
                        ),
                        const SizedBox(height: 10),

                        // ✅ contacto profesional
                        _tile(
                          icon: Icons.contact_phone_outlined,
                          title: 'Contacto profesional',
                          subtitle: 'Teléfono, correo, WhatsApp.',
                          gold: gold,
                          onTap: () => _go(const ContactoProfesionalScreen()),
                        ),
                        const SizedBox(height: 10),

                        _tile(
                          icon: Icons.support_agent_outlined,
                          title: 'Soporte técnico',
                          subtitle: 'Ayuda técnica.',
                          gold: gold,
                          onTap: () => _go(const SoporteScreen()),
                        ),

                        // MÓDULOS VALUADOR
                        _sectionTitle('MÓDULOS VALUADOR', gold),

                        _tile(
                          icon: Icons.assignment_outlined,
                          title: 'Solicitudes de avalúo',
                          subtitle: 'Aceptar o rechazar solicitudes.',
                          gold: gold,
                          onTap: () => _go(const SolicitudesAvaluoScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.home_work_outlined,
                          title: 'Avalúos inmobiliarios',
                          subtitle: 'Casas, terrenos y edificios.',
                          gold: gold,
                          onTap: () => _go(const AvaluosInmobiliariosScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.picture_as_pdf_outlined,
                          title: 'Dictámenes / reportes',
                          subtitle: 'Generar y subir documentos.',
                          gold: gold,
                          onTap: () => _go(const DictamenesReportesScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.camera_alt_outlined,
                          title: 'Evidencia fotográfica',
                          subtitle: 'Fotos del inmueble.',
                          gold: gold,
                          onTap: () => _go(const EvidenciaFotograficaScreen()),
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


