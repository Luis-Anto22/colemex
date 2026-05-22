import 'dart:math';

import 'package:flutter/material.dart';

import 'profesional.dart';

class DetalleProfesionalScreen extends StatefulWidget {
  final Profesional profesional;

  const DetalleProfesionalScreen({
    super.key,
    required this.profesional,
  });

  @override
  State<DetalleProfesionalScreen> createState() =>
      _DetalleProfesionalScreenState();
}

class _DetalleProfesionalScreenState extends State<DetalleProfesionalScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;

  Profesional get profesional => widget.profesional;

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

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 850;
    final Color perfilColor = _colorForPerfil(profesional.perfil);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.90),
        foregroundColor: Colors.white,
        title: const Text(
          'Detalle profesional',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (_, __) {
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
                  radius: 1.35,
                  colors: [
                    perfilColor.withOpacity(0.24),
                    const Color(0xFF020617).withOpacity(0.92),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isWide ? 24 : 16,
                16,
                isWide ? 24 : 16,
                28,
              ),
              child: Column(
                children: [
                  _HeaderDetalle(
                    profesional: profesional,
                    perfilColor: perfilColor,
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool twoColumns = constraints.maxWidth >= 850;

                      if (twoColumns) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _InfoPrincipalPanel(
                                profesional: profesional,
                                perfilColor: perfilColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: [
                                  _EstadoPanel(
                                    profesional: profesional,
                                    perfilColor: perfilColor,
                                  ),
                                  const SizedBox(height: 16),
                                  _UbicacionPanel(
                                    profesional: profesional,
                                    perfilColor: perfilColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _InfoPrincipalPanel(
                            profesional: profesional,
                            perfilColor: perfilColor,
                          ),
                          const SizedBox(height: 16),
                          _EstadoPanel(
                            profesional: profesional,
                            perfilColor: perfilColor,
                          ),
                          const SizedBox(height: 16),
                          _UbicacionPanel(
                            profesional: profesional,
                            perfilColor: perfilColor,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _AccionesPanel(perfilColor: perfilColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForPerfil(String perfil) {
    final p = perfil.toLowerCase();

    if (p.contains('abogado')) return const Color(0xFF38BDF8);
    if (p.contains('ajustador')) return const Color(0xFFF97316);
    if (p.contains('perito')) return const Color(0xFFEF4444);
    if (p.contains('valuador')) return const Color(0xFF22C55E);
    if (p.contains('investigador')) return const Color(0xFFA855F7);
    if (p.contains('psic')) return const Color(0xFFEC4899);
    if (p.contains('inmobiliario')) return const Color(0xFFFACC15);
    if (p.contains('contador')) return const Color(0xFF14B8A6);
    if (p.contains('crediticio')) return const Color(0xFF6366F1);
    if (p.contains('vial')) return const Color(0xFF06B6D4);

    return const Color(0xFF94A3B8);
  }
}

class _HeaderDetalle extends StatelessWidget {
  final Profesional profesional;
  final Color perfilColor;

  const _HeaderDetalle({
    required this.profesional,
    required this.perfilColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 720;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 26 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.065),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
        boxShadow: [
          BoxShadow(
            color: perfilColor.withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                _AvatarGrande(
                  foto: profesional.foto,
                  nombre: profesional.nombre,
                  color: perfilColor,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _HeaderText(
                    profesional: profesional,
                    perfilColor: perfilColor,
                  ),
                ),
                const SizedBox(width: 18),
                _VerificadoBadge(
                  verificado: profesional.verificado == 1,
                  color: perfilColor,
                ),
              ],
            )
          : Column(
              children: [
                _AvatarGrande(
                  foto: profesional.foto,
                  nombre: profesional.nombre,
                  color: perfilColor,
                ),
                const SizedBox(height: 16),
                _HeaderText(
                  profesional: profesional,
                  perfilColor: perfilColor,
                ),
                const SizedBox(height: 14),
                _VerificadoBadge(
                  verificado: profesional.verificado == 1,
                  color: perfilColor,
                ),
              ],
            ),
    );
  }
}

class _AvatarGrande extends StatelessWidget {
  final String foto;
  final String nombre;
  final Color color;

  const _AvatarGrande({
    required this.foto,
    required this.nombre,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final String inicial =
        nombre.trim().isEmpty ? '?' : nombre.trim()[0].toUpperCase();

    return Container(
      width: 106,
      height: 106,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 28,
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: const Color(0xFF020617),
        backgroundImage: foto.trim().isNotEmpty ? NetworkImage(foto) : null,
        child: foto.trim().isEmpty
            ? Text(
                inicial,
                style: TextStyle(
                  color: color,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                ),
              )
            : null,
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final Profesional profesional;
  final Color perfilColor;

  const _HeaderText({
    required this.profesional,
    required this.perfilColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: MediaQuery.of(context).size.width >= 720
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          profesional.nombre,
          textAlign:
              MediaQuery.of(context).size.width >= 720 ? null : TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          profesional.correo,
          textAlign:
              MediaQuery.of(context).size.width >= 720 ? null : TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.60),
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: MediaQuery.of(context).size.width >= 720
              ? WrapAlignment.start
              : WrapAlignment.center,
          children: [
            _ChipDetalle(
              icon: Icons.work_rounded,
              label: profesional.perfil,
              color: perfilColor,
            ),
            _ChipDetalle(
              icon: Icons.location_city_rounded,
              label: _safeText(profesional.ciudad, 'Sin ciudad'),
              color: const Color(0xFF38BDF8),
            ),
            _ChipDetalle(
              icon: Icons.workspace_premium_rounded,
              label: _safeText(
                profesional.especialidadNombre ?? '',
                'Sin especialidad',
              ),
              color: const Color(0xFFA855F7),
            ),
          ],
        ),
      ],
    );
  }

  String _safeText(String value, String fallback) {
    return value.trim().isEmpty ? fallback : value;
  }
}

class _VerificadoBadge extends StatelessWidget {
  final bool verificado;
  final Color color;

  const _VerificadoBadge({
    required this.verificado,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeColor =
        verificado ? const Color(0xFF22C55E) : const Color(0xFFFACC15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: badgeColor.withOpacity(0.30)),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.16),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verificado
                ? Icons.verified_rounded
                : Icons.pending_actions_rounded,
            color: badgeColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            verificado ? 'Verificado' : 'Sin verificar',
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPrincipalPanel extends StatelessWidget {
  final Profesional profesional;
  final Color perfilColor;

  const _InfoPrincipalPanel({
    required this.profesional,
    required this.perfilColor,
  });

  @override
  Widget build(BuildContext context) {
    return _DarkPanel(
      title: 'Información principal',
      icon: Icons.assignment_ind_rounded,
      glowColor: perfilColor,
      child: Column(
        children: [
          _InfoRowPremium(
            icon: Icons.person_rounded,
            label: 'Nombre',
            value: profesional.nombre,
            color: perfilColor,
          ),
          _InfoRowPremium(
            icon: Icons.email_rounded,
            label: 'Correo',
            value: profesional.correo,
            color: const Color(0xFF38BDF8),
          ),
          _InfoRowPremium(
            icon: Icons.phone_rounded,
            label: 'Teléfono',
            value: profesional.telefono,
            color: const Color(0xFF22C55E),
          ),
          _InfoRowPremium(
            icon: Icons.work_rounded,
            label: 'Perfil',
            value: profesional.perfil,
            color: perfilColor,
          ),
          _InfoRowPremium(
            icon: Icons.workspace_premium_rounded,
            label: 'Especialidad',
            value: profesional.especialidadNombre ?? '',
            color: const Color(0xFFA855F7),
          ),
          _InfoRowPremium(
            icon: Icons.location_city_rounded,
            label: 'Ciudad',
            value: profesional.ciudad,
            color: const Color(0xFFFACC15),
          ),
          _InfoRowPremium(
            icon: Icons.calendar_month_rounded,
            label: 'Fecha de registro',
            value: profesional.fechaRegistro.toString(),
            color: const Color(0xFFF97316),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _EstadoPanel extends StatelessWidget {
  final Profesional profesional;
  final Color perfilColor;

  const _EstadoPanel({
    required this.profesional,
    required this.perfilColor,
  });

  @override
  Widget build(BuildContext context) {
    return _DarkPanel(
      title: 'Estado administrativo',
      icon: Icons.admin_panel_settings_rounded,
      glowColor: const Color(0xFF22C55E),
      child: Column(
        children: [
          _StatusCard(
            title: 'Estado operativo',
            value: _safeText(profesional.estado, 'No especificado'),
            icon: Icons.online_prediction_rounded,
            color: _estadoColor(profesional.estado),
          ),
          const SizedBox(height: 10),
          _StatusCard(
            title: 'Verificación',
            value: profesional.verificado == 1
                ? 'Profesional verificado'
                : 'Pendiente de verificación',
            icon: profesional.verificado == 1
                ? Icons.verified_rounded
                : Icons.pending_actions_rounded,
            color: profesional.verificado == 1
                ? const Color(0xFF22C55E)
                : const Color(0xFFFACC15),
          ),
          const SizedBox(height: 10),
          _StatusCard(
            title: 'Flujo futuro',
            value: 'Pago → Documentos → Auditoría → Panel',
            icon: Icons.account_tree_rounded,
            color: perfilColor,
          ),
        ],
      ),
    );
  }

  Color _estadoColor(String estado) {
    final e = estado.toLowerCase();

    if (e.contains('disponible')) return const Color(0xFF22C55E);
    if (e.contains('ocupado')) return const Color(0xFFFACC15);
    if (e.contains('fuera')) return const Color(0xFFEF4444);

    return const Color(0xFF94A3B8);
  }

  String _safeText(String value, String fallback) {
    return value.trim().isEmpty ? fallback : value;
  }
}

class _UbicacionPanel extends StatelessWidget {
  final Profesional profesional;
  final Color perfilColor;

  const _UbicacionPanel({
    required this.profesional,
    required this.perfilColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool tieneUbicacion =
        profesional.latitude != null && profesional.longitude != null;

    return _DarkPanel(
      title: 'Ubicación',
      icon: Icons.location_on_rounded,
      glowColor: const Color(0xFF38BDF8),
      child: tieneUbicacion
          ? Column(
              children: [
                _StatusCard(
                  title: 'Latitud',
                  value: '${profesional.latitude}',
                  icon: Icons.my_location_rounded,
                  color: const Color(0xFF38BDF8),
                ),
                const SizedBox(height: 10),
                _StatusCard(
                  title: 'Longitud',
                  value: '${profesional.longitude}',
                  icon: Icons.explore_rounded,
                  color: const Color(0xFFA855F7),
                ),
              ],
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.045),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.09)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.location_off_rounded,
                    color: Colors.white.withOpacity(0.55),
                    size: 38,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sin ubicación registrada',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cuando el profesional comparta ubicación, aparecerá aquí.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _AccionesPanel extends StatelessWidget {
  final Color perfilColor;

  const _AccionesPanel({
    required this.perfilColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.end,
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.18)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text(
              'Volver',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: perfilColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'La edición se manejará desde la lista de profesionales.',
                  ),
                  backgroundColor: Color(0xFF0F172A),
                ),
              );
            },
            icon: const Icon(Icons.edit_rounded),
            label: const Text(
              'Editar profesional',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
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
            color: glowColor.withOpacity(0.13),
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

class _InfoRowPremium extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLast;

  const _InfoRowPremium({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final String cleanValue =
        value.toString().trim().isEmpty ? 'No especificado' : value.toString();

    return Column(
      children: [
        Row(
          children: [
            _MiniGlowIcon(
              icon: icon,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.50),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    cleanValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.3,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast)
          Divider(
            height: 24,
            color: Colors.white.withOpacity(0.09),
          ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatusCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.085),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          _MiniGlowIcon(
            icon: icon,
            color: color,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.8,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipDetalle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ChipDetalle({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11.8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
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

class _MiniGlowIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _MiniGlowIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39,
      height: 39,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.11),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }
}

class _MovingParticlesPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _MovingParticlesPainter({required this.progress})
      : particles = List.generate(80, (index) {
          final random = Random(index * 777);
          return _Particle(
            x: random.nextDouble(),
            y: random.nextDouble(),
            radius: 0.8 + random.nextDouble() * 2.1,
            speed: 0.015 + random.nextDouble() * 0.045,
            opacity: 0.22 + random.nextDouble() * 0.58,
          );
        });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      final animatedY = (particle.y + progress * particle.speed) % 1.0;
      final wave = sin((progress * 2 * pi) + particle.y * 10) * 14;

      final position = Offset(
        particle.x * size.width + wave,
        animatedY * size.height,
      );

      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(position, particle.radius, paint);
    }

    final linePaint = Paint()
      ..strokeWidth = 0.4
      ..color = Colors.white.withOpacity(0.055);

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];

        final o1 = Offset(
          p1.x * size.width,
          ((p1.y + progress * p1.speed) % 1.0) * size.height,
        );

        final o2 = Offset(
          p2.x * size.width,
          ((p2.y + progress * p2.speed) % 1.0) * size.height,
        );

        final distance = (o1 - o2).distance;

        if (distance < 100) {
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