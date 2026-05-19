import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services/api_client.dart';
import '../../services/api_services/asistencia_vial_api.dart';
import 'package:advocatus/screens/asistencia_vial/evidencias_servicio_screen.dart';


class ServicioEnCursoAsistenciaScreen extends StatefulWidget {
  const ServicioEnCursoAsistenciaScreen({super.key});

  @override
  State<ServicioEnCursoAsistenciaScreen> createState() =>
      _ServicioEnCursoAsistenciaScreenState();
}

class _ServicioEnCursoAsistenciaScreenState
    extends State<ServicioEnCursoAsistenciaScreen> {
  final AsistenciaVialApi api = AsistenciaVialApi(ApiClient());

  bool cargando = true;
  String mensaje = '';

  int profesionalId = 0;

  Map<String, dynamic>? servicio;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();

    profesionalId = prefs.getInt('id') ?? 0;

    if (profesionalId <= 0) {
      setState(() {
        cargando = false;
        mensaje = 'ID profesional no válido';
      });
      return;
    }

    try {
      final data = await api.getServicioEnCurso(profesionalId);

      if (!mounted) return;

      setState(() {
        servicio = data;
        cargando = false;
        mensaje = '';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
        mensaje = 'Error: $e';
      });
    }
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  String _txt(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    return text.isEmpty ? fallback : text;
  }

  String _cliente() {
    final cliente = _map(servicio?['cliente']);

    return _txt(cliente['nombre'], 'Cliente');
  }

  String _tipoAuxilio() {
    final tipo = _map(servicio?['tipo_auxilio']);

    return _txt(tipo['nombre'], 'Auxilio vial');
  }

  String _vehiculo() {
    final marca = _txt(servicio?['vehiculo_marca']);
    final modelo = _txt(servicio?['vehiculo_modelo']);
    final anio = _txt(servicio?['vehiculo_anio']);
    final color = _txt(servicio?['vehiculo_color']);
    final placas = _txt(servicio?['placas']);

    final partes = [
      marca,
      modelo,
      anio,
      color,
      if (placas.isNotEmpty) 'Placas: $placas',
    ].where((e) => e.isNotEmpty).toList();

    return partes.isEmpty
        ? 'Vehículo no especificado'
        : partes.join(' • ');
  }

  String _estado() {
    return _txt(servicio?['estado'], 'pendiente');
  }

  String _direccion() {
    return _txt(
      servicio?['direccion'],
      'Ubicación no especificada',
    );
  }

  String _descripcion() {
    return _txt(servicio?['descripcion']);
  }

  int _servicioId() {
    return int.tryParse(
          servicio?['id']?.toString() ?? '',
        ) ??
        0;
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'aceptado':
        return Colors.blue;

      case 'en_camino':
        return Colors.orange;

      case 'en_servicio':
        return Colors.purple;

      case 'finalizado':
        return Colors.green;

      case 'cancelado':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  String _estadoLabel(String estado) {
    switch (estado.toLowerCase()) {
      case 'aceptado':
        return 'Aceptado';

      case 'en_camino':
        return 'En camino';

      case 'en_servicio':
        return 'En servicio';

      case 'finalizado':
        return 'Finalizado';

      case 'cancelado':
        return 'Cancelado';

      default:
        return estado;
    }
  }

  Future<void> _cambiarEstado(String estado) async {
    final servicioId = _servicioId();

    if (servicioId <= 0) return;

    try {
      await api.cambiarEstadoServicio(
        servicioId: servicioId,
        estado: estado,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Estado actualizado a ${_estadoLabel(estado)}',
          ),
        ),
      );

      await _cargar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  Widget _estadoButton({
    required String estado,
    required String label,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: () => _cambiarEstado(estado),
      icon: Icon(icon),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    final estado = _estado();

    final colorEstado = _estadoColor(estado);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicio en curso'),
        actions: [
          IconButton(
            onPressed: _cargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF12161C),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : servicio == null
              ? Center(
                  child: Text(
                    mensaje.isEmpty
                        ? 'No hay servicios activos.'
                        : mensaje,
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Icon(
                      Icons.car_repair,
                      size: 60,
                      color: gold,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      _tipoAuxilio(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Card(
                      color: const Color(0xFF1B2028),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorEstado.withOpacity(.15),
                                    borderRadius:
                                        BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    _estadoLabel(estado),
                                    style: TextStyle(
                                      color: colorEstado,
                                      fontWeight:
                                          FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Text(
                              'Cliente: ${_cliente()}',
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Vehículo: ${_vehiculo()}',
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Ubicación: ${_direccion()}',
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),

                            if (_descripcion().isNotEmpty) ...[
                              const SizedBox(height: 12),

                              Text(
                                _descripcion(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (estado == 'aceptado')
                      _estadoButton(
                        estado: 'en_camino',
                        label: 'Marcar en camino',
                        icon: Icons.navigation,
                      ),

                    if (estado == 'en_camino') ...[
                      _estadoButton(
                        estado: 'en_servicio',
                        label: 'Iniciar servicio',
                        icon: Icons.build,
                      ),
                    ],

                    if (estado == 'en_servicio') ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EvidenciasServicioScreen(
                                servicioId: _servicioId(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Evidencias'),
                      ),

                      const SizedBox(height: 12),

                      _estadoButton(
                        estado: 'finalizado',
                        label: 'Finalizar servicio',
                        icon: Icons.check_circle,
                      ),
                    ],
                  ],
                ),
    );
  }
}