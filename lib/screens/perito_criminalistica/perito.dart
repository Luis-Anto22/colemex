import 'package:flutter/material.dart';

// COMMON SCREENS
import 'package:colemex/screens/common/agenda/agenda_screen.dart';
import 'package:colemex/screens/common/calificaciones/calificaciones_screen.dart';
import 'package:colemex/screens/common/configuracion/configuracion_screen.dart';
import 'package:colemex/screens/common/historial/historial_screen.dart';
import 'package:colemex/screens/common/ingresos/ingresos_screen.dart';
import 'package:colemex/screens/common/notificaciones/notificaciones_screen.dart';
import 'package:colemex/screens/common/soporte/soporte_screen.dart';
import 'package:colemex/screens/common/perfil/perfil_verificado_screen.dart';

class PanelPeritoScreen extends StatefulWidget {
  const PanelPeritoScreen({super.key});

  @override
  State<PanelPeritoScreen> createState() => _PanelPeritoScreenState();
}

class _PanelPeritoScreenState extends State<PanelPeritoScreen> {
  void _go(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ─────────────── UI HELPERS ───────────────

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
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(.60)),
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

  // ─────────────── BUILD ───────────────

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
                        // HERO
                        _card(
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: gold.withOpacity(.12),
                                  border: Border.all(color: gold.withOpacity(.20)),
                                ),
                                child: Icon(Icons.science_outlined, color: gold),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Portal del perito',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Análisis técnico y dictámenes periciales',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ACCIONES RÁPIDAS
                        _sectionHeader('Acciones rápidas'),
                        Row(
                          children: [
                            _quickAction(
                              icon: Icons.event_available_outlined,
                              label: 'Agenda',
                              onTap: () => _go(const AgendaScreen()),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.attach_money,
                              label: 'Ingresos',
                              onTap: () => _go(const IngresosScreen()),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.notifications_none,
                              label: 'Alertas',
                              onTap: () => _go(const NotificacionesScreen()),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.support_agent_outlined,
                              label: 'Soporte',
                              onTap: () => _go(const SoporteScreen()),
                            ),
                          ],
                        ),

                        // MÓDULOS
                        _sectionHeader(
                          'Gestión pericial',
                          subtitle: 'Herramientas y módulos principales.',
                        ),

                        _tile(
                          icon: Icons.event_available_outlined,
                          title: 'Agenda',
                          subtitle: 'Citas, inspecciones y peritajes.',
                          onTap: () => _go(const AgendaScreen()),
                        ),
                        const SizedBox(height: 10),

                        _tile(
                          icon: Icons.history,
                          title: 'Historial',
                          subtitle: 'Servicios realizados y dictámenes.',
                          onTap: () => _go(const HistorialScreen()),
                        ),
                        const SizedBox(height: 10),

                        _tile(
                          icon: Icons.attach_money,
                          title: 'Ingresos',
                          subtitle: 'Pagos, honorarios y facturación.',
                          onTap: () => _go(const IngresosScreen()),
                        ),
                        const SizedBox(height: 10),

                        _tile(
                          icon: Icons.star_outline,
                          title: 'Calificaciones',
                          subtitle: 'Evaluaciones y comentarios.',
                          onTap: () => _go(const CalificacionesScreen()),
                        ),
                        const SizedBox(height: 10),

                        _tile(
                          icon: Icons.notifications_none,
                          title: 'Notificaciones',
                          subtitle: 'Avisos y alertas del sistema.',
                          onTap: () => _go(const NotificacionesScreen()),
                        ),
                        const SizedBox(height: 10),

                        _tile(
                          icon: Icons.verified_user_outlined,
                          title: 'Perfil profesional',
                          subtitle: 'Datos, certificaciones y verificación.',
                          onTap: () => _go(const PerfilVerificadoScreen()),
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
                          title: 'Soporte',
                          subtitle: 'Ayuda técnica y asistencia.',
                          onTap: () => _go(const SoporteScreen()),
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
