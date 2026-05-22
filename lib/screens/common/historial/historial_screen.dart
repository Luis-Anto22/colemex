import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/common_api.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final CommonApi api = CommonApi(ApiClient());

  bool cargando = true;
  String mensaje = '';
  List<dynamic> items = [];

  int profesionalId = 0;
  String perfil = '';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();

    profesionalId = prefs.getInt('id') ?? 0;
    perfil = (prefs.getString('perfil') ?? '').trim();

    if (profesionalId <= 0) {
      setState(() {
        cargando = false;
        mensaje = 'ID no válido';
      });
      return;
    }

    try {
      final data = await api.getHistorial(
        profesionalId: profesionalId,
        perfil: perfil,
      );

      if (!mounted) return;

      setState(() {
        items = data;
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

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  String _texto(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _clienteNombre(Map<String, dynamic> item) {
    if (item['cliente_nombre'] != null) {
      return _texto(item['cliente_nombre'], 'Cliente no especificado');
    }

    final cliente = _asMap(item['cliente']);

    if (cliente['nombre'] != null) {
      return _texto(cliente['nombre'], 'Cliente no especificado');
    }

    if (item['cliente_id'] != null) {
      return 'Cliente #${item['cliente_id']}';
    }

    return 'Cliente no especificado';
  }

  String _tituloCaso(Map<String, dynamic> item) {
    final titulo = _texto(item['titulo']);
    if (titulo.isNotEmpty) return titulo;

    final servicio = _texto(item['servicio']);
    if (servicio.isNotEmpty) return 'Solicitud de $servicio';

    return 'Servicio';
  }

  String _servicio(Map<String, dynamic> item) {
  final servicio = _texto(item['servicio']);
  if (servicio.isNotEmpty) return servicio;

  final tipoAuxilio = _asMap(item['tipo_auxilio']);
  final nombreTipo = _texto(tipoAuxilio['nombre']);

  if (nombreTipo.isNotEmpty) return nombreTipo;

  return 'Servicio no especificado';
}

  String _estado(Map<String, dynamic> item) {
    return _texto(item['estado'], 'sin estado');
  }

  String _descripcion(Map<String, dynamic> item) {
    final descripcion = _texto(item['descripcion']);
    if (descripcion.isNotEmpty) return descripcion;

    final detalle = _texto(item['detalle']);
    if (detalle.isNotEmpty) return detalle;

    final ubicacion = _texto(item['ubicacion']);
    if (ubicacion.isNotEmpty) return 'Ubicación: $ubicacion';

    final estadoAnterior = _texto(item['estado_anterior']);
    final estadoNuevo = _texto(item['estado_nuevo']);

    if (estadoAnterior.isNotEmpty || estadoNuevo.isNotEmpty) {
      return 'Estado: $estadoAnterior → $estadoNuevo';
    }

    return '';
  }

  String _fecha(Map<String, dynamic> item) {
  final posibles = [
    item['fecha_finalizacion'],
    item['fecha_solicitud'],
    item['inicio'],
    item['fecha_creacion'],
    item['created_at'],
    item['creado_en'],
    item['fecha'],
  ];

  for (final value in posibles) {
    final text = _texto(value);
    if (text.isNotEmpty) {
      return _fmtFecha(text);
    }
  }

  return 'Fecha no disponible';
}

  String _fmtFecha(String value) {
    final raw = value.trim().replaceFirst('T', ' ');

    if (raw.length >= 16) {
      return raw.substring(0, 16);
    }

    return raw;
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
      case 'confirmada':
        return Colors.blue;
      case 'finalizado':
      case 'finalizada':
      case 'completada':
      case 'completado':
        return Colors.green;
      case 'cancelado':
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _labelEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'en proceso':
      case 'confirmada':
        return 'En proceso';
      case 'finalizado':
      case 'finalizada':
      case 'completada':
      case 'completado':
        return 'Finalizado';
      case 'cancelado':
      case 'cancelada':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  void _verDetalle(Map<String, dynamic> item) {
    final titulo = _tituloCaso(item);
    final cliente = _clienteNombre(item);
    final servicio = _servicio(item);
    final estado = _estado(item);
    final fecha = _fecha(item);
    final descripcion = _descripcion(item);
    final ubicacion = _texto(item['ubicacion']);
    final estadoAnterior = _texto(item['estado_anterior']);
    final estadoNuevo = _texto(item['estado_nuevo']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        final colorEstado = _colorEstado(estado);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.folder_open,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          titulo,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _labelEstado(estado),
                      style: TextStyle(
                        color: colorEstado,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _detalleLinea(Icons.person_outline, 'Cliente', cliente),
                  _detalleLinea(
                    Icons.miscellaneous_services_outlined,
                    'Servicio',
                    servicio,
                  ),
                  _detalleLinea(Icons.calendar_today_outlined, 'Fecha', fecha),
                  if (ubicacion.isNotEmpty)
                    _detalleLinea(Icons.location_on_outlined, 'Ubicación', ubicacion),
                  if (estadoAnterior.isNotEmpty || estadoNuevo.isNotEmpty)
                    _detalleLinea(
                      Icons.compare_arrows,
                      'Cambio de estado',
                      '$estadoAnterior → $estadoNuevo',
                    ),
                  if (descripcion.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      descripcion,
                      style: const TextStyle(height: 1.35),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detalleLinea(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
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
      ),
    );
  }

  Widget _historialCard(Map<String, dynamic> item) {
    final titulo = _tituloCaso(item);
    final cliente = _clienteNombre(item);
    final servicio = _servicio(item);
    final estado = _estado(item);
    final fecha = _fecha(item);
    final descripcion = _descripcion(item);
    final colorEstado = _colorEstado(estado);
    final gold = Theme.of(context).primaryColor;

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
              Icon(Icons.folder_open, color: gold),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cliente: $cliente',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Servicio: $servicio',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Fecha: $fecha',
                      style: const TextStyle(fontSize: 13),
                    ),
                    if (descripcion.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _labelEstado(estado),
                  style: TextStyle(
                    color: colorEstado,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de servicios'),
        actions: [
          IconButton(
            onPressed: _cargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.history, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text(
              'Historial',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Servicios anteriores, cierres y detalles.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (cargando)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    mensaje.isEmpty ? 'Sin historial.' : mensaje,
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final item = _asMap(items[i]);
                      return _historialCard(item);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}