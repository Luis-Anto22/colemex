import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'empleado_crear.dart';
import 'nomina_recibos.dart';

class NominaEmpleados extends StatefulWidget {
  final int idContador;

  const NominaEmpleados({
    super.key,
    required this.idContador,
  });

  @override
  State<NominaEmpleados> createState() => _NominaEmpleadosState();
}

class _NominaEmpleadosState extends State<NominaEmpleados> {
  bool _loading = true;
  String? _error;

  List<dynamic> _empleados = [];
  List<dynamic> _filtrados = [];

  final TextEditingController _buscarController = TextEditingController();

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/empleados";

  @override
  void initState() {
    super.initState();
    _fetchEmpleados();
    _buscarController.addListener(_filtrar);
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmpleados() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl?contador_id=${widget.idContador}"),
        headers: {"Accept": "application/json"},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          _empleados = data["data"] ?? [];
          _filtrados = _empleados;
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = data["message"] ?? "Error al cargar empleados";
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
          ? _empleados
          : _empleados.where((e) {
              final m = Map<String, dynamic>.from(e);
              final nombre = m["nombre"]?.toString().toLowerCase() ?? "";
              final empresa =
                  m["cliente_nombre"]?.toString().toLowerCase() ?? "";
              final puesto = m["puesto"]?.toString().toLowerCase() ?? "";
              final estado = m["estado"]?.toString().toLowerCase() ?? "";

              return nombre.contains(q) ||
                  empresa.contains(q) ||
                  puesto.contains(q) ||
                  estado.contains(q);
            }).toList();
    });
  }

  Future<void> _crearEmpleado() async {
    final creado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmpleadoCrear(idContador: widget.idContador),
      ),
    );

    if (creado == true) {
      _fetchEmpleados();
    }
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
      case 'activo':
        return Colors.green;
      case 'inactivo':
        return Colors.orange;
      case 'baja':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int get _activos => _empleados
      .where((e) =>
          (Map<String, dynamic>.from(e)["estado"]?.toString() ?? "activo") ==
          "activo")
      .length;

  double get _nominaTotal => _empleados.fold(
        0,
        (sum, e) => sum + _num(Map<String, dynamic>.from(e)["salario"]),
      );

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
        onPressed: _crearEmpleado,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text("Nuevo empleado"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("❌ $_error"))
              : RefreshIndicator(
                  onRefresh: _fetchEmpleados,
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 125,
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
                              "Nómina y empleados",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
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
                                "Administra empleados, salarios y recibos de nómina.",
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
                                      title: "Empleados",
                                      value: "${_empleados.length}",
                                      icon: Icons.groups_rounded,
                                      color: darkGold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _KpiCard(
                                      title: "Activos",
                                      value: "$_activos",
                                      icon: Icons.verified_user_rounded,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _KpiWideCard(
                                title: "Nómina estimada",
                                value: _money(_nominaTotal),
                                icon: Icons.account_balance_wallet_rounded,
                                color: Colors.blue,
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
                                    icon: Icon(Icons.search_rounded),
                                    hintText: "Buscar empleado, empresa o puesto...",
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
                            child: Text("No hay empleados registrados."),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final empleado =
                                  Map<String, dynamic>.from(_filtrados[index]);
                              final estado =
                                  empleado["estado"]?.toString() ?? "activo";

                              return _EmpleadoCard(
                                empleado: empleado,
                                estadoColor: _estadoColor(estado),
                                money: _money,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NominaRecibos(
                                        idContador: widget.idContador,
                                        empleadoId: empleado["id"],
                                        empleadoNombre:
                                            empleado["nombre"] ?? "",
                                      ),
                                    ),
                                  );
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
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiWideCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiWideCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(.13),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
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

class _EmpleadoCard extends StatelessWidget {
  final Map<String, dynamic> empleado;
  final Color estadoColor;
  final String Function(dynamic) money;
  final VoidCallback onTap;

  const _EmpleadoCard({
    required this.empleado,
    required this.estadoColor,
    required this.money,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final estado = empleado["estado"]?.toString() ?? "activo";

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
                  Icons.badge_rounded,
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
                      empleado["nombre"]?.toString() ?? "Empleado",
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
                          icon: Icons.business_rounded,
                          text:
                              "Empresa: ${empleado["cliente_nombre"] ?? "N/A"}",
                        ),
                        _MiniDato(
                          icon: Icons.work_rounded,
                          text: "Puesto: ${empleado["puesto"] ?? "N/A"}",
                        ),
                        _MiniDato(
                          icon: Icons.payments_rounded,
                          text: "Salario: ${money(empleado["salario"])}",
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