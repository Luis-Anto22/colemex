import 'dart:math';

import 'package:flutter/material.dart';

class PlanesScreen extends StatefulWidget {
  const PlanesScreen({super.key});

  @override
  State<PlanesScreen> createState() => _PlanesScreenState();
}

class _PlanesScreenState extends State<PlanesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;
  final TextEditingController _searchController = TextEditingController();

  String _filtroEstado = 'Todos';

  final List<_PlanMock> _planes = const [
    _PlanMock(
      nombre: 'Plan Básico',
      descripcion: 'Ideal para profesionales que comienzan en la plataforma.',
      precio: 299,
      duracion: '30 días',
      estado: 'Activo',
      profesionales: 12,
      beneficios: [
        'Perfil profesional visible',
        'Recepción de solicitudes',
        'Soporte básico',
      ],
    ),
    _PlanMock(
      nombre: 'Plan Profesional',
      descripcion: 'Para profesionales con mayor volumen de atención.',
      precio: 599,
      duracion: '30 días',
      estado: 'Activo',
      profesionales: 24,
      beneficios: [
        'Mayor visibilidad',
        'Prioridad en solicitudes',
        'Soporte preferente',
        'Panel avanzado',
      ],
    ),
    _PlanMock(
      nombre: 'Plan Premium',
      descripcion: 'Máxima presencia dentro de COLEMEX / Advocatus.',
      precio: 999,
      duracion: '30 días',
      estado: 'Activo',
      profesionales: 8,
      beneficios: [
        'Máxima visibilidad',
        'Asignaciones prioritarias',
        'Estadísticas avanzadas',
        'Soporte premium',
      ],
    ),
    _PlanMock(
      nombre: 'Plan Corporativo',
      descripcion: 'Pensado para despachos o equipos profesionales.',
      precio: 1499,
      duracion: '30 días',
      estado: 'Inactivo',
      profesionales: 0,
      beneficios: [
        'Múltiples profesionales',
        'Panel corporativo',
        'Reportes por equipo',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_PlanMock> get _planesFiltrados {
    final query = _searchController.text.trim().toLowerCase();

    return _planes.where((plan) {
      final coincideBusqueda = plan.nombre.toLowerCase().contains(query) ||
          plan.descripcion.toLowerCase().contains(query) ||
          plan.duracion.toLowerCase().contains(query);

      final coincideEstado =
          _filtroEstado == 'Todos' || plan.estado == _filtroEstado;

      return coincideBusqueda && coincideEstado;
    }).toList();
  }

  int get _planesActivos =>
      _planes.where((plan) => plan.estado == 'Activo').length;

  int get _profesionalesEnPlanes =>
      _planes.fold(0, (sum, plan) => sum + plan.profesionales);

  double get _ingresoEstimado =>
      _planes.fold(0, (sum, plan) => sum + (plan.precio * plan.profesionales));

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 900;
    final planesFiltrados = _planesFiltrados;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.90),
        foregroundColor: Colors.white,
        title: const Text(
          'Planes',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Crear plan',
            onPressed: _mostrarCrearPlanMock,
            icon: const Icon(Icons.add_card_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFACC15),
        foregroundColor: Colors.black,
        elevation: 10,
        onPressed: _mostrarCrearPlanMock,
        icon: const Icon(Icons.add_card_rounded),
        label: const Text(
          'Nuevo plan',
          style: TextStyle(fontWeight: FontWeight.w900),
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
                    const Color(0xFFFACC15).withOpacity(0.20),
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
                96,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderPlanes(
                    total: _planes.length,
                    activos: _planesActivos,
                    ingresoEstimado: _ingresoEstimado,
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle(
                    title: 'Resumen de planes',
                    subtitle:
                        'Pantalla visual para preparar los planes de pago de profesionales.',
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _MetricCard(
                        title: 'Planes',
                        value: _planes.length.toString(),
                        subtitle: 'Configurados',
                        icon: Icons.workspace_premium_rounded,
                        glowColor: const Color(0xFFFACC15),
                      ),
                      _MetricCard(
                        title: 'Activos',
                        value: _planesActivos.toString(),
                        subtitle: 'Disponibles para compra',
                        icon: Icons.check_circle_rounded,
                        glowColor: const Color(0xFF22C55E),
                      ),
                      _MetricCard(
                        title: 'Profesionales',
                        value: _profesionalesEnPlanes.toString(),
                        subtitle: 'Con plan asignado',
                        icon: Icons.badge_rounded,
                        glowColor: const Color(0xFF38BDF8),
                      ),
                      _MetricCard(
                        title: 'Estimado',
                        value: '\$${_ingresoEstimado.toStringAsFixed(0)}',
                        subtitle: 'Ingreso visual mensual',
                        icon: Icons.payments_rounded,
                        glowColor: const Color(0xFFF97316),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const _SectionTitle(
                    title: 'Catálogo de planes',
                    subtitle: 'Datos mock por ahora; conexión real después.',
                  ),
                  const SizedBox(height: 14),
                  _SearchFilterPanel(
                    controller: _searchController,
                    filtroEstado: _filtroEstado,
                    onFiltroChanged: (value) {
                      setState(() {
                        _filtroEstado = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (planesFiltrados.isEmpty)
                    const _EmptyPanel()
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: planesFiltrados.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 2 : 1,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: isWide ? 1.55 : 1.05,
                      ),
                      itemBuilder: (_, index) {
                        final plan = planesFiltrados[index];

                        return _PlanCard(
                          plan: plan,
                          onTap: () => _mostrarDetallePlan(plan),
                          onEditar: () => _mostrarAccionMock(
                            'Editar plan',
                            'Después conectaremos esta acción para modificar nombre, precio, duración y beneficios del plan.',
                          ),
                          onEstado: () => _mostrarAccionMock(
                            plan.estado == 'Activo'
                                ? 'Desactivar plan'
                                : 'Activar plan',
                            'Después esta acción cambiará el estado real del plan en la base de datos.',
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarCrearPlanMock() {
    _mostrarAccionMock(
      'Crear plan',
      'Aquí después abriremos un formulario real para crear planes en la tabla planes_profesionales.',
    );
  }

  void _mostrarDetallePlan(_PlanMock plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _PremiumBottomSheet(
          title: plan.nombre,
          icon: Icons.workspace_premium_rounded,
          glowColor: const Color(0xFFFACC15),
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.description_rounded,
                title: 'Descripción',
                value: plan.descripcion,
                color: const Color(0xFF38BDF8),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.payments_rounded,
                title: 'Precio',
                value: '\$${plan.precio.toStringAsFixed(2)} MXN',
                color: const Color(0xFFFACC15),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.calendar_month_rounded,
                title: 'Duración',
                value: plan.duracion,
                color: const Color(0xFFA855F7),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.badge_rounded,
                title: 'Profesionales',
                value: '${plan.profesionales} profesionales usando este plan',
                color: const Color(0xFF22C55E),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Beneficios',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.62),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...plan.beneficios.map(
                (beneficio) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _BenefitRow(text: beneficio),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarAccionMock(String titulo, String mensaje) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _PremiumBottomSheet(
          title: titulo,
          icon: Icons.construction_rounded,
          glowColor: const Color(0xFF38BDF8),
          child: Text(
            mensaje,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        );
      },
    );
  }
}

class _HeaderPlanes extends StatelessWidget {
  final int total;
  final int activos;
  final double ingresoEstimado;

  const _HeaderPlanes({
    required this.total,
    required this.activos,
    required this.ingresoEstimado,
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
            color: const Color(0xFFFACC15).withOpacity(0.16),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                const _HeaderIcon(),
                const SizedBox(width: 18),
                const Expanded(child: _HeaderText()),
                const SizedBox(width: 18),
                _HeaderCounters(
                  total: total,
                  activos: activos,
                  ingresoEstimado: ingresoEstimado,
                ),
              ],
            )
          : Column(
              children: [
                const _HeaderIcon(),
                const SizedBox(height: 16),
                const _HeaderText(),
                const SizedBox(height: 16),
                _HeaderCounters(
                  total: total,
                  activos: activos,
                  ingresoEstimado: ingresoEstimado,
                ),
              ],
            ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFACC15),
            Color(0xFFF97316),
            Color(0xFFB45309),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFACC15).withOpacity(0.30),
            blurRadius: 28,
          ),
        ],
      ),
      child: const Icon(
        Icons.workspace_premium_rounded,
        color: Colors.black,
        size: 38,
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 720;

    return Column(
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        const Text(
          'Planes profesionales',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Aquí se configurarán los planes que el profesional escoge antes de pagar.',
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.62),
            fontSize: 13.5,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HeaderCounters extends StatelessWidget {
  final int total;
  final int activos;
  final double ingresoEstimado;

  const _HeaderCounters({
    required this.total,
    required this.activos,
    required this.ingresoEstimado,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _SmallCounter(
          label: 'Planes',
          value: total.toString(),
          icon: Icons.layers_rounded,
          color: const Color(0xFFFACC15),
        ),
        _SmallCounter(
          label: 'Activos',
          value: activos.toString(),
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF22C55E),
        ),
        _SmallCounter(
          label: 'Ingreso',
          value: '\$${ingresoEstimado.toStringAsFixed(0)}',
          icon: Icons.payments_rounded,
          color: const Color(0xFFF97316),
        ),
      ],
    );
  }
}

class _SmallCounter extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SmallCounter({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 122,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.075),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
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
                Color(0xFFFACC15),
                Color(0xFFF97316),
              ],
            ),
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFACC15).withOpacity(0.35),
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
                  fontWeight: FontWeight.w600,
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
          _GlowIcon(icon: icon, glowColor: glowColor),
          const SizedBox(height: 13),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
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
              color: Colors.white.withOpacity(0.52),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchFilterPanel extends StatelessWidget {
  final TextEditingController controller;
  final String filtroEstado;
  final ValueChanged<String> onFiltroChanged;

  const _SearchFilterPanel({
    required this.controller,
    required this.filtroEstado,
    required this.onFiltroChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 720;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(child: _buildSearch()),
                const SizedBox(width: 12),
                SizedBox(width: 220, child: _buildDropdown()),
              ],
            )
          : Column(
              children: [
                _buildSearch(),
                const SizedBox(height: 12),
                _buildDropdown(),
              ],
            ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      cursorColor: const Color(0xFFFACC15),
      decoration: InputDecoration(
        hintText: 'Buscar plan por nombre, duración o descripción...',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.42),
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFFFACC15),
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(19)),
          borderSide: BorderSide(
            color: Color(0xFFFACC15),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: filtroEstado,
      dropdownColor: const Color(0xFF020617),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      iconEnabledColor: const Color(0xFFFACC15),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.tune_rounded,
          color: Color(0xFFFACC15),
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Todos', child: Text('Todos')),
        DropdownMenuItem(value: 'Activo', child: Text('Activos')),
        DropdownMenuItem(value: 'Inactivo', child: Text('Inactivos')),
      ],
      onChanged: (value) {
        if (value != null) onFiltroChanged(value);
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  final _PlanMock plan;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEstado;

  const _PlanCard({
    required this.plan,
    required this.onTap,
    required this.onEditar,
    required this.onEstado,
  });

  @override
  Widget build(BuildContext context) {
    final bool activo = plan.estado == 'Activo';
    final Color estadoColor =
        activo ? const Color(0xFF22C55E) : const Color(0xFF94A3B8);

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
                color: const Color(0xFFFACC15).withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PlanIcon(activo: activo),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PlanTitleBlock(
                      nombre: plan.nombre,
                      descripcion: plan.descripcion,
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: const Color(0xFF020617),
                    iconColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: Colors.white.withOpacity(0.12)),
                    ),
                    onSelected: (value) {
                      if (value == 'editar') onEditar();
                      if (value == 'estado') onEstado();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, color: Color(0xFFFACC15)),
                            SizedBox(width: 10),
                            Text(
                              'Editar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'estado',
                        child: Row(
                          children: [
                            Icon(
                              activo
                                  ? Icons.block_rounded
                                  : Icons.check_circle_rounded,
                              color: activo
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF22C55E),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              activo ? 'Desactivar' : 'Activar',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChipInfo(
                    icon: Icons.payments_rounded,
                    label: '\$${plan.precio.toStringAsFixed(0)} MXN',
                    color: const Color(0xFFFACC15),
                  ),
                  _ChipInfo(
                    icon: Icons.calendar_month_rounded,
                    label: plan.duracion,
                    color: const Color(0xFF38BDF8),
                  ),
                  _ChipInfo(
                    icon: activo
                        ? Icons.check_circle_rounded
                        : Icons.pause_circle_rounded,
                    label: plan.estado,
                    color: estadoColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: plan.beneficios.take(3).map((beneficio) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: _BenefitRow(text: beneficio),
                    );
                  }).toList(),
                ),
              ),
              Divider(color: Colors.white.withOpacity(0.10), height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MiniInfo(
                      icon: Icons.badge_rounded,
                      text: '${plan.profesionales} profesionales',
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.edit_rounded,
                    color: const Color(0xFFFACC15),
                    onTap: onEditar,
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon:
                        activo ? Icons.block_rounded : Icons.check_circle_rounded,
                    color:
                        activo ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                    onTap: onEstado,
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

class _PlanIcon extends StatelessWidget {
  final bool activo;

  const _PlanIcon({
    required this.activo,
  });

  @override
  Widget build(BuildContext context) {
    final color = activo ? const Color(0xFFFACC15) : const Color(0xFF94A3B8);

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.22),
            blurRadius: 20,
          ),
        ],
      ),
      child: Icon(
        Icons.workspace_premium_rounded,
        color: color,
        size: 30,
      ),
    );
  }
}

class _PlanTitleBlock extends StatelessWidget {
  final String nombre;
  final String descripcion;

  const _PlanTitleBlock({
    required this.nombre,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          descripcion,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(0.56),
            fontSize: 12.5,
            height: 1.25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;

  const _BenefitRow({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF22C55E),
          size: 17,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ChipInfo({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 210),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.50), size: 17),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.62),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.11),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _PremiumBottomSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color glowColor;
  final Widget child;

  const _PremiumBottomSheet({
    required this.title,
    required this.icon,
    required this.glowColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 20),
              _GlowIcon(icon: icon, glowColor: glowColor),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              child,
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: glowColor,
                    foregroundColor: glowColor == const Color(0xFFFACC15)
                        ? Colors.black
                        : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text(
                    'Entendido',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
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

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.manage_search_rounded,
            color: Color(0xFFFACC15),
            size: 52,
          ),
          const SizedBox(height: 12),
          const Text(
            'No hay planes para mostrar',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Intenta cambiar el filtro o la búsqueda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontWeight: FontWeight.w600,
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
          BoxShadow(color: glowColor.withOpacity(0.22), blurRadius: 22),
        ],
      ),
      child: Icon(icon, color: glowColor, size: 27),
    );
  }
}

class _MovingParticlesPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _MovingParticlesPainter({required this.progress})
      : particles = List.generate(80, (index) {
          final random = Random(index * 851);
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

        if ((o1 - o2).distance < 100) {
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

class _PlanMock {
  final String nombre;
  final String descripcion;
  final double precio;
  final String duracion;
  final String estado;
  final int profesionales;
  final List<String> beneficios;

  const _PlanMock({
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.duracion,
    required this.estado,
    required this.profesionales,
    required this.beneficios,
  });
}