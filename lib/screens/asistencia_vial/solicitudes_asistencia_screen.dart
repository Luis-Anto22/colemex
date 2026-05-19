import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services/api_client.dart';
import '../../services/api_services/asistencia_vial_api.dart';

class SolicitudesAsistenciaScreen extends StatefulWidget {
  const SolicitudesAsistenciaScreen({super.key});

  @override
  State<SolicitudesAsistenciaScreen> createState() =>
      _SolicitudesAsistenciaScreenState();
}

class _SolicitudesAsistenciaScreenState
    extends State<SolicitudesAsistenciaScreen> {
  final AsistenciaVialApi api = AsistenciaVialApi(ApiClient());

  bool cargando = true;
  String mensaje = '';
  int profesionalId = 0;
  List<dynamic> solicitudes = [];

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
      final data = await api.getSolicitudesPendientes();

      if (!mounted) return;

      setState(() {
        solicitudes = data;
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

  Map<String, dynamic> _map(dynamic item) {
    if (item is Map<String, dynamic>) return item;
    if (item is Map) return Map<String, dynamic>.from(item);
    return {};
  }

  String _txt(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _cliente(Map<String, dynamic> item) {
    final cliente = _map(item['cliente']);
    return _txt(cliente['nombre'], 'Cliente');
  }

  String _tipoAuxilio(Map<String, dynamic> item) {
    final tipo = _map(item['tipo_auxilio']);
    return _txt(tipo['nombre'], 'Auxilio vial');
  }

  String _vehiculo(Map<String, dynamic> item) {
    final marca = _txt(item['vehiculo_marca']);
    final modelo = _txt(item['vehiculo_modelo']);
    final anio = _txt(item['vehiculo_anio']);
    final color = _txt(item['vehiculo_color']);
    final placas = _txt(item['placas']);

    final partes = [
      marca,
      modelo,
      anio,
      color,
      if (placas.isNotEmpty) 'Placas: $placas',
    ].where((e) => e.isNotEmpty).toList();

    return partes.isEmpty ? 'Vehículo no especificado' : partes.join(' • ');
  }

  String _fecha(dynamic value) {
    final text = _txt(value, 'Fecha no disponible');
    final raw = text.replaceFirst('T', ' ');
    if (raw.length >= 16) return raw.substring(0, 16);
    return raw;
  }

  Future<void> _aceptar(int servicioId) async {
    try {
      await api.aceptarServicio(
        servicioId: servicioId,
        profesionalId: profesionalId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servicio aceptado')),
      );

      await _cargar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _rechazar(int servicioId) async {
    try {
      await api.rechazarServicio(servicioId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servicio rechazado')),
      );

      await _cargar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _confirmarAceptar(int servicioId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aceptar servicio'),
        content: const Text('¿Quieres tomar esta solicitud?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _aceptar(servicioId);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _confirmarRechazar(int servicioId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rechazar servicio'),
        content: const Text('¿Seguro que quieres rechazar esta solicitud?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rechazar(servicioId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  Widget _solicitudCard(Map<String, dynamic> item) {
    final id = int.tryParse(item['id']?.toString() ?? '') ?? 0;
    final gold = Theme.of(context).primaryColor;

    final direccion = _txt(item['direccion'], 'Ubicación no especificada');
    final descripcion = _txt(item['descripcion']);
    final fecha = _fecha(item['fecha_solicitud'] ?? item['created_at']);

    return Card(
      color: const Color(0xFF1B2028),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.car_repair, color: gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _tipoAuxilio(item),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Pendiente',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Cliente: ${_cliente(item)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Text(
              'Vehículo: ${_vehiculo(item)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Text(
              'Ubicación: $direccion',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Text(
              'Fecha: $fecha',
              style: const TextStyle(color: Colors.white54),
            ),
            if (descripcion.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                descripcion,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: id <= 0 ? null : () => _confirmarRechazar(id),
                    icon: const Icon(Icons.close),
                    label: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: id <= 0 ? null : () => _confirmarAceptar(id),
                    icon: const Icon(Icons.check),
                    label: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes pendientes'),
        actions: [
          IconButton(
            onPressed: _cargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF12161C),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Icon(Icons.notifications_active, size: 58, color: gold),
            const SizedBox(height: 12),
            const Text(
              'Solicitudes de auxilio',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Acepta o rechaza servicios solicitados por clientes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 18),
            if (cargando)
              const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (solicitudes.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Center(
                  child: Text(
                    mensaje.isEmpty ? 'No hay solicitudes pendientes.' : mensaje,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              )
            else
              ...solicitudes.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _solicitudCard(_map(item)),
                );
              }),
          ],
        ),
      ),
    );
  }
}