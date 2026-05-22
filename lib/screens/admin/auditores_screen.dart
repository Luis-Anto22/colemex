import 'dart:math';

import 'package:flutter/material.dart';

class AuditoresScreen extends StatefulWidget {
  const AuditoresScreen({super.key});

  @override
  State<AuditoresScreen> createState() => _AuditoresScreenState();
}

class _AuditoresScreenState extends State<AuditoresScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;

  final TextEditingController _searchController = TextEditingController();

  String _filtroEstado = 'Todos';

  final List<_AuditorMock> _auditores = const [
    _AuditorMock(
      nombre: 'Mariana López',
      correo: 'mariana.auditor@colemex.com',
      telefono: '55 1234 5678',
      estado: 'Activo',
      verificaciones: 18,
      pendientes: 4,
      ultimaRevision: 'Hoy, 10:30 AM',
    ),
    _AuditorMock(
      nombre: 'Roberto Sánchez',
      correo: 'roberto.auditor@colemex.com',
      telefono: '55 2233 8899',
      estado: 'Activo',
      verificaciones: 31,
      pendientes: 2,
      ultimaRevision: 'Ayer, 6:15 PM',
    ),
    _AuditorMock(
      nombre: 'Karla Méndez',
      correo: 'karla.auditor@colemex.com',
      telefono: '55 7788 9911',
      estado: 'Inactivo',
      verificaciones: 9,
      pendientes: 0,
      ultimaRevision: 'Hace 5 días',
    ),
    _AuditorMock(
      nombre: 'Fernando Ruiz',
      correo: 'fernando.auditor@colemex.com',
      telefono: '55 3311 2244',
      estado: 'Activo',
      verificaciones: 14,
      pendientes: 7,
      ultimaRevision: 'Hoy, 8:45 AM',
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

  List<_AuditorMock> get _auditoresFiltrados {
    final query = _searchController.text.trim().toLowerCase();

    return _auditores.where((auditor) {
      final coincideBusqueda = auditor.nombre.toLowerCase().contains(query) ||
          auditor.correo.toLowerCase().contains(query) ||
          auditor.telefono.toLowerCase().contains(query);

      final coincideEstado =
          _filtroEstado == 'Todos' || auditor.estado == _filtroEstado;

      return coincideBusqueda && coincideEstado;
    }).toList();
  }

  int get _totalActivos =>
      _auditores.where((auditor) => auditor.estado == 'Activo').length;

  int get _totalPendientes =>
      _auditores.fold(0, (sum, auditor) => sum + auditor.pendientes);

  int get _totalVerificaciones =>
      _auditores.fold(0, (sum, auditor) => sum + auditor.verificaciones);

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 900;
    final auditoresFiltrados = _auditoresFiltrados;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.90),
        foregroundColor: Colors.white,
        title: const Text(
          'Auditores',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Crear auditor',
            onPressed: _mostrarCrearAuditorMock,
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFA855F7),
        foregroundColor: Colors.white,
        elevation: 10,
        onPressed: _mostrarCrearAuditorMock,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'Nuevo auditor',
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
                    const Color(0xFFA855F7).withOpacity(0.25),
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
                  _HeaderAuditores(
                    total: _auditores.length,
                    activos: _totalActivos,
                    pendientes: _totalPendientes,
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle(
                    title: 'Resumen de auditoría',
                    subtitle:
                        'Control visual de auditores y revisiones profesionales.',
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _MetricCard(
                        title: 'Auditores',
                        value: _auditores.length.toString(),
                        subtitle: 'Registrados',
                        icon: Icons.verified_user_rounded,
                        glowColor: const Color(0xFFA855F7),
                      ),
                      _MetricCard(
                        title: 'Activos',
                        value: _totalActivos.toString(),
                        subtitle: 'Con acceso permitido',
                        icon: Icons.check_circle_rounded,
                        glowColor: const Color(0xFF22C55E),
                      ),
                      _MetricCard(
                        title: 'Pendientes',
                        value: _totalPendientes.toString(),
                        subtitle: 'Documentos por revisar',
                        icon: Icons.pending_actions_rounded,
                        glowColor: const Color(0xFFFACC15),
                      ),
                      _MetricCard(
                        title: 'Verificaciones',
                        value: _totalVerificaciones.toString(),
                        subtitle: 'Aprobadas históricamente',
                        icon: Icons.fact_check_rounded,
                        glowColor: const Color(0xFF38BDF8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const _SectionTitle(
                    title: 'Lista de auditores',
                    subtitle: 'Datos visuales por ahora; API después.',
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
                  if (auditoresFiltrados.isEmpty)
                    const _EmptyPanel()
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: auditoresFiltrados.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 2 : 1,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: isWide ? 2.18 : 1.55,
                      ),
                      itemBuilder: (_, index) {
                        final auditor = auditoresFiltrados[index];

                        return _AuditorCard(
                          auditor: auditor,
                          onTap: () => _mostrarDetalleAuditor(auditor),
                          onEditar: () => _mostrarAccionMock(
                            'Editar auditor',
                            'Más adelante conectaremos esta acción a la API para editar los datos del auditor.',
                          ),
                          onDesactivar: () => _mostrarAccionMock(
                            auditor.estado == 'Activo'
                                ? 'Desactivar auditor'
                                : 'Activar auditor',
                            'Por ahora es solo visual. Después cambiaremos el campo activo en la tabla auditores.',
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

  void _mostrarCrearAuditorMock() {
    _mostrarAccionMock(
      'Crear auditor',
      'Aquí después abriremos un formulario real para registrar auditores en la tabla auditores.',
    );
  }

  void _mostrarDetalleAuditor(_AuditorMock auditor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _PremiumBottomSheet(
          title: auditor.nombre,
          icon: Icons.verified_user_rounded,
          glowColor: const Color(0xFFA855F7),
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.email_rounded,
                title: 'Correo',
                value: auditor.correo,
                color: const Color(0xFF38BDF8),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.phone_rounded,
                title: 'Teléfono',
                value: auditor.telefono,
                color: const Color(0xFF22C55E),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.fact_check_rounded,
                title: 'Verificaciones',
                value: '${auditor.verificaciones} aprobadas',
                color: const Color(0xFFA855F7),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.pending_actions_rounded,
                title: 'Pendientes',
                value: '${auditor.pendientes} documentos pendientes',
                color: const Color(0xFFFACC15),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.schedule_rounded,
                title: 'Última revisión',
                value: auditor.ultimaRevision,
                color: const Color(0xFFF97316),
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
              color: Colors.white.withOpacity(0.70),
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }
}

class _HeaderAuditores extends StatelessWidget {
  final int total;
  final int activos;
  final int pendientes;

  const _HeaderAuditores({
    required this.total,
    required this.activos,
    required this.pendientes,
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
            color: const Color(0xFFA855F7).withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                _HeaderIcon(),
                const SizedBox(width: 18),
                const Expanded(child: _HeaderText()),
                const SizedBox(width: 18),
                _HeaderCounters(
                  total: total,
                  activos: activos,
                  pendientes: pendientes,
                ),
              ],
            )
          : Column(
              children: [
                _HeaderIcon(),
                const SizedBox(height: 16),
                const _HeaderText(),
                const SizedBox(height: 16),
                _HeaderCounters(
                  total: total,
                  activos: activos,
                  pendientes: pendientes,
                ),
              ],
            ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFA855F7),
            Color(0xFF7C3AED),
            Color(0xFF4C1D95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withOpacity(0.35),
            blurRadius: 28,
          ),
        ],
      ),
      child: const Icon(
        Icons.verified_user_rounded,
        color: Colors.white,
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
          'Gestión de auditores',
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
          'Los auditores revisarán documentos y verificarán profesionales.',
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
  final int pendientes;

  const _HeaderCounters({
    required this.total,
    required this.activos,
    required this.pendientes,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _SmallCounter(
          label: 'Total',
          value: total.toString(),
          icon: Icons.groups_rounded,
          color: const Color(0xFFA855F7),
        ),
        _SmallCounter(
          label: 'Activos',
          value: activos.toString(),
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF22C55E),
        ),
        _SmallCounter(
          label: 'Pendientes',
          value: pendientes.toString(),
          icon: Icons.pending_rounded,
          color: const Color(0xFFFACC15),
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
      width: 118,
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
                Color(0xFFA855F7),
                Color(0xFF7C3AED),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA855F7).withOpacity(0.4),
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
              height: 1.25,
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
      cursorColor: const Color(0xFFA855F7),
      decoration: InputDecoration(
        hintText: 'Buscar auditor por nombre, correo o teléfono...',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.42),
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFFA855F7),
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
            color: Color(0xFFA855F7),
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
      iconEnabledColor: const Color(0xFFA855F7),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.tune_rounded,
          color: Color(0xFFA855F7),
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

class _AuditorCard extends StatelessWidget {
  final _AuditorMock auditor;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onDesactivar;

  const _AuditorCard({
    required this.auditor,
    required this.onTap,
    required this.onEditar,
    required this.onDesactivar,
  });

  @override
  Widget build(BuildContext context) {
    final bool activo = auditor.estado == 'Activo';
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
                color: const Color(0xFFA855F7).withOpacity(0.11),
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
                  _AuditorAvatar(nombre: auditor.nombre),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AuditorName(
                      nombre: auditor.nombre,
                      correo: auditor.correo,
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
                      if (value == 'estado') onDesactivar();
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
                    icon: activo
                        ? Icons.check_circle_rounded
                        : Icons.pause_circle_rounded,
                    label: auditor.estado,
                    color: estadoColor,
                  ),
                  _ChipInfo(
                    icon: Icons.fact_check_rounded,
                    label: '${auditor.verificaciones} verificaciones',
                    color: const Color(0xFFA855F7),
                  ),
                  _ChipInfo(
                    icon: Icons.pending_actions_rounded,
                    label: '${auditor.pendientes} pendientes',
                    color: const Color(0xFFFACC15),
                  ),
                ],
              ),
              const Spacer(),
              Divider(color: Colors.white.withOpacity(0.10), height: 22),
              Row(
                children: [
                  Expanded(
                    child: _MiniInfo(
                      icon: Icons.schedule_rounded,
                      text: auditor.ultimaRevision,
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
                    onTap: onDesactivar,
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

class _AuditorAvatar extends StatelessWidget {
  final String nombre;

  const _AuditorAvatar({
    required this.nombre,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = nombre.trim().isEmpty ? '?' : nombre.trim()[0].toUpperCase();

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFA855F7).withOpacity(0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withOpacity(0.30),
            blurRadius: 18,
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: const Color(0xFFA855F7).withOpacity(0.15),
        child: Text(
          inicial,
          style: const TextStyle(
            color: Color(0xFFA855F7),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _AuditorName extends StatelessWidget {
  final String nombre;
  final String correo;

  const _AuditorName({
    required this.nombre,
    required this.correo,
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
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          correo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(0.56),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
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
        Icon(
          icon,
          color: Colors.white.withOpacity(0.50),
          size: 17,
        ),
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
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
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
                  foregroundColor: Colors.white,
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
            color: Color(0xFFA855F7),
            size: 52,
          ),
          const SizedBox(height: 12),
          const Text(
            'No hay auditores para mostrar',
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

class _MovingParticlesPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _MovingParticlesPainter({required this.progress})
      : particles = List.generate(80, (index) {
          final random = Random(index * 831);
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

class _AuditorMock {
  final String nombre;
  final String correo;
  final String telefono;
  final String estado;
  final int verificaciones;
  final int pendientes;
  final String ultimaRevision;

  const _AuditorMock({
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.estado,
    required this.verificaciones,
    required this.pendientes,
    required this.ultimaRevision,
  });
}