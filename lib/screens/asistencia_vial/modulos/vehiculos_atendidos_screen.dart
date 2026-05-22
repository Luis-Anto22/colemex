import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/asistencia_vial_api.dart';

class VehiculosAtendidosScreen extends StatefulWidget {
  const VehiculosAtendidosScreen({super.key});

  @override
  State<VehiculosAtendidosScreen> createState() =>
      _VehiculosAtendidosScreenState();
}

class _VehiculosAtendidosScreenState extends State<VehiculosAtendidosScreen> {
  late final AsistenciaVialApi api;

  bool cargando = true;
  String? error;
  List<dynamic> vehiculos = [];

  @override
  void initState() {
    super.initState();
    api = AsistenciaVialApi(ApiClient());
    cargarVehiculos();
  }

  Future<void> cargarVehiculos() async {
    try {
      setState(() {
        cargando = true;
        error = null;
      });

      final prefs = await SharedPreferences.getInstance();

      final profesionalId =
          prefs.getInt('profesional_id') ??
          prefs.getInt('id') ??
          int.tryParse(prefs.getString('profesional_id') ?? '') ??
          int.tryParse(prefs.getString('id') ?? '');

      if (profesionalId == null) {
        throw Exception('No se encontró el ID del profesional');
      }

      final data = await api.getVehiculosAtendidos(profesionalId);

      if (!mounted) return;

      setState(() {
        vehiculos = data;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        cargando = false;
      });
    }
  }

  Color obtenerColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'finalizado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String texto(dynamic valor) {
    if (valor == null) return 'No registrado';
    final v = valor.toString().trim();
    return v.isEmpty ? 'No registrado' : v;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181C24),
        elevation: 0,
        title: const Text(
          'Vehículos atendidos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: cargarVehiculos,
        child: cargando
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 120),
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 52,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  )
                : vehiculos.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(24),
                        children: const [
                          SizedBox(height: 120),
                          Icon(
                            Icons.directions_car_outlined,
                            color: Colors.white38,
                            size: 58,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay vehículos atendidos',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: vehiculos.length,
                        itemBuilder: (context, index) {
                          final vehiculo =
                              vehiculos[index] as Map<String, dynamic>;

                          final nombreVehiculo =
                              texto(vehiculo['vehiculo']);
                          final cliente = texto(vehiculo['cliente']);
                          final placas = texto(vehiculo['placas']);
                          final tipoAuxilio =
                              texto(vehiculo['tipo_auxilio']);
                          final fecha = texto(vehiculo['fecha']);
                          final estado = texto(vehiculo['estado']);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF181C24),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.directions_car,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nombreVehiculo,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            cliente,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                infoTile(
                                  Icons.confirmation_number,
                                  'Placas',
                                  placas,
                                ),
                                infoTile(
                                  Icons.build,
                                  'Auxilio',
                                  tipoAuxilio,
                                ),
                                infoTile(
                                  Icons.calendar_today,
                                  'Fecha',
                                  fecha,
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: obtenerColorEstado(estado)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    estado.toUpperCase(),
                                    style: TextStyle(
                                      color: obtenerColorEstado(estado),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget infoTile(
    IconData icon,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(width: 10),
          Text(
            '$titulo: ',
            style: const TextStyle(color: Colors.white54),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}