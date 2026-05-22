import 'dart:math';

import 'package:flutter/material.dart';

class CasosAdminScreen extends StatefulWidget {
  const CasosAdminScreen({super.key});

  @override
  State<CasosAdminScreen> createState() => _CasosAdminScreenState();
}

class _CasosAdminScreenState extends State<CasosAdminScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;
  final TextEditingController _searchController = TextEditingController();

  String _filtroEstado = 'Todos';

  final List<_CasoMock> _casos = const [
    _CasoMock(
      titulo: 'Asesoría legal por contrato',
      cliente: 'Jorge Ramírez',
      profesional: 'Luis Hernández',
      perfil: 'Abogados',
      estado: 'Pendiente',
      prioridad: 'Alta',
      fecha: 'Hoy, 10:25 AM',
      descripcion:
          'Cliente solicita revisión de contrato mercantil y asesoría inicial.',
    ),
    _CasoMock(
      titulo: 'Avalúo de inmueble',
      cliente: 'María González',
      profesional: 'Ana Martínez',
      perfil: 'Valuadores',
      estado: 'En proceso',
      prioridad: 'Media',
      fecha: 'Ayer, 06:10 PM',
      descripcion:
          'Solicitud de avalúo para inmueble residencial ubicado en zona urbana.',
    ),
    _CasoMock(
      titulo: 'Investigación de siniestro',
      cliente: 'Carlos Rivera',
      profesional: 'Fernando Ruiz',
      perfil: 'Investigadores',
      estado: 'Asignado',
      prioridad: 'Alta',
      fecha: 'Hace 2 días',
      descripcion:
          'Investigación y recopilación de evidencia por incidente reportado.',
    ),
    _CasoMock(
      titulo: 'Sesión psicológica inicial',
      cliente: 'Fernanda Soto',
      profesional: 'Laura Méndez',
      perfil: 'Psicólogos',
      estado: 'Finalizado',
      prioridad: 'Baja',
      fecha: 'Hace 4 días',
      descripcion:
          'Primera sesión de orientación psicológica registrada como finalizada.',
    ),
    _CasoMock(
      titulo: 'Asistencia vial por falla mecánica',
      cliente: 'Roberto Salinas',
      profesional: 'Grúas Central MX',
      perfil: 'Asistencia vial',
      estado: 'Cancelado',
      prioridad: 'Media',
      fecha: 'Hace 5 días',
      descripcion:
          'Servicio cancelado por el cliente antes de la llegada del profesional.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_CasoMock> get _casosFiltrados {
    final query = _searchController.text.trim().toLowerCase();

    return _casos.where((caso) {
      final coincideBusqueda = caso.titulo.toLowerCase().contains(query) ||
          caso.cliente.toLowerCase().contains(query) ||
          caso.profesional.toLowerCase().contains(query) ||
          caso.perfil.toLowerCase().contains(query) ||
          caso.descripcion.toLowerCase().contains(query);

      final coincideEstado =
          _filtroEstado == 'Todos' || caso.estado == _filtroEstado;

      return coincideBusqueda && coincideEstado;
    }).toList();
  }

  int get _pendientes => _casos.where((c) => c.estado == 'Pendiente').length;

  int get _enProceso => _casos
      .where((c) => c.estado == 'En proceso' || c.estado == 'Asignado')
      .length;

  int get _finalizados => _casos.where((c) => c.estado == 'Finalizado').length;


  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 900;
    final casosFiltrados = _casosFiltrados;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.90),
        foregroundColor: Colors.white,
        title: const Text(
          'Casos',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => _mostrarAccionMock(
              'Actualizar casos',
              'Después aquí consultaremos casos reales desde la API.',
            ),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFEF4444),
        foregroundColor: Colors.white,
        elevation: 10,
        onPressed: () => _mostrarAccionMock(
          'Nuevo caso',
          'Después aquí podremos crear o asignar casos manualmente desde el panel admin.',
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nuevo caso',
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
                    const Color(0xFFEF4444).withOpacity(0.23),
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
                  _HeaderCasos(
                    total: _casos.length,
                    pendientes: _pendientes,
                    enProceso: _enProceso,
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle(
                    title: 'Resumen de casos',
                    subtitle:
                        'Vista visual para controlar solicitudes, asignaciones y estados.',
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _MetricCard(
                        title: 'Total',
                        value: _casos.length.toString(),
                        subtitle: 'Casos registrados',
                        icon: Icons.folder_copy_rounded,
                        glowColor: const Color(0xFFEF4444),
                      ),
                      _MetricCard(
                        title: 'Pendientes',
                        value: _pendientes.toString(),
                        subtitle: 'Sin iniciar',
                        icon: Icons.pending_actions_rounded,
                        glowColor: const Color(0xFFFACC15),
                      ),
                      _MetricCard(
                        title: 'En proceso',
                        value: _enProceso.toString(),
                        subtitle: 'Asignados o activos',
                        icon: Icons.sync_rounded,
                        glowColor: const Color(0xFF38BDF8),
                      ),
                      _MetricCard(
                        title: 'Finalizados',
                        value: _finalizados.toString(),
                        subtitle: 'Cerrados correctamente',
                        icon: Icons.check_circle_rounded,
                        glowColor: const Color(0xFF22C55E),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const _SectionTitle(
                    title: 'Lista de casos',
                    subtitle: 'Datos mock por ahora; conexión real después.',
                  ),
                  const SizedBox(height: 14),
                  _SearchFilterPanel(
                    controller: _searchController,
                    filtroEstado: _filtroEstado,
                    onFiltroChanged: (value) {
                      setState(() => _filtroEstado = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (casosFiltrados.isEmpty)
                    const _EmptyPanel()
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: casosFiltrados.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 2 : 1,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: isWide ? 1.95 : 1.36,
                      ),
                      itemBuilder: (_, index) {
                        final caso = casosFiltrados[index];

                        return _CasoCard(
                          caso: caso,
                          onTap: () => _mostrarDetalleCaso(caso),
                          onAsignar: () => _mostrarAccionMock(
                            'Asignar profesional',
                            'Después aquí podremos reasignar el profesional responsable del caso.',
                          ),
                          onEstado: () => _mostrarAccionMock(
                            'Cambiar estado',
                            'Después aquí podremos cambiar el estado real del caso en la base de datos.',
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

  void _mostrarDetalleCaso(_CasoMock caso) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _PremiumBottomSheet(
          title: caso.titulo,
          icon: Icons.folder_open_rounded,
          glowColor: _estadoColor(caso.estado),
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.person_rounded,
                title: 'Cliente',
                value: caso.cliente,
                color: const Color(0xFF38BDF8),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.badge_rounded,
                title: 'Profesional asignado',
                value: caso.profesional,
                color: const Color(0xFFA855F7),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.work_rounded,
                title: 'Perfil',
                value: caso.perfil,
                color: const Color(0xFFFACC15),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.flag_rounded,
                title: 'Prioridad',
                value: caso.prioridad,
                color: _prioridadColor(caso.prioridad),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.calendar_month_rounded,
                title: 'Fecha',
                value: caso.fecha,
                color: const Color(0xFF06B6D4),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.description_rounded,
                title: 'Descripción',
                value: caso.descripcion,
                color: const Color(0xFF22C55E),
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

class _HeaderCasos extends StatelessWidget {
  final int total;
  final int pendientes;
  final int enProceso;

  const _HeaderCasos({
    required this.total,
    required this.pendientes,
    required this.enProceso,
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
            color: const Color(0xFFEF4444).withOpacity(0.16),
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
                  pendientes: pendientes,
                  enProceso: enProceso,
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
                  pendientes: pendientes,
                  enProceso: enProceso,
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
            Color(0xFFEF4444),
            Color(0xFFDC2626),
            Color(0xFF7F1D1D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.30),
            blurRadius: 28,
          ),
        ],
      ),
      child: const Icon(
        Icons.folder_copy_rounded,
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
          'Control de casos',
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
          'Administra solicitudes, asignaciones, estados y seguimiento operativo.',
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
  final int pendientes;
  final int enProceso;

  const _HeaderCounters({
    required this.total,
    required this.pendientes,
    required this.enProceso,
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
          icon: Icons.folder_rounded,
          color: const Color(0xFFEF4444),
        ),
        _SmallCounter(
          label: 'Pendientes',
          value: pendientes.toString(),
          icon: Icons.pending_rounded,
          color: const Color(0xFFFACC15),
        ),
        _SmallCounter(
          label: 'Activos',
          value: enProceso.toString(),
          icon: Icons.sync_rounded,
          color: const Color(0xFF38BDF8),
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
                Color(0xFFEF4444),
                Color(0xFFDC2626),
              ],
            ),
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(0.35),
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
                SizedBox(width: 235, child: _buildDropdown()),
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
      cursorColor: const Color(0xFFEF4444),
      decoration: InputDecoration(
        hintText: 'Buscar caso por cliente, profesional, perfil o descripción...',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.42),
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFFEF4444),
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
            color: Color(0xFFEF4444),
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
      iconEnabledColor: const Color(0xFFEF4444),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.tune_rounded,
          color: Color(0xFFEF4444),
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
        DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
        DropdownMenuItem(value: 'Asignado', child: Text('Asignado')),
        DropdownMenuItem(value: 'En proceso', child: Text('En proceso')),
        DropdownMenuItem(value: 'Finalizado', child: Text('Finalizado')),
        DropdownMenuItem(value: 'Cancelado', child: Text('Cancelado')),
      ],
      onChanged: (value) {
        if (value != null) onFiltroChanged(value);
      },
    );
  }
}

class _CasoCard extends StatelessWidget {
  final _CasoMock caso;
  final VoidCallback onTap;
  final VoidCallback onAsignar;
  final VoidCallback onEstado;

  const _CasoCard({
    required this.caso,
    required this.onTap,
    required this.onAsignar,
    required this.onEstado,
  });

  @override
  Widget build(BuildContext context) {
    final estadoColor = _estadoColor(caso.estado);
    final prioridadColor = _prioridadColor(caso.prioridad);

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
                color: estadoColor.withOpacity(0.11),
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
                  _Avatar(text: caso.cliente, color: estadoColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NameBlock(
                      title: caso.titulo,
                      subtitle: caso.cliente,
                    ),
                  ),
                  _EstadoBadge(estado: caso.estado, color: estadoColor),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                caso.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.58),
                  height: 1.35,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChipInfo(
                    icon: Icons.badge_rounded,
                    label: caso.profesional,
                    color: const Color(0xFFA855F7),
                  ),
                  _ChipInfo(
                    icon: Icons.work_rounded,
                    label: caso.perfil,
                    color: const Color(0xFF38BDF8),
                  ),
                  _ChipInfo(
                    icon: Icons.flag_rounded,
                    label: caso.prioridad,
                    color: prioridadColor,
                  ),
                ],
              ),
              const Spacer(),
              Divider(color: Colors.white.withOpacity(0.10), height: 22),
              Row(
                children: [
                  Expanded(
                    child: _MiniInfo(
                      icon: Icons.calendar_month_rounded,
                      text: caso.fecha,
                    ),
                  ),
                  _ActionButton(
                    icon: Icons.person_add_alt_1_rounded,
                    color: const Color(0xFF38BDF8),
                    onTap: onAsignar,
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.edit_rounded,
                    color: const Color(0xFFFACC15),
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

class _EstadoBadge extends StatelessWidget {
  final String estado;
  final Color color;

  const _EstadoBadge({
    required this.estado,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String text;
  final Color color;

  const _Avatar({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = text.trim().isEmpty ? '?' : text.trim()[0].toUpperCase();

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.65), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.30), blurRadius: 18),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Text(
          inicial,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _NameBlock extends StatelessWidget {
  final String title;
  final String subtitle;

  const _NameBlock({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
          subtitle,
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
      constraints: const BoxConstraints(maxWidth: 220),
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
            color: Color(0xFFEF4444),
            size: 52,
          ),
          const SizedBox(height: 12),
          const Text(
            'No hay casos para mostrar',
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

Color _estadoColor(String estado) {
  final e = estado.toLowerCase();

  if (e.contains('pendiente')) return const Color(0xFFFACC15);
  if (e.contains('asignado')) return const Color(0xFF38BDF8);
  if (e.contains('proceso')) return const Color(0xFFF97316);
  if (e.contains('finalizado')) return const Color(0xFF22C55E);
  if (e.contains('cancelado')) return const Color(0xFF94A3B8);

  return const Color(0xFFEF4444);
}

Color _prioridadColor(String prioridad) {
  final p = prioridad.toLowerCase();

  if (p.contains('alta')) return const Color(0xFFEF4444);
  if (p.contains('media')) return const Color(0xFFFACC15);
  if (p.contains('baja')) return const Color(0xFF22C55E);

  return const Color(0xFF94A3B8);
}

class _MovingParticlesPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _MovingParticlesPainter({required this.progress})
      : particles = List.generate(80, (index) {
          final random = Random(index * 871);
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

class _CasoMock {
  final String titulo;
  final String cliente;
  final String profesional;
  final String perfil;
  final String estado;
  final String prioridad;
  final String fecha;
  final String descripcion;

  const _CasoMock({
    required this.titulo,
    required this.cliente,
    required this.profesional,
    required this.perfil,
    required this.estado,
    required this.prioridad,
    required this.fecha,
    required this.descripcion,
  });
}