import 'dart:math';

import 'package:flutter/material.dart';

import 'lista_profesionales_screen.dart';
import 'estadisticas_general_screen.dart';
import 'auditores_screen.dart';
import 'verificaciones_screen.dart';
import 'planes_screen.dart';
import 'pagos_screen.dart';
import 'casos_admin_screen.dart';
import 'notificaciones_admin_screen.dart';
import 'configuracion_admin_screen.dart';
import '../universal_menu.dart';

class PanelAdminHome extends StatefulWidget {
  const PanelAdminHome({super.key});

  @override
  State<PanelAdminHome> createState() => _PanelAdminHomeState();
}

class _PanelAdminHomeState extends State<PanelAdminHome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.85),
        foregroundColor: Colors.white,
        title: const Text(
          'Panel Administrador',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          UniversalMenu(
            onSelected: (value) {
              if (value == 'configuracion') {
                _goTo(context, const ConfiguracionAdminScreen());
              } else if (value == 'cerrar') {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _MovingParticlesPainter(
                    progress: _backgroundController.value,
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.3,
                  colors: [
                    const Color(0xFF1E3A8A).withOpacity(0.35),
                    const Color(0xFF020617).withOpacity(0.88),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: Colors.white,
              backgroundColor: const Color(0xFF111827),
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isWide ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderAdmin(isWide: isWide),
                    const SizedBox(height: 24),

                    const _SectionTitle(
                      title: 'Resumen general',
                      subtitle: 'Vista rápida del estado actual del sistema',
                    ),
                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: const [
                        _MetricCard(
                          title: 'Profesionales',
                          value: 'Activos',
                          subtitle: 'Administración por perfil',
                          icon: Icons.badge_rounded,
                          glowColor: Color(0xFF38BDF8),
                        ),
                        _MetricCard(
                          title: 'Auditores',
                          value: 'Revisión',
                          subtitle: 'Validación documental',
                          icon: Icons.verified_user_rounded,
                          glowColor: Color(0xFFA855F7),
                        ),
                        _MetricCard(
                          title: 'Pagos',
                          value: 'Planes',
                          subtitle: 'Preparado para Play Store',
                          icon: Icons.payments_rounded,
                          glowColor: Color(0xFFF97316),
                        ),
                        _MetricCard(
                          title: 'Verificación',
                          value: 'Pendiente',
                          subtitle: 'Flujo futuro listo',
                          icon: Icons.fact_check_rounded,
                          glowColor: Color(0xFF06B6D4),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    const _SectionTitle(
                      title: 'Módulos principales',
                      subtitle: 'Centro de control del administrador',
                    ),
                    const SizedBox(height: 14),

                    GridView.count(
                      crossAxisCount: isWide ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: isWide ? 1.22 : 0.92,
                      children: [
                        _AdminModuleCard(
                          title: 'Profesionales',
                          subtitle: 'Ver, buscar y editar perfiles',
                          icon: Icons.badge_rounded,
                          glowColor: const Color(0xFF38BDF8),
                          onTap: () {
                            _goTo(
                              context,
                              const ListaProfesionalesScreen(),
                            );
                          },
                        ),
                        _AdminModuleCard(
                          title: 'Estadísticas',
                          subtitle: 'Resumen general del sistema',
                          icon: Icons.bar_chart_rounded,
                          glowColor: const Color(0xFF22C55E),
                          onTap: () {
                            _goTo(
                              context,
                              const EstadisticasGeneralScreen(),
                            );
                          },
                        ),
                        _AdminModuleCard(
                          title: 'Auditores',
                          subtitle: 'Validadores del sistema',
                          icon: Icons.verified_user_rounded,
                          glowColor: const Color(0xFFA855F7),
                          onTap: () {
                            _goTo(
                              context,
                              const AuditoresScreen(),
                            );
                          },
                        ),
                        _AdminModuleCard(
                          title: 'Verificaciones',
                          subtitle: 'Documentos profesionales',
                          icon: Icons.fact_check_rounded,
                          glowColor: const Color(0xFF06B6D4),
                          onTap: () {
                            _goTo(
                              context,
                              const VerificacionesScreen(),
                            );
                          },
                        ),
                        _AdminModuleCard(
                          title: 'Planes',
                          subtitle: 'Paquetes para profesionales',
                          icon: Icons.workspace_premium_rounded,
                          glowColor: const Color(0xFFFACC15),
                          onTap: () {
                            _goTo(
                              context,
                              const PlanesScreen(),
                            );
                          },
                        ),
                        _AdminModuleCard(
                          title: 'Pagos',
                          subtitle: 'Estados y referencias',
                          icon: Icons.receipt_long_rounded,
                          glowColor: const Color(0xFFF97316),
                          onTap: () {
                            _goTo(
                              context,
                              const PagosScreen(),
                            );
                          },
                        ),
                        _AdminModuleCard(
                          title: 'Casos',
                          subtitle: 'Solicitudes y asignaciones',
                          icon: Icons.folder_copy_rounded,
                          glowColor: const Color(0xFFEF4444),
                          onTap: () {
                            _goTo(
                              context,
                              const CasosAdminScreen(),
                            );
                          },
                        ),
                        _AdminModuleCard(
                          title: 'Notificaciones',
                          subtitle: 'Avisos y push',
                          icon: Icons.notifications_active_rounded,
                          glowColor: const Color(0xFF38BDF8),
                          onTap: () {
                            _goTo(
                              context,
                              const NotificacionesAdminScreen(),
                            );
                          },
                        ),
                        _AdminModuleCard(
                          title: 'Configuración',
                          subtitle: 'Ajustes generales',
                          icon: Icons.settings_rounded,
                          glowColor: const Color(0xFF94A3B8),
                          onTap: () {
                            _goTo(
                              context,
                              const ConfiguracionAdminScreen(),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final bool twoColumns = constraints.maxWidth >= 850;

                        if (twoColumns) {
                          return const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _WorkflowPanel(),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _NotasPanel(),
                              ),
                            ],
                          );
                        }

                        return const Column(
                          children: [
                            _WorkflowPanel(),
                            SizedBox(height: 16),
                            _NotasPanel(),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovingParticlesPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _MovingParticlesPainter({required this.progress})
      : particles = List.generate(85, (index) {
          final random = Random(index * 999);
          return _Particle(
            x: random.nextDouble(),
            y: random.nextDouble(),
            radius: 0.8 + random.nextDouble() * 2.2,
            speed: 0.015 + random.nextDouble() * 0.045,
            opacity: 0.25 + random.nextDouble() * 0.65,
          );
        });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    for (final particle in particles) {
      final double animatedY = (particle.y + progress * particle.speed) % 1.0;
      final double wave = sin((progress * 2 * pi) + particle.y * 10) * 14;

      final Offset position = Offset(
        particle.x * size.width + wave,
        animatedY * size.height,
      );

      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(position, particle.radius, paint);
    }

    final Paint linePaint = Paint()
      ..strokeWidth = 0.4
      ..color = Colors.white.withOpacity(0.06);

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];

        final Offset o1 = Offset(
          p1.x * size.width,
          ((p1.y + progress * p1.speed) % 1.0) * size.height,
        );

        final Offset o2 = Offset(
          p2.x * size.width,
          ((p2.y + progress * p2.speed) % 1.0) * size.height,
        );

        final double distance = (o1 - o2).distance;

        if (distance < 105) {
          canvas.drawLine(o1, o2, linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MovingParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _Particle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double opacity;

  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}

class _HeaderAdmin extends StatelessWidget {
  final bool isWide;

  const _HeaderAdmin({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 28 : 22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                _buildIcon(),
                const SizedBox(width: 18),
                const Expanded(child: _HeaderText()),
                const SizedBox(width: 18),
                _buildBadge(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildIcon(),
                    const SizedBox(width: 14),
                    const Expanded(child: _HeaderText()),
                  ],
                ),
                const SizedBox(height: 18),
                _buildBadge(),
              ],
            ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF38BDF8),
            Color(0xFF2563EB),
            Color(0xFF1E40AF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withOpacity(0.35),
            blurRadius: 28,
          ),
        ],
      ),
      child: const Icon(
        Icons.admin_panel_settings_rounded,
        color: Colors.white,
        size: 38,
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            color: Color(0xFF38BDF8),
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Administrador activo',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenido, admin',
          style: TextStyle(
            color: Colors.white,
            fontSize: 29,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Centro de control COLEMEX / Advocatus',
          style: TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF38BDF8),
                Color(0xFF2563EB),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withOpacity(0.4),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.58),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color glowColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmall = MediaQuery.of(context).size.width < 500;

    return Container(
      width: isSmall ? (MediaQuery.of(context).size.width - 46) / 2 : 250,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.065),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.12),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GlowIcon(
            icon: icon,
            glowColor: glowColor,
          ),
          const SizedBox(height: 13),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE2E8F0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.25,
              color: Colors.white.withOpacity(0.52),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color glowColor;
  final VoidCallback onTap;

  const _AdminModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.065),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.11)),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GlowIcon(
                icon: icon,
                glowColor: glowColor,
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.25,
                  color: Colors.white.withOpacity(0.56),
                ),
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Text(
                    'Abrir',
                    style: TextStyle(
                      color: glowColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: glowColor,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowIcon extends StatelessWidget {
  final IconData icon;
  final Color glowColor;

  const _GlowIcon({
    required this.icon,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: glowColor.withOpacity(0.12),
        border: Border.all(color: glowColor.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.22),
            blurRadius: 22,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: glowColor,
        size: 27,
      ),
    );
  }
}

class _WorkflowPanel extends StatelessWidget {
  const _WorkflowPanel();

  @override
  Widget build(BuildContext context) {
    return _DarkPanel(
      title: 'Flujo futuro de profesionales',
      icon: Icons.account_tree_rounded,
      glowColor: const Color(0xFF38BDF8),
      child: const Column(
        children: [
          _FlowTile(
            number: '1',
            title: 'Registro',
            subtitle: 'El profesional crea su cuenta.',
          ),
          _FlowTile(
            number: '2',
            title: 'Plan y pago',
            subtitle: 'Escoge un plan y realiza el pago.',
          ),
          _FlowTile(
            number: '3',
            title: 'Documentos',
            subtitle: 'Después de pagar puede subir sus documentos.',
          ),
          _FlowTile(
            number: '4',
            title: 'Auditoría',
            subtitle: 'El auditor revisa y valida la información.',
          ),
          _FlowTile(
            number: '5',
            title: 'Verificado',
            subtitle: 'Solo después de verificarse podrá usar su panel.',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _NotasPanel extends StatelessWidget {
  const _NotasPanel();

  @override
  Widget build(BuildContext context) {
    return _DarkPanel(
      title: 'Estado actual',
      icon: Icons.info_rounded,
      glowColor: const Color(0xFFA855F7),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NoteItem(
            icon: Icons.check_circle_rounded,
            text: 'La app sigue funcionando normal.',
            color: Color(0xFF22C55E),
          ),
          _NoteItem(
            icon: Icons.check_circle_rounded,
            text: 'Las pantallas visuales ya están preparadas.',
            color: Color(0xFF22C55E),
          ),
          _NoteItem(
            icon: Icons.warning_rounded,
            text: 'Todavía no bloqueamos a los profesionales.',
            color: Color(0xFFFACC15),
          ),
          _NoteItem(
            icon: Icons.android_rounded,
            text: 'El bloqueo real se activa cuando probemos pagos en Play Store.',
            color: Color(0xFF38BDF8),
          ),
        ],
      ),
    );
  }
}

class _DarkPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color glowColor;
  final Widget child;

  const _DarkPanel({
    required this.title,
    required this.icon,
    required this.glowColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.065),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _GlowIcon(
                icon: icon,
                glowColor: glowColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _FlowTile extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool isLast;

  const _FlowTile({
    required this.number,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF38BDF8),
                      Color(0xFF2563EB),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withOpacity(0.3),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.8,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.3,
                      color: Colors.white.withOpacity(0.58),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _NoteItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.35,
                color: Colors.white.withOpacity(0.72),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}