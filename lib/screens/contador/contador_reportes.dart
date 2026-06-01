import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'reporte_crear.dart';
import 'reporte_detalle.dart';

class ContadorReportes extends StatefulWidget {
  final int idContador;

  const ContadorReportes({super.key, required this.idContador});

  @override
  State<ContadorReportes> createState() => _ContadorReportesState();
}

class _ContadorReportesState extends State<ContadorReportes> {
  bool _loading = true;
  String? _error;
  List<dynamic> _reportes = [];
  List<dynamic> _filtrados = [];

  final TextEditingController _buscarController = TextEditingController();

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/reportes";

  @override
  void initState() {
    super.initState();
    _fetchReportes();
    _buscarController.addListener(_filtrar);
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  Future<void> _fetchReportes() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl?contador_id=${widget.idContador}"),
        headers: {"Accept": "application/json"},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          _reportes = data["data"] ?? [];
          _filtrados = _reportes;
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = data["message"] ?? "Error al cargar reportes";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _filtrar() {
    final q = _buscarController.text.toLowerCase().trim();

    setState(() {
      _filtrados = q.isEmpty
          ? _reportes
          : _reportes.where((r) {
              final m = Map<String, dynamic>.from(r);
              final cliente = m["cliente_nombre"]?.toString().toLowerCase() ?? "";
              final periodo = m["periodo"]?.toString().toLowerCase() ?? "";
              final estado = m["estado"]?.toString().toLowerCase() ?? "";
              return cliente.contains(q) ||
                  periodo.contains(q) ||
                  estado.contains(q);
            }).toList();
    });
  }

  double _num(dynamic v) {
    if (v == null) return 0;
    return double.tryParse(v.toString()) ?? 0;
  }

  String _money(dynamic v) {
    final n = _num(v);
    return "\$${n.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        )}";
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'generado':
        return Colors.green;
      case 'enviado':
        return Colors.blue;
      case 'borrador':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _crearReporte() async {
    final creado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReporteCrear(idContador: widget.idContador),
      ),
    );

    if (creado == true) _fetchReportes();
  }

  double get _ingresosTotal =>
      _reportes.fold(0, (sum, r) => sum + _num(r["ingresos"]));

  double get _egresosTotal =>
      _reportes.fold(0, (sum, r) => sum + _num(r["egresos"]));

  double get _utilidadTotal =>
      _reportes.fold(0, (sum, r) => sum + _num(r["utilidad"]));

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    const darkGold = Color(0xFFB8860B);
    const bg = Color(0xFFF7F7F9);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: darkGold,
        foregroundColor: Colors.white,
        onPressed: _crearReporte,
        icon: const Icon(Icons.add),
        label: const Text("Nuevo reporte"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("❌ $_error"))
              : RefreshIndicator(
                  onRefresh: _fetchReportes,
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 120,
                        pinned: true,
                        backgroundColor: darkGold,
                        foregroundColor: Colors.white,
                        flexibleSpace: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [gold, darkGold],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const FlexibleSpaceBar(
                            titlePadding: EdgeInsets.only(left: 56, bottom: 16),
                            title: Text(
                              "Reportes financieros",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Gestiona y consulta los reportes de tus clientes",
                                style: TextStyle(
                                  color: Color(0xFF667085),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 18),

                              Row(
                                children: [
                                  Expanded(
                                    child: _KpiCard(
                                      title: "Ingresos totales",
                                      value: _money(_ingresosTotal),
                                      icon: Icons.trending_up,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _KpiCard(
                                      title: "Egresos totales",
                                      value: _money(_egresosTotal),
                                      icon: Icons.trending_down,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _KpiCard(
                                      title: "Utilidad neta",
                                      value: _money(_utilidadTotal),
                                      icon: Icons.account_balance_wallet_outlined,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _KpiCard(
                                      title: "Reportes",
                                      value: "${_reportes.length}",
                                      icon: Icons.bar_chart_rounded,
                                      color: darkGold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.05),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _buscarController,
                                  decoration: const InputDecoration(
                                    icon: Icon(Icons.search),
                                    hintText: "Buscar cliente o periodo...",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),
                            ],
                          ),
                        ),
                      ),

                      if (_filtrados.isEmpty)
                        const SliverFillRemaining(
                          child: Center(
                            child: Text("No hay reportes registrados."),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final r =
                                  Map<String, dynamic>.from(_filtrados[index]);
                              return _ReporteCard(
                                reporte: r,
                                estadoColor: _estadoColor(
                                  r["estado"]?.toString() ?? "borrador",
                                ),
                                money: _money,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReporteDetalle(
                                        reporteId: r["id"],
                                      ),
                                    ),
                                  ).then((_) => _fetchReportes());
                                },
                              );
                            },
                            childCount: _filtrados.length,
                          ),
                        ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 90),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(.13),
            child: Icon(icon, color: color, size: 30),
          ),
          const Spacer(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReporteCard extends StatelessWidget {
  final Map<String, dynamic> reporte;
  final Color estadoColor;
  final String Function(dynamic) money;
  final VoidCallback onTap;

  const _ReporteCard({
    required this.reporte,
    required this.estadoColor,
    required this.money,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final estado = reporte["estado"]?.toString() ?? "borrador";

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEAEAEA)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: estadoColor.withOpacity(.12),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: estadoColor,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: estadoColor.withOpacity(.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        estado.toUpperCase(),
                        style: TextStyle(
                          color: estadoColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reporte["cliente_nombre"]?.toString() ??
                          reporte["titulo"]?.toString() ??
                          "Reporte financiero",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      children: [
                        _MiniDato(
                          icon: Icons.calendar_month,
                          text: "Periodo: ${reporte["periodo"] ?? "N/A"}",
                        ),
                        _MiniDato(
                          icon: Icons.trending_up,
                          text: "Ingresos: ${money(reporte["ingresos"])}",
                        ),
                        _MiniDato(
                          icon: Icons.trending_down,
                          text: "Egresos: ${money(reporte["egresos"])}",
                        ),
                        _MiniDato(
                          icon: Icons.show_chart,
                          text: "Utilidad: ${money(reporte["utilidad"])}",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniDato extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniDato({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: Color(0xFF667085)),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}