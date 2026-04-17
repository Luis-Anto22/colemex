import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../api_service.dart';

class EstadisticasGeneralScreen extends StatefulWidget {
  const EstadisticasGeneralScreen({super.key});

  @override
  State<EstadisticasGeneralScreen> createState() => _EstadisticasGeneralScreenState();
}

class _EstadisticasGeneralScreenState extends State<EstadisticasGeneralScreen> {
  Map<String, dynamic>? _datos;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

Future<void> _cargarEstadisticas() async {
  try {
    final data = await ApiService.obtenerEstadisticas();

    if (data['success'] == true) {
      setState(() {
        _datos = data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = data['mensaje'] ?? '❌ Error desconocido';
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _error = '❌ Error al conectar: $e';
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final rawCasos = _datos?["casos"]?["por_estado"];
    final casosPorTipo = <String, int>{};

    if (rawCasos != null) {
      (rawCasos as Map).forEach((key, value) {
        final cantidad = int.tryParse(value.toString()) ?? 0;
        if (key != null && key.toString().isNotEmpty) {
          casosPorTipo[key.toString()] = cantidad;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Estadísticas Generales"),
        backgroundColor: Colors.indigo,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCard("Total de abogados", Icons.people, _datos?["abogados"]?["total"]),
                        _buildCard("Total de casos", Icons.folder, _datos?["casos"]?["total"]),
                        _buildCard("Total de clientes", Icons.person, _datos?["clientes"]?["total"]),
                        const SizedBox(height: 24),

                        const Text("Casos por estado", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 220,
                          child: casosPorTipo.isEmpty
                              ? const Center(child: Text("Sin datos"))
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: _maxY(casosPorTipo),
                                    barTouchData: BarTouchData(enabled: true),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final keys = casosPorTipo.keys.toList();
                                            if (value.toInt() < keys.length) {
                                              return Text(keys[value.toInt()], style: const TextStyle(fontSize: 12));
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ),
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: List.generate(casosPorTipo.length, (index) {
                                      final tipo = casosPorTipo.keys.elementAt(index);
                                      final cantidad = casosPorTipo[tipo] ?? 0;
                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: cantidad.toDouble(),
                                            color: Colors.indigo,
                                            width: 18,
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),

                        const Text("Distribución de casos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 220,
                          child: casosPorTipo.isEmpty
                              ? const Center(child: Text("Sin datos"))
                              : PieChart(
                                  PieChartData(
                                    sections: casosPorTipo.entries.map((entry) {
                                      final tipo = entry.key;
                                      final cantidad = entry.value;
                                      final color = _colorForTipo(tipo);
                                      return PieChartSectionData(
                                        value: cantidad.toDouble(),
                                        title: "$tipo\n$cantidad",
                                        color: color,
                                        radius: 60,
                                        titleStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildCard(String titulo, IconData icono, dynamic valor) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icono, color: Colors.indigo),
        title: Text(titulo),
        trailing: Text(
          valor?.toString() ?? "0",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  double _maxY(Map<String, int> casos) {
    if (casos.isEmpty) return 10;
    final max = casos.values.reduce((a, b) => a > b ? a : b);
    return (max + 5).toDouble();
  }

  static Color _colorForTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case "abierto":
        return Colors.green;
      case "en_proceso":
        return Colors.orange;
      case "cerrado":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}