import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'api_service_profesionales.dart';

class EstadisticasGeneralScreen extends StatefulWidget {
  const EstadisticasGeneralScreen({super.key});

  @override
  State<EstadisticasGeneralScreen> createState() =>
      _EstadisticasGeneralScreenState();
}

class _EstadisticasGeneralScreenState extends State<EstadisticasGeneralScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;

  Map<String, dynamic>? _datos;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _cargarEstadisticas();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _cargarEstadisticas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiServiceProfesionales.obtenerEstadisticasAdmin();

      if (!mounted) return;

      setState(() {
        _datos = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  int get _totalProfesionales => _asInt(_datos?['profesionales_total']);
  int get _profesionalesVerificados =>
      _asInt(_datos?['profesionales_verificados']);
  int get _profesionalesNoVerificados =>
      _asInt(_datos?['profesionales_no_verificados']);

  int get _totalClientes => _asInt(_datos?['clientes_total']);
  int get _totalCasos => _asInt(_datos?['casos_total']);
  int get _totalAuditores => _asInt(_datos?['auditores_total']);

  int get _casosPendientes => _asInt(_datos?['casos_pendientes']);
  int get _casosEnProceso => _asInt(_datos?['casos_en_proceso']);
  int get _casosFinalizados => _asInt(_datos?['casos_finalizados']);
  int get _casosCancelados => _asInt(_datos?['casos_cancelados']);

  int get _pagosConfirmados => _asInt(_datos?['pagos_confirmados']);
  int get _documentosSubidos => _asInt(_datos?['documentos_subidos']);
  int get _notificacionesAdmin =>
      _asInt(_datos?['notificaciones_admin_total']);

  int get _casosActivos => _casosPendientes + _casosEnProceso;

  Map<String, int> get _casosPorEstado {
    final result = <String, int>{};

    final raw = _datos?['casos_por_estado'];

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final estado = item['estado']?.toString() ?? 'Sin estado';
          final total = _asInt(item['total']);
          if (estado.trim().isNotEmpty) {
            result[estado] = total;
          }
        }
      }
    }

    if (result.isEmpty) {
      if (_casosPendientes > 0) result['Pendientes'] = _casosPendientes;
      if (_casosEnProceso > 0) result['En proceso'] = _casosEnProceso;
      if (_casosFinalizados > 0) result['Finalizados'] = _casosFinalizados;
      if (_casosCancelados > 0) result['Cancelados'] = _casosCancelados;
    }

    return result;
  }

  Map<String, int> get _profesionalesPorPerfil {
    final result = <String, int>{};

    final raw = _datos?['profesionales_por_perfil'];

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final perfil = item['perfil']?.toString() ?? 'Sin perfil';
          final total = _asInt(item['total']);
          if (perfil.trim().isNotEmpty) {
            result[perfil] = total;
          }
        }
      }
    }

    return result;
  }

  int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.90),
        foregroundColor: Colors.white,
        title: const Text(
          'Estadísticas generales',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _isLoading ? null : _cargarEstadisticas,
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
                    const Color(0xFF1E3A8A).withOpacity(0.32),
                    const Color(0xFF020617).withOpacity(0.92),
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
              onRefresh: _cargarEstadisticas,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  isWide ? 24 : 16,
                  16,
                  isWide ? 24 : 16,
                  28,
                ),
                child: _buildContent(isWide),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isWide) {
    if (_isLoading) {
      return const _LoadingPanel();
    }

    if (_error != null) {
      return _ErrorPanel(
        error: _error!,
        onRetry: _cargarEstadisticas,
      );
    }

    final casosPorEstado = _casosPorEstado;
    final profesionalesPorPerfil = _profesionalesPorPerfil;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderEstadisticas(
          totalProfesionales: _totalProfesionales,
          totalClientes: _totalClientes,
          totalCasos: _totalCasos,
        ),
        const SizedBox(height: 22),
        const _SectionTitle(
          title: 'Indicadores principales',
          subtitle: 'Resumen operativo real de la plataforma',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _MetricCard(
              title: 'Profesionales',
              value: _totalProfesionales.toString(),
              subtitle: 'Registrados en sistema',
              icon: Icons.badge_rounded,
              glowColor: const Color(0xFF38BDF8),
            ),
            _MetricCard(
              title: 'Clientes',
              value: _totalClientes.toString(),
              subtitle: 'Usuarios registrados',
              icon: Icons.people_alt_rounded,
              glowColor: const Color(0xFF22C55E),
            ),
            _MetricCard(
              title: 'Casos totales',
              value: _totalCasos.toString(),
              subtitle: 'Solicitudes creadas',
              icon: Icons.folder_copy_rounded,
              glowColor: const Color(0xFFA855F7),
            ),
            _MetricCard(
              title: 'Casos activos',
              value: _casosActivos.toString(),
              subtitle: 'Pendientes o en proceso',
              icon: Icons.pending_actions_rounded,
              glowColor: const Color(0xFFF97316),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const _SectionTitle(
          title: 'Verificación y operación',
          subtitle: 'Control de profesionales, pagos, documentos y auditoría',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _MetricCard(
              title: 'Verificados',
              value: _profesionalesVerificados.toString(),
              subtitle: 'Profesionales aprobados',
              icon: Icons.verified_rounded,
              glowColor: const Color(0xFF22C55E),
            ),
            _MetricCard(
              title: 'No verificados',
              value: _profesionalesNoVerificados.toString(),
              subtitle: 'Pendientes de revisión',
              icon: Icons.warning_rounded,
              glowColor: const Color(0xFFFACC15),
            ),
            _MetricCard(
              title: 'Pagos confirmados',
              value: _pagosConfirmados.toString(),
              subtitle: 'Profesionales con pago',
              icon: Icons.payments_rounded,
              glowColor: const Color(0xFF14B8A6),
            ),
            _MetricCard(
              title: 'Documentos',
              value: _documentosSubidos.toString(),
              subtitle: 'Profesionales con documentos',
              icon: Icons.upload_file_rounded,
              glowColor: const Color(0xFF6366F1),
            ),
            _MetricCard(
              title: 'Auditores',
              value: _totalAuditores.toString(),
              subtitle: 'Usuarios de revisión',
              icon: Icons.admin_panel_settings_rounded,
              glowColor: const Color(0xFFEC4899),
            ),
            _MetricCard(
              title: 'Push admin',
              value: _notificacionesAdmin.toString(),
              subtitle: 'Notificaciones enviadas/registradas',
              icon: Icons.notifications_active_rounded,
              glowColor: const Color(0xFF06B6D4),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const _SectionTitle(
          title: 'Análisis de casos',
          subtitle: 'Distribución y volumen por estado',
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 900;

            if (twoColumns) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _BarChartPanel(
                      title: 'Casos por estado',
                      icon: Icons.bar_chart_rounded,
                      glowColor: const Color(0xFF38BDF8),
                      data: casosPorEstado,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _PieChartPanel(
                      title: 'Distribución de casos',
                      icon: Icons.pie_chart_rounded,
                      glowColor: const Color(0xFFA855F7),
                      data: casosPorEstado,
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _BarChartPanel(
                  title: 'Casos por estado',
                  icon: Icons.bar_chart_rounded,
                  glowColor: const Color(0xFF38BDF8),
                  data: casosPorEstado,
                ),
                const SizedBox(height: 16),
                _PieChartPanel(
                  title: 'Distribución de casos',
                  icon: Icons.pie_chart_rounded,
                  glowColor: const Color(0xFFA855F7),
                  data: casosPorEstado,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        _EstadoPanel(
          title: 'Detalle de casos',
          icon: Icons.list_alt_rounded,
          glowColor: const Color(0xFF22C55E),
          data: casosPorEstado,
          emptyText: 'No hay estados de casos registrados todavía.',
        ),
        const SizedBox(height: 26),
        const _SectionTitle(
          title: 'Profesionales por perfil',
          subtitle: 'Distribución de perfiles registrados',
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 900;

            if (twoColumns) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _BarChartPanel(
                      title: 'Perfiles profesionales',
                      icon: Icons.groups_rounded,
                      glowColor: const Color(0xFFFACC15),
                      data: profesionalesPorPerfil,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _EstadoPanel(
                      title: 'Detalle por perfil',
                      icon: Icons.badge_rounded,
                      glowColor: const Color(0xFFFACC15),
                      data: profesionalesPorPerfil,
                      emptyText: 'No hay perfiles profesionales registrados.',
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _BarChartPanel(
                  title: 'Perfiles profesionales',
                  icon: Icons.groups_rounded,
                  glowColor: const Color(0xFFFACC15),
                  data: profesionalesPorPerfil,
                ),
                const SizedBox(height: 16),
                _EstadoPanel(
                  title: 'Detalle por perfil',
                  icon: Icons.badge_rounded,
                  glowColor: const Color(0xFFFACC15),
                  data: profesionalesPorPerfil,
                  emptyText: 'No hay perfiles profesionales registrados.',
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HeaderEstadisticas extends StatelessWidget {
  final int totalProfesionales;
  final int totalClientes;
  final int totalCasos;

  const _HeaderEstadisticas({
    required this.totalProfesionales,
    required this.totalClientes,
    required this.totalCasos,
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
            color: const Color(0xFF38BDF8).withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 12),
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
                _HeaderCounters(
                  totalProfesionales: totalProfesionales,
                  totalClientes: totalClientes,
                  totalCasos: totalCasos,
                ),
              ],
            )
          : Column(
              children: [
                _buildIcon(),
                const SizedBox(height: 16),
                const _HeaderText(),
                const SizedBox(height: 16),
                _HeaderCounters(
                  totalProfesionales: totalProfesionales,
                  totalClientes: totalClientes,
                  totalCasos: totalCasos,
                ),
              ],
            ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 70,
      height: 70,
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
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withOpacity(0.35),
            blurRadius: 28,
          ),
        ],
      ),
      child: const Icon(
        Icons.query_stats_rounded,
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
          'Dashboard estadístico',
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
          'Métricas generales de COLEMEX / Advocatus.',
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
  final int totalProfesionales;
  final int totalClientes;
  final int totalCasos;

  const _HeaderCounters({
    required this.totalProfesionales,
    required this.totalClientes,
    required this.totalCasos,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _SmallCounter(
          label: 'Profesionales',
          value: totalProfesionales.toString(),
          icon: Icons.badge_rounded,
          color: const Color(0xFF38BDF8),
        ),
        _SmallCounter(
          label: 'Clientes',
          value: totalClientes.toString(),
          icon: Icons.people_alt_rounded,
          color: const Color(0xFF22C55E),
        ),
        _SmallCounter(
          label: 'Casos',
          value: totalCasos.toString(),
          icon: Icons.folder_rounded,
          color: const Color(0xFFA855F7),
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
      width: 132,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              height: 1.25,
              color: Colors.white.withOpacity(0.52),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color glowColor;
  final Map<String, int> data;

  const _BarChartPanel({
    required this.title,
    required this.icon,
    required this.glowColor,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return _DarkPanel(
      title: title,
      icon: icon,
      glowColor: glowColor,
      child: SizedBox(
        height: 285,
        child: data.isEmpty
            ? const _NoDataChart()
            : BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _maxY(data),
                  barTouchData: BarTouchData(enabled: true),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (_) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.08),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        getTitlesWidget: (value, meta) {
                          final keys = data.keys.toList();
                          final index = value.toInt();

                          if (index < 0 || index >= keys.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _shortLabel(keys[index]),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.62),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    data.length,
                    (index) {
                      final tipo = data.keys.elementAt(index);
                      final cantidad = data[tipo] ?? 0;
                      final color = _colorForTipo(tipo);

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: cantidad.toDouble(),
                            color: color,
                            width: 20,
                            borderRadius: BorderRadius.circular(7),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: _maxY(data),
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }

  double _maxY(Map<String, int> values) {
    if (values.isEmpty) return 10;
    final maxValue = values.values.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 0) return 10;
    return (maxValue + 5).toDouble();
  }

  String _shortLabel(String value) {
    final clean = value.replaceAll('_', ' ');
    if (clean.length <= 12) return clean;
    return '${clean.substring(0, 11)}...';
  }
}

class _PieChartPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color glowColor;
  final Map<String, int> data;

  const _PieChartPanel({
    required this.title,
    required this.icon,
    required this.glowColor,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return _DarkPanel(
      title: title,
      icon: icon,
      glowColor: glowColor,
      child: SizedBox(
        height: 285,
        child: data.isEmpty
            ? const _NoDataChart()
            : PieChart(
                PieChartData(
                  centerSpaceRadius: 42,
                  sectionsSpace: 3,
                  sections: data.entries.map((entry) {
                    final tipo = entry.key;
                    final cantidad = entry.value;
                    final color = _colorForTipo(tipo);

                    return PieChartSectionData(
                      value: cantidad.toDouble(),
                      title: cantidad.toString(),
                      color: color,
                      radius: 72,
                      titleStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}

class _EstadoPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color glowColor;
  final Map<String, int> data;
  final String emptyText;

  const _EstadoPanel({
    required this.title,
    required this.icon,
    required this.glowColor,
    required this.data,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return _DarkPanel(
      title: title,
      icon: icon,
      glowColor: glowColor,
      child: data.isEmpty
          ? _NoDataList(text: emptyText)
          : Column(
              children: data.entries.map((entry) {
                final color = _colorForTipo(entry.key);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _EstadoRow(
                    estado: entry.key,
                    cantidad: entry.value,
                    color: color,
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _EstadoRow extends StatelessWidget {
  final String estado;
  final int cantidad;
  final Color color;

  const _EstadoRow({
    required this.estado,
    required this.cantidad,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final totalWidth = MediaQuery.of(context).size.width;
    final percentWidth = cantidad <= 0 ? 0.05 : 0.40;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.075),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.11),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Icon(
              Icons.circle,
              color: color,
              size: 15,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estado.replaceAll('_', ' '),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: Stack(
                    children: [
                      Container(
                        height: 7,
                        color: Colors.white.withOpacity(0.08),
                      ),
                      Container(
                        height: 7,
                        width: max(24, min(totalWidth * percentWidth, 220)),
                        color: color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            cantidad.toString(),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
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
              _GlowIcon(icon: icon, glowColor: glowColor),
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

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF38BDF8)),
          SizedBox(height: 16),
          Text(
            'Cargando estadísticas...',
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

class _ErrorPanel extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorPanel({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.35)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'No se pudieron cargar las estadísticas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontSize: 12.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'Reintentar',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoDataChart extends StatelessWidget {
  const _NoDataChart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Sin datos para graficar',
        style: TextStyle(
          color: Colors.white.withOpacity(0.58),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _NoDataList extends StatelessWidget {
  final String text;

  const _NoDataList({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withOpacity(0.58),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

Color _colorForTipo(String tipo) {
  final clean = tipo.toLowerCase();

  if (clean.contains('abogado')) return const Color(0xFF38BDF8);
  if (clean.contains('ajustador')) return const Color(0xFFF97316);
  if (clean.contains('perito')) return const Color(0xFFEF4444);
  if (clean.contains('valuador')) return const Color(0xFF22C55E);
  if (clean.contains('investigador')) return const Color(0xFFA855F7);
  if (clean.contains('psic')) return const Color(0xFFEC4899);
  if (clean.contains('inmobiliario')) return const Color(0xFFFACC15);
  if (clean.contains('contador')) return const Color(0xFF14B8A6);
  if (clean.contains('crediticio')) return const Color(0xFF6366F1);
  if (clean.contains('vial')) return const Color(0xFF06B6D4);

  if (clean.contains('abierto')) return const Color(0xFF22C55E);
  if (clean.contains('pendiente')) return const Color(0xFFFACC15);
  if (clean.contains('proceso')) return const Color(0xFFF97316);
  if (clean.contains('cerrado')) return const Color(0xFFEF4444);
  if (clean.contains('finalizado')) return const Color(0xFF38BDF8);
  if (clean.contains('rechazado')) return const Color(0xFFDC2626);
  if (clean.contains('cancelado')) return const Color(0xFF94A3B8);

  return const Color(0xFFA855F7);
}

class _MovingParticlesPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _MovingParticlesPainter({required this.progress})
      : particles = List.generate(80, (index) {
          final random = Random(index * 821);
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