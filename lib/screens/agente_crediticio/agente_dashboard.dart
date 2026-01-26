import 'package:flutter/material.dart';
import 'widgets/agente_card.dart';
import 'api_service_crediticio.dart';

class AgenteDashboard extends StatefulWidget {
  final int? idAgente;

  const AgenteDashboard({super.key, this.idAgente});

  @override
  State<AgenteDashboard> createState() => _AgenteDashboardState();
}

class _AgenteDashboardState extends State<AgenteDashboard> {
  Map<String, int> estados = {};
  double montoTotal = 0.0;
  double rating = 0.0;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDashboard();
  }

  Future<void> _cargarDashboard() async {
    try {
      final data =
          await ApiServiceCrediticio.dashboardAgente(widget.idAgente ?? 0);

      setState(() {
        estados = Map<String, int>.from(data['estados'] ?? {});
        montoTotal = (data['monto_total_solicitado'] ?? 0.0).toDouble();
        rating = (data['rating_promedio'] ?? 0.0).toDouble();
        cargando = false;
      });
    } catch (e) {
      debugPrint("❌ Error al cargar dashboard: $e");
      setState(() => cargando = false);
    }
  }

  int _getEstado(String key) => estados[key] ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Agente Crediticio"),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                AgenteCard(
                  icono: Icons.timelapse,
                  titulo: "Pendientes",
                  valor: "${_getEstado('pendiente')}",
                  color: Colors.orange,
                ),
                AgenteCard(
                  icono: Icons.check_circle,
                  titulo: "Aprobados",
                  valor: "${_getEstado('aprobado')}",
                  color: Colors.green,
                ),
                AgenteCard(
                  icono: Icons.cancel,
                  titulo: "Rechazados",
                  valor: "${_getEstado('rechazado')}",
                  color: Colors.red,
                ),
                AgenteCard(
                  icono: Icons.attach_money,
                  titulo: "Monto Total",
                  valor: "\$${montoTotal.toStringAsFixed(2)}",
                  color: Colors.blue,
                ),
                AgenteCard(
                  icono: Icons.star,
                  titulo: "Rating Promedio",
                  valor: rating.toStringAsFixed(2),
                  color: Colors.amber,
                ),
                if (widget.idAgente != null)
                  AgenteCard(
                    icono: Icons.badge,
                    titulo: "ID del Agente",
                    valor: "${widget.idAgente}",
                    color: Colors.purple,
                  ),
              ],
            ),
    );
  }
}