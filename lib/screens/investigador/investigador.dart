import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// módulos investigador_modulos
import 'investigador_modulos/casos_asignados_screen.dart';
import 'investigador_modulos/bitacora_screen.dart';
import 'investigador_modulos/evidencias_screen.dart';
import 'investigador_modulos/rutas_screen.dart';
import 'investigador_modulos/perfil_verificado_screen.dart';
import 'investigador_modulos/agenda_screen.dart';
import 'investigador_modulos/historial_screen.dart';
import 'investigador_modulos/ingresos_screen.dart';
import 'investigador_modulos/calificaciones_screen.dart';
import 'investigador_modulos/notificaciones_screen.dart';
import 'investigador_modulos/configuracion_screen.dart';
import 'investigador_modulos/soporte_screen.dart';
import 'investigador_modulos/ubicacion_tiempo_real_screen.dart';



class PanelInvestigadorScreen extends StatefulWidget {
  const PanelInvestigadorScreen({super.key});

  @override
  State<PanelInvestigadorScreen> createState() =>
      _PanelInvestigadorScreenState();
}

class _PanelInvestigadorScreenState extends State<PanelInvestigadorScreen> {
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

    // ✅ Dorado institucional desde tu theme actual
    final gold = theme.primaryColor;

    // ✅ Color de appbar desde tu theme actual
    final headerBg =
        theme.appBarTheme.backgroundColor ?? theme.primaryColor;

    // ✅ Sombras básicas (no dependemos de AppTheme.shadow)
    final shadow = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withOpacity(.30),
        blurRadius: 24,
        offset: const Offset(0, 10),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
        title: const Text('Panel • Investigador'),
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
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: gold.withOpacity(.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: gold.withOpacity(.25),
                                ),
                              ),
                              child: Icon(Icons.search, color: gold),
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
                                    'Investigación • Evidencias • Bitácora',
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
                          subtitle: 'Datos, foto, documentos y verificación.',
                          gold: gold,
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.location_on_outlined,
                          title: 'Ubicación en tiempo real',
                          subtitle: 'Compartir ubicación cuando estés activo.',
                          gold: gold,
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.event_available_outlined,
                          title: 'Agenda / citas',
                          subtitle: 'Disponibilidad, horarios y visitas.',
                          gold: gold,
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.history,
                          title: 'Historial de servicios',
                          subtitle: 'Registros y cierres de investigaciones.',
                          gold: gold,
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.attach_money,
                          title: 'Ingresos / comisiones',
                          subtitle: 'Resumen, pagos y facturación.',
                          gold: gold,
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.star_outline,
                          title: 'Calificaciones de usuarios',
                          subtitle: 'Promedio y comentarios.',
                          gold: gold,
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.notifications_none,
                          title: 'Notificaciones',
                          subtitle: 'Nuevas asignaciones y alertas.',
                          gold: gold,
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.settings_outlined,
                          title: 'Configuración',
                          subtitle: 'Cuenta, privacidad y preferencias.',
                          gold: gold,
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.support_agent_outlined,
                          title: 'Contacto / soporte',
                          subtitle: 'Ayuda técnica y soporte.',
                          gold: gold,
                        ),

                        // ESPECÍFICO INVESTIGADOR
                        _sectionTitle('MÓDULOS INVESTIGADOR', gold),
                        _tile(
                          icon: Icons.assignment_outlined,
                          title: 'Casos asignados',
                          subtitle: 'Ver, aceptar y gestionar casos.',
                          gold: gold,
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.notes_outlined,
                          title: 'Bitácora / seguimiento',
                          subtitle: 'Notas, avances y estatus del caso.',
                          gold: gold,
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.camera_alt_outlined,
                          title: 'Evidencias (fotos / archivos)',
                          subtitle: 'Subir y organizar evidencias.',
                          gold: gold,
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.map_outlined,
                          title: 'Rutas / ubicaciones',
                          subtitle: 'Puntos de interés y ubicación de visitas.',
                          gold: gold,
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
