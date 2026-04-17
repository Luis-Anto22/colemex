import 'package:flutter/material.dart';

// comunes (solo si ya los usas en otros paneles)
import 'package:advocatus/screens/common/historial/historial_screen.dart';
import 'package:advocatus/screens/common/ubicacion/ubicacion_tiempo_real_screen.dart';

class PanelAsistenciaVial extends StatefulWidget {
  final int asistenciaId;

  const PanelAsistenciaVial({
    super.key,
    required this.asistenciaId,
  });

  @override
  State<PanelAsistenciaVial> createState() =>
      _PanelAsistenciaVialState();
}

class _PanelAsistenciaVialState
    extends State<PanelAsistenciaVial> {

  String estado = 'Disponible';

  void _go(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _sectionHeader(String title,
      {String? subtitle}) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
                color:
                    Colors.white.withOpacity(.7),
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
          color:
              active ? Colors.black : Colors.white,
        ),
      ),
      selected: active,
      onSelected: (_) =>
          setState(() => estado = label),
      selectedColor: Colors.amber,
      backgroundColor:
          Colors.white.withOpacity(.08),
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
      title: Text(title,
          style:
              const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(.7),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white54,
      ),
      onTap: onTap,
    );
  }

  Widget _resumenCard() {
    return Card(
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: const [
            _ResumenItem(
              titulo: "Servicios",
              valor: "3",
            ),
            _ResumenItem(
              titulo: "Ingresos",
              valor: "\$2,400",
            ),
            _ResumenItem(
              titulo: "Solicitudes",
              valor: "5",
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
        title:
            const Text("Panel • Asistencia Vial"),
      ),
      body: Container(
        color: const Color(0xFF12161C),
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            // 🔥 HERO
            Card(
              color: Colors.black87,
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Portal Profesional",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Estado: $estado",
                            style: TextStyle(
                              color: Colors.white
                                  .withOpacity(.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🟢 ESTADO
            _sectionHeader(
              "Estado profesional",
              subtitle:
                  "Define tu disponibilidad actual",
            ),

            Wrap(
              spacing: 10,
              children: [
                _estadoChip("Disponible"),
                _estadoChip("En servicio"),
                _estadoChip("Fuera de servicio"),
              ],
            ),

            // 📊 RESUMEN DEL DÍA
            _sectionHeader(
              "Resumen del día",
              subtitle:
                  "Actividad actual",
            ),

            _resumenCard(),

            // 🚗 SERVICIOS
            _sectionHeader(
              "Servicios",
              subtitle:
                  "Gestión operativa",
            ),

            _tile(
              icon: Icons.notifications_active,
              title: "Solicitudes pendientes",
              subtitle:
                  "Aceptar o rechazar servicios",
              onTap: () {},
            ),
            _tile(
              icon: Icons.build,
              title: "Servicio en curso",
              subtitle:
                  "Atenciones activas",
              onTap: () {},
            ),
            _tile(
              icon: Icons.history,
              title: "Historial de servicios",
              subtitle:
                  "Servicios completados",
              onTap: () =>
                  _go(const HistorialScreen()),
            ),

            // 📍 OPERACIÓN
            _sectionHeader(
              "Operación",
            ),

            _tile(
              icon: Icons.location_on,
              title:
                  "Ubicación en tiempo real",
              subtitle:
                  "Compartir ubicación activa",
              onTap: () => _go(
                  const UbicacionTiempoRealScreen()),
            ),
          ],
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