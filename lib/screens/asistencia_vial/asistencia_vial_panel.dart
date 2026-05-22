import 'package:advocatus/screens/asistencia_vial/servicio_en_curso_asistencia_screen.dart';
import 'package:flutter/material.dart';

import 'package:advocatus/screens/common/historial/historial_screen.dart';
import 'package:advocatus/screens/common/ubicacion/ubicacion_tiempo_real_screen.dart';
import 'package:advocatus/screens/common/agenda/agenda_screen.dart';
import 'package:advocatus/screens/common/ingresos/ingresos_screen.dart';
import 'package:advocatus/screens/asistencia_vial/solicitudes_asistencia_screen.dart';
import 'package:advocatus/screens/asistencia_vial/modulos/vehiculos_atendidos_screen.dart';
import 'package:advocatus/screens/common/configuracion/configuracion_screen.dart';
import 'package:advocatus/screens/common/notificaciones/notificaciones_screen.dart';

import 'package:advocatus/services/api_services/api_client.dart';
import 'package:advocatus/services/api_services/asistencia_vial_api.dart';

class PanelAsistenciaVial extends StatefulWidget {
  final int asistenciaId;

  const PanelAsistenciaVial({
    super.key,
    required this.asistenciaId,
  });

  @override
  State<PanelAsistenciaVial> createState() => _PanelAsistenciaVialState();
}

class _PanelAsistenciaVialState extends State<PanelAsistenciaVial> {
  final AsistenciaVialApi api = AsistenciaVialApi(ApiClient());

  String estado = 'Disponible';

  bool cargandoResumen = true;
  int serviciosHoy = 0;
  double ingresosHoy = 0;
  int solicitudesHoy = 0;

  @override
  void initState() {
    super.initState();
    _cargarResumenDia();
  }

  Future<void> _cargarResumenDia() async {
    try {
      final data = await api.getResumenDia(widget.asistenciaId);

      if (!mounted) return;

      setState(() {
        serviciosHoy = int.tryParse('${data['servicios'] ?? 0}') ?? 0;
        ingresosHoy = double.tryParse('${data['ingresos'] ?? 0}') ?? 0;
        solicitudesHoy = int.tryParse('${data['solicitudes'] ?? 0}') ?? 0;
        cargandoResumen = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargandoResumen = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar resumen: $e')),
      );
    }
  }

  void _go(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) => _cargarResumenDia());
  }

  Widget _sectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _estadoChip(String label) {
    final active = estado == label;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: active ? Colors.black : Colors.white,
        ),
      ),
      selected: active,
      onSelected: (_) => setState(() => estado = label),
      selectedColor: Colors.amber,
      backgroundColor: Colors.white.withOpacity(.08),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(.7)),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white54,
      ),
      onTap: onTap,
    );
  }

  Widget _resumenCard() {
    if (cargandoResumen) {
      return const Card(
        color: Colors.black87,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ResumenItem(
              titulo: "Servicios",
              valor: "$serviciosHoy",
            ),
            _ResumenItem(
              titulo: "Ingresos",
              valor: "\$${ingresosHoy.toStringAsFixed(2)}",
            ),
            _ResumenItem(
              titulo: "Solicitudes",
              valor: "$solicitudesHoy",
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel • Asistencia Vial"),
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () => _go(
              NotificacionesScreen(
                profesionalId: widget.asistenciaId,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarResumenDia,
        child: Container(
          color: const Color(0xFF12161C),
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Card(
                color: Colors.black87,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.car_repair,
                        size: 42,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Portal Profesional",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Estado: $estado",
                              style: TextStyle(
                                color: Colors.white.withOpacity(.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _sectionHeader(
                "Estado profesional",
                subtitle: "Define tu disponibilidad actual",
              ),

              Wrap(
                spacing: 10,
                children: [
                  _estadoChip("Disponible"),
                  _estadoChip("En servicio"),
                  _estadoChip("Fuera de servicio"),
                ],
              ),

              _sectionHeader(
                "Resumen del día",
                subtitle: "Actividad actual",
              ),

              _resumenCard(),

              _sectionHeader(
                "Servicios",
                subtitle: "Gestión operativa",
              ),

              _tile(
                icon: Icons.notifications_active,
                title: "Solicitudes pendientes",
                subtitle: "Aceptar o rechazar servicios",
                onTap: () => _go(const SolicitudesAsistenciaScreen()),
              ),

              _tile(
                icon: Icons.build,
                title: "Servicio en curso",
                subtitle: "Atenciones activas",
                onTap: () => _go(
                  const ServicioEnCursoAsistenciaScreen(),
                ),
              ),

              _tile(
                icon: Icons.history,
                title: "Historial de servicios",
                subtitle: "Servicios completados",
                onTap: () => _go(const HistorialScreen()),
              ),

              _tile(
                icon: Icons.directions_car,
                title: "Vehículos atendidos",
                subtitle: "Vehículos registrados en servicios",
                onTap: () => _go(
                  const VehiculosAtendidosScreen(),
                ),
              ),

              _tile(
                icon: Icons.calendar_month,
                title: "Agenda",
                subtitle: "Citas y servicios programados",
                onTap: () => _go(const AgendaScreen()),
              ),

              _tile(
                icon: Icons.attach_money,
                title: "Ingresos",
                subtitle: "Pagos, comisiones y ganancias",
                onTap: () => _go(const IngresosScreen()),
              ),

              _sectionHeader("Operación"),

              _tile(
                icon: Icons.location_on,
                title: "Ubicación en tiempo real",
                subtitle: "Compartir ubicación activa",
                onTap: () => _go(const UbicacionTiempoRealScreen()),
              ),

              _sectionHeader("Cuenta"),

              _tile(
                icon: Icons.settings,
                title: "Configuración",
                subtitle: "Preferencias, ubicación y cierre de sesión",
                onTap: () => _go(const ConfiguracionScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumenItem extends StatelessWidget {
  final String titulo;
  final String valor;

  const _ResumenItem({
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}