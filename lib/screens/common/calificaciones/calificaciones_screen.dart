import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/common_api.dart';

class CalificacionesScreen extends StatefulWidget {
  const CalificacionesScreen({super.key});

  @override
  State<CalificacionesScreen> createState() => _CalificacionesScreenState();
}

class _CalificacionesScreenState extends State<CalificacionesScreen> {
  final CommonApi api = CommonApi(ApiClient());

  bool cargando = true;
  String mensaje = '';

  int profesionalId = 0;
  List<dynamic> items = [];

  double promedio = 0;
  int total = 0;

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
        mensaje = 'ID no válido';
      });
      return;
    }

    try {
      final data = await api.getCalificaciones(profesionalId);

      if (!mounted) return;

      setState(() {
        items = data['items'] is List ? data['items'] as List<dynamic> : [];
        promedio = _toDouble(data['promedio']);
        total = _toInt(data['total']);
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

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  String _texto(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _clienteNombre(Map<String, dynamic> item) {
    final cliente = item['cliente'];

    if (cliente is Map) {
      final nombre = cliente['nombre'];
      if (nombre != null && nombre.toString().trim().isNotEmpty) {
        return nombre.toString();
      }
    }

    if (item['cliente_nombre'] != null) {
      return _texto(item['cliente_nombre'], 'Cliente');
    }

    if (item['cliente_id'] != null) {
      return 'Cliente #${item['cliente_id']}';
    }

    return 'Cliente';
  }

  String _fecha(dynamic value) {
    final text = _texto(value, 'Fecha no disponible');

    if (text.length >= 16) {
      return text.replaceFirst('T', ' ').substring(0, 16);
    }

    return text;
  }

  int _estrellas(Map<String, dynamic> item) {
    final value = item['estrellas'];
    final estrellas = _toInt(value);

    if (estrellas < 0) return 0;
    if (estrellas > 5) return 5;

    return estrellas;
  }

  Widget _stars(int cantidad, {double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final active = index < cantidad;

        return Icon(
          active ? Icons.star : Icons.star_border,
          color: active ? Theme.of(context).primaryColor : Colors.grey,
          size: size,
        );
      }),
    );
  }

  void _verDetalle(Map<String, dynamic> item) {
    final cliente = _clienteNombre(item);
    final estrellas = _estrellas(item);
    final comentario = _texto(item['comentario'], 'Sin comentario');
    final fecha = _fecha(item['fecha'] ?? item['created_at']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        final gold = Theme.of(context).primaryColor;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cliente,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _stars(estrellas, size: 24),
                const SizedBox(height: 14),
                _detalleLinea(Icons.calendar_today_outlined, 'Fecha', fecha),
                const SizedBox(height: 10),
                const Text(
                  'Comentario',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  comentario,
                  style: const TextStyle(height: 1.35),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detalleLinea(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _calificacionCard(Map<String, dynamic> item) {
    final gold = Theme.of(context).primaryColor;

    final cliente = _clienteNombre(item);
    final estrellas = _estrellas(item);
    final comentario = _texto(item['comentario'], 'Sin comentario');
    final fecha = _fecha(item['fecha'] ?? item['created_at']);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _verDetalle(item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.person, color: gold),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _stars(estrellas),
                    const SizedBox(height: 6),
                    Text(
                      comentario,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fecha,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resumenPromedio() {
    final gold = Theme.of(context).primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.star, color: gold, size: 34),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Promedio',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${promedio.toStringAsFixed(1)} / 5.0',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$total calificación${total == 1 ? '' : 'es'}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            _stars(promedio.round()),
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
        title: const Text('Calificaciones'),
        actions: [
          IconButton(
            onPressed: _cargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Icon(Icons.star_outline, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text(
              'Calificaciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Promedio y comentarios de usuarios.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            _resumenPromedio(),

            const SizedBox(height: 14),

            if (cargando)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    mensaje.isEmpty
                        ? 'Por el momento no tienes calificaciones.'
                        : mensaje,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Comentarios',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...items.map((item) {
                final map = Map<String, dynamic>.from(item as Map);
                return _calificacionCard(map);
              }),
            ],
          ],
        ),
      ),
    );
  }
}