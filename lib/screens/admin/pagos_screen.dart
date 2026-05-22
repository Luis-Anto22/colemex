import 'dart:math';

import 'package:flutter/material.dart';

class PagosScreen extends StatefulWidget {
  const PagosScreen({super.key});

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;
  final TextEditingController _searchController = TextEditingController();

  String _filtroEstado = 'Todos';

  final List<_PagoMock> _pagos = const [
    _PagoMock(
      profesional: 'Luis Hernández',
      correo: 'luis.abogado@correo.com',
      perfil: 'Abogados',
      plan: 'Plan Profesional',
      monto: 599,
      estado: 'Pagado',
      metodo: 'Google Play Billing',
      referencia: 'GPA.3391-8842-1120',
      fecha: 'Hoy, 09:15 AM',
    ),
    _PagoMock(
      profesional: 'Ana Martínez',
      correo: 'ana.valuador@correo.com',
      perfil: 'Valuadores',
      plan: 'Plan Premium',
      monto: 999,
      estado: 'Pendiente',
      metodo: 'Google Play Billing',
      referencia: 'Pendiente de confirmación',
      fecha: 'Hoy, 11:40 AM',
    ),
    _PagoMock(
      profesional: 'Carlos Méndez',
      correo: 'carlos.investigador@correo.com',
      perfil: 'Investigadores',
      plan: 'Plan Básico',
      monto: 299,
      estado: 'Fallido',
      metodo: 'Google Play Billing',
      referencia: 'Pago rechazado',
      fecha: 'Ayer, 07:10 PM',
    ),
    _PagoMock(
      profesional: 'Fernanda Ruiz',
      correo: 'fernanda.psicologa@correo.com',
      perfil: 'Psicólogos',
      plan: 'Plan Profesional',
      monto: 599,
      estado: 'Reembolsado',
      metodo: 'Google Play Billing',
      referencia: 'REF-998123',
      fecha: 'Hace 3 días',
    ),
    _PagoMock(
      profesional: 'Roberto Salinas',
      correo: 'roberto.contador@correo.com',
      perfil: 'Contadores',
      plan: 'Plan Premium',
      monto: 999,
      estado: 'Pagado',
      metodo: 'Google Play Billing',
      referencia: 'GPA.9931-0012-4478',
      fecha: 'Hace 4 días',
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

  List<_PagoMock> get _pagosFiltrados {
    final query = _searchController.text.trim().toLowerCase();

    return _pagos.where((pago) {
      final coincideBusqueda = pago.profesional.toLowerCase().contains(query) ||
          pago.correo.toLowerCase().contains(query) ||
          pago.perfil.toLowerCase().contains(query) ||
          pago.plan.toLowerCase().contains(query) ||
          pago.referencia.toLowerCase().contains(query);

      final coincideEstado =
          _filtroEstado == 'Todos' || pago.estado == _filtroEstado;

      return coincideBusqueda && coincideEstado;
    }).toList();
  }

  int get _pagados => _pagos.where((p) => p.estado == 'Pagado').length;

  int get _pendientes => _pagos.where((p) => p.estado == 'Pendiente').length;

  int get _fallidos => _pagos.where((p) => p.estado == 'Fallido').length;

  double get _ingresosConfirmados => _pagos
      .where((p) => p.estado == 'Pagado')
      .fold(0, (sum, p) => sum + p.monto);

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 900;
    final pagosFiltrados = _pagosFiltrados;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.90),
        foregroundColor: Colors.white,
        title: const Text(
          'Pagos',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => _mostrarAccionMock(
              'Actualizar pagos',
              'Después aquí consultaremos los pagos reales desde la API y Google Play Billing.',
            ),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
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
                    const Color(0xFFF97316).withOpacity(0.24),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderPagos(
                    ingresos: _ingresosConfirmados,
                    pagados: _pagados,
                    pendientes: _pendientes,
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle(
                    title: 'Resumen de pagos',
                    subtitle:
                        'Vista visual para preparar el flujo de pagos con Play Store.',
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _MetricCard(
                        title: 'Ingresos',
                        value: '\$${_ingresosConfirmados.toStringAsFixed(0)}',
                        subtitle: 'Pagos confirmados',
                        icon: Icons.payments_rounded,
                        glowColor: const Color(0xFFF97316),
                      ),
                      _MetricCard(
                        title: 'Pagados',
                        value: _pagados.toString(),
                        subtitle: 'Profesionales con pago',
                        icon: Icons.check_circle_rounded,
                        glowColor: const Color(0xFF22C55E),
                      ),
                      _MetricCard(
                        title: 'Pendientes',
                        value: _pendientes.toString(),
                        subtitle: 'Esperando confirmación',
                        icon: Icons.pending_actions_rounded,
                        glowColor: const Color(0xFFFACC15),
                      ),
                      _MetricCard(
                        title: 'Fallidos',
                        value: _fallidos.toString(),
                        subtitle: 'Pago rechazado',
                        icon: Icons.cancel_rounded,
                        glowColor: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const _SectionTitle(
                    title: 'Historial de pagos',
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
                  if (pagosFiltrados.isEmpty)
                    const _EmptyPanel()
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pagosFiltrados.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 2 : 1,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: isWide ? 2.05 : 1.42,
                      ),
                      itemBuilder: (_, index) {
                        final pago = pagosFiltrados[index];

                        return _PagoCard(
                          pago: pago,
                          onTap: () => _mostrarDetallePago(pago),
                          onValidar: () => _mostrarAccionMock(
                            'Validar pago',
                            'Después esta acción verificará el token/compra de Google Play Billing y actualizará pagos_profesionales.',
                          ),
                          onReembolso: () => _mostrarAccionMock(
                            'Reembolso',
                            'Después aquí mostraremos el estado de reembolso o cancelación del pago.',
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

  void _mostrarDetallePago(_PagoMock pago) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _PremiumBottomSheet(
          title: pago.profesional,
          icon: Icons.receipt_long_rounded,
          glowColor: _estadoColor(pago.estado),
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.email_rounded,
                title: 'Correo',
                value: pago.correo,
                color: const Color(0xFF38BDF8),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.work_rounded,
                title: 'Perfil',
                value: pago.perfil,
                color: const Color(0xFFA855F7),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.workspace_premium_rounded,
                title: 'Plan',
                value: pago.plan,
                color: const Color(0xFFFACC15),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.payments_rounded,
                title: 'Monto',
                value: '\$${pago.monto.toStringAsFixed(2)} MXN',
                color: const Color(0xFFF97316),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.receipt_rounded,
                title: 'Referencia',
                value: pago.referencia,
                color: const Color(0xFF22C55E),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.calendar_month_rounded,
                title: 'Fecha',
                value: pago.fecha,
                color: const Color(0xFF06B6D4),
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

class _HeaderPagos extends StatelessWidget {
  final double ingresos;
  final int pagados;
  final int pendientes;

  const _HeaderPagos({
    required this.ingresos,
    required this.pagados,
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
            color: const Color(0xFFF97316).withOpacity(0.16),
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
                  ingresos: ingresos,
                  pagados: pagados,
                  pendientes: pendientes,
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
                  ingresos: ingresos,
                  pagados: pagados,
                  pendientes: pendientes,
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
            Color(0xFFF97316),
            Color(0xFFEA580C),
            Color(0xFF9A3412),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.30),
            blurRadius: 28,
          ),
        ],
      ),
      child: const Icon(
        Icons.payments_rounded,
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
          'Pagos profesionales',
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
          'Después del pago, el profesional podrá subir documentos para auditoría.',
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
  final double ingresos;
  final int pagados;
  final int pendientes;

  const _HeaderCounters({
    required this.ingresos,
    required this.pagados,
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
          label: 'Ingresos',
          value: '\$${ingresos.toStringAsFixed(0)}',
          icon: Icons.payments_rounded,
          color: const Color(0xFFF97316),
        ),
        _SmallCounter(
          label: 'Pagados',
          value: pagados.toString(),
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
                Color(0xFFF97316),
                Color(0xFFEA580C),
              ],
            ),
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF97316).withOpacity(0.35),
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
      cursorColor: const Color(0xFFF97316),
      decoration: InputDecoration(
        hintText: 'Buscar pago por profesional, plan, referencia o perfil...',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.42),
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFFF97316),
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
            color: Color(0xFFF97316),
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
      iconEnabledColor: const Color(0xFFF97316),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.tune_rounded,
          color: Color(0xFFF97316),
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
        DropdownMenuItem(value: 'Pagado', child: Text('Pagado')),
        DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
        DropdownMenuItem(value: 'Fallido', child: Text('Fallido')),
        DropdownMenuItem(value: 'Reembolsado', child: Text('Reembolsado')),
      ],
      onChanged: (value) {
        if (value != null) onFiltroChanged(value);
      },
    );
  }
}

class _PagoCard extends StatelessWidget {
  final _PagoMock pago;
  final VoidCallback onTap;
  final VoidCallback onValidar;
  final VoidCallback onReembolso;

  const _PagoCard({
    required this.pago,
    required this.onTap,
    required this.onValidar,
    required this.onReembolso,
  });

  @override
  Widget build(BuildContext context) {
    final color = _estadoColor(pago.estado);

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
                color: color.withOpacity(0.11),
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
                  _Avatar(nombre: pago.profesional, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NameBlock(
                      nombre: pago.profesional,
                      correo: pago.correo,
                    ),
                  ),
                  _EstadoBadge(estado: pago.estado, color: color),
                ],
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChipInfo(
                    icon: Icons.workspace_premium_rounded,
                    label: pago.plan,
                    color: const Color(0xFFFACC15),
                  ),
                  _ChipInfo(
                    icon: Icons.payments_rounded,
                    label: '\$${pago.monto.toStringAsFixed(0)} MXN',
                    color: const Color(0xFFF97316),
                  ),
                  _ChipInfo(
                    icon: Icons.work_rounded,
                    label: pago.perfil,
                    color: const Color(0xFFA855F7),
                  ),
                ],
              ),
              const Spacer(),
              Divider(color: Colors.white.withOpacity(0.10), height: 22),
              Row(
                children: [
                  Expanded(
                    child: _MiniInfo(
                      icon: Icons.receipt_long_rounded,
                      text: pago.referencia,
                    ),
                  ),
                  _ActionButton(
                    icon: Icons.verified_rounded,
                    color: const Color(0xFF22C55E),
                    onTap: onValidar,
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.currency_exchange_rounded,
                    color: const Color(0xFF38BDF8),
                    onTap: onReembolso,
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
  final String nombre;
  final Color color;

  const _Avatar({
    required this.nombre,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = nombre.trim().isEmpty ? '?' : nombre.trim()[0].toUpperCase();

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
  final String nombre;
  final String correo;

  const _NameBlock({
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
            color: Color(0xFFF97316),
            size: 52,
          ),
          const SizedBox(height: 12),
          const Text(
            'No hay pagos para mostrar',
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

  if (e.contains('pagado')) return const Color(0xFF22C55E);
  if (e.contains('pendiente')) return const Color(0xFFFACC15);
  if (e.contains('fallido')) return const Color(0xFFEF4444);
  if (e.contains('reembolsado')) return const Color(0xFF38BDF8);
  if (e.contains('cancelado')) return const Color(0xFF94A3B8);

  return const Color(0xFFF97316);
}

class _MovingParticlesPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _MovingParticlesPainter({required this.progress})
      : particles = List.generate(80, (index) {
          final random = Random(index * 861);
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

class _PagoMock {
  final String profesional;
  final String correo;
  final String perfil;
  final String plan;
  final double monto;
  final String estado;
  final String metodo;
  final String referencia;
  final String fecha;

  const _PagoMock({
    required this.profesional,
    required this.correo,
    required this.perfil,
    required this.plan,
    required this.monto,
    required this.estado,
    required this.metodo,
    required this.referencia,
    required this.fecha,
  });
}