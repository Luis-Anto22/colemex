import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../agente_imobiliario/api_service_inmobiliario.dart';

class CatalogoInmueblesScreen extends StatefulWidget {
  const CatalogoInmueblesScreen({super.key});

  @override
  State<CatalogoInmueblesScreen> createState() => _CatalogoInmueblesScreenState();
}

class _CatalogoInmueblesScreenState extends State<CatalogoInmueblesScreen> {
  static const Color _primary = Color(0xFF0B2545);
  static const Color _brown = Color(0xFF7C2D12);

  final TextEditingController _buscarController = TextEditingController();

  bool _cargando = true;
  bool _usandoUbicacion = false;

  List<dynamic> _inmuebles = [];

  String _tipoOperacion = 'todos';
  String _tipoInmueble = 'todos';
  double? _latitud;
  double? _longitud;

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  Future<void> _cargarCatalogo() async {
    setState(() => _cargando = true);

    try {
      final data = await ApiServiceInmobiliario.getCatalogoInmuebles(
        tipoOperacion: _tipoOperacion == 'todos' ? null : _tipoOperacion,
        tipoInmueble: _tipoInmueble == 'todos' ? null : _tipoInmueble,
        buscar: _buscarController.text.trim(),
        latitud: _latitud,
        longitud: _longitud,
        radioKm: _usandoUbicacion ? 30 : null,
      );

      if (!mounted) return;

      setState(() {
        _inmuebles = data;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar inmuebles: $e')),
      );
    }
  }

  Future<void> _activarUbicacion() async {
    try {
      final servicioActivo = await Geolocator.isLocationServiceEnabled();

      if (!servicioActivo) {
        _snack('Activa la ubicación del dispositivo.');
        return;
      }

      var permiso = await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        _snack('Permiso de ubicación denegado.');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitud = pos.latitude;
        _longitud = pos.longitude;
        _usandoUbicacion = true;
      });

      await _cargarCatalogo();
    } catch (e) {
      _snack('No se pudo obtener ubicación: $e');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  String _text(dynamic value, [String fallback = '']) {
    final txt = '${value ?? ''}'.trim();
    if (txt.isEmpty || txt == 'null') return fallback;
    return txt;
  }

  int _int(dynamic value) {
    return int.tryParse('${value ?? 0}') ?? 0;
  }

  double _double(dynamic value) {
    return double.tryParse('${value ?? 0}') ?? 0;
  }

  String _precio(dynamic inmueble) {
    final map = Map<String, dynamic>.from(inmueble as Map);
    final precio = _double(map['precio']);
    final operacion = _text(map['tipo_operacion'], 'venta');

    final value = precio.toStringAsFixed(0);
    final chars = value.split('').reversed.toList();
    final buffer = StringBuffer();

    for (int i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write(',');
      buffer.write(chars[i]);
    }

    final formatted = buffer.toString().split('').reversed.join();

    if (operacion == 'renta') return '\$$formatted / mes';
    return '\$$formatted';
  }

  String _labelOperacion(String value) {
    switch (value) {
      case 'venta':
        return 'Venta';
      case 'renta':
        return 'Renta';
      default:
        return 'Venta/Renta';
    }
  }

  String _labelTipo(String value) {
    switch (value) {
      case 'casa':
        return 'Casa';
      case 'departamento':
        return 'Departamento';
      case 'terreno':
        return 'Terreno';
      case 'local':
        return 'Local';
      case 'oficina':
        return 'Oficina';
      case 'bodega':
        return 'Bodega';
      default:
        return 'Todos';
    }
  }

  List<String> _fotos(Map<String, dynamic> inmueble) {
    final fotos = inmueble['fotos'];

    if (fotos is List) {
      return fotos
          .whereType<Map>()
          .map((e) => '${e['archivo_url'] ?? ''}')
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    return [];
  }

  Future<int?> _clienteId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  Future<String> _clienteNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nombre') ??
        prefs.getString('nombreUsuario') ??
        'Cliente interesado';
  }

  Future<void> _contactar(Map<String, dynamic> inmueble) async {
    final inmuebleId = _int(inmueble['id']);
    final clienteId = await _clienteId();
    final nombre = await _clienteNombre();

    if (inmuebleId <= 0) {
      _snack('Inmueble inválido.');
      return;
    }

    try {
      await ApiServiceInmobiliario.registrarProspecto(
        inmuebleId: inmuebleId,
        clienteId: clienteId,
        nombre: nombre,
        nivelInteres: 'alto',
        mensaje: 'Cliente interesado desde catálogo de inmuebles.',
      );

      _snack('Solicitud enviada al agente inmobiliario.');
    } catch (e) {
      _snack('No se pudo contactar al agente: $e');
    }
  }

  Future<void> _calificar(Map<String, dynamic> inmueble, int estrellas) async {
    final inmuebleId = _int(inmueble['id']);
    final clienteId = await _clienteId();

    if (clienteId == null) {
      _snack('No se pudo identificar al cliente.');
      return;
    }

    try {
      await ApiServiceInmobiliario.calificarInmueble(
        inmuebleId: inmuebleId,
        clienteId: clienteId,
        calificacion: estrellas,
        comentario: '',
      );

      _snack('Calificación guardada.');
      await _cargarCatalogo();
    } catch (e) {
      _snack('No se pudo calificar: $e');
    }
  }

  void _abrirDetalle(Map<String, dynamic> inmueble) {
    final fotos = _fotos(inmueble);
    int estrellas = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.55,
              maxChildSize: 0.96,
              builder: (_, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: SizedBox(
                          height: 230,
                          child: fotos.isEmpty
                              ? Container(
                                  color: _brown,
                                  child: const Icon(
                                    Icons.apartment_rounded,
                                    color: Colors.white,
                                    size: 90,
                                  ),
                                )
                              : PageView(
                                  children: fotos.map((url) {
                                    return Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) {
                                        return Container(
                                          color: _brown,
                                          child: const Icon(
                                            Icons.broken_image_rounded,
                                            color: Colors.white,
                                            size: 70,
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _text(inmueble['titulo'], 'Propiedad'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _precio(inmueble),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _brown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 18, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _text(inmueble['ubicacion'], 'Sin ubicación'),
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _infoPill(Icons.sell_rounded,
                              _labelOperacion(_text(inmueble['tipo_operacion']))),
                          _infoPill(Icons.home_work_rounded,
                              _labelTipo(_text(inmueble['tipo_inmueble']))),
                          _infoPill(Icons.bed_rounded,
                              '${_int(inmueble['recamaras'])} rec.'),
                          _infoPill(Icons.bathtub_rounded,
                              '${_int(inmueble['banos'])} baños'),
                          _infoPill(Icons.local_parking_rounded,
                              '${_int(inmueble['estacionamientos'])} estac.'),
                          _infoPill(Icons.star_rounded,
                              '${_double(inmueble['calificacion_promedio']).toStringAsFixed(1)} (${_int(inmueble['total_calificaciones'])})'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _text(inmueble['descripcion'], 'Sin descripción.'),
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Calificar propiedad',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          final value = index + 1;
                          return IconButton(
                            onPressed: () {
                              setSheetState(() => estrellas = value);
                            },
                            icon: Icon(
                              value <= estrellas
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: const Color(0xFFF59E0B),
                              size: 30,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _calificar(inmueble, estrellas),
                              icon: const Icon(Icons.star_rounded),
                              label: const Text('Calificar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _brown,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _contactar(inmueble),
                              icon: const Icon(Icons.message_rounded),
                              label: const Text('Contactar'),
                              style: FilledButton.styleFrom(
                                backgroundColor: _primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _infoPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _brown),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF334155),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: _primary.withOpacity(0.15),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? _primary : const Color(0xFF475569),
        fontWeight: FontWeight.w800,
      ),
      side: BorderSide(
        color: selected ? _primary.withOpacity(0.35) : Colors.black12,
      ),
    );
  }

  Widget _card(Map<String, dynamic> inmueble) {
    final fotos = _fotos(inmueble);
    final foto = fotos.isNotEmpty ? fotos.first : '';
    final titulo = _text(inmueble['titulo'], 'Propiedad');
    final ubicacion = _text(inmueble['ubicacion'], 'Sin ubicación');
    final operacion = _labelOperacion(_text(inmueble['tipo_operacion']));
    final tipo = _labelTipo(_text(inmueble['tipo_inmueble']));
    final distancia = _double(inmueble['distancia_km']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _abrirDetalle(inmueble),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: foto.isEmpty
                    ? Container(
                        color: _brown,
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: Colors.white,
                          size: 70,
                        ),
                      )
                    : Image.network(
                        foto,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: _brown,
                            child: const Icon(
                              Icons.broken_image_rounded,
                              color: Colors.white,
                              size: 60,
                            ),
                          );
                        },
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _infoPill(Icons.sell_rounded, operacion),
                      _infoPill(Icons.home_work_rounded, tipo),
                      if (_usandoUbicacion && distancia > 0)
                        _infoPill(
                          Icons.near_me_rounded,
                          '${distancia.toStringAsFixed(1)} km',
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _precio(inmueble),
                    style: const TextStyle(
                      fontSize: 18,
                      color: _brown,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ubicacion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFF59E0B), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${_double(inmueble['calificacion_promedio']).toStringAsFixed(1)}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Text(
                        '${_int(inmueble['recamaras'])} rec · ${_int(inmueble['banos'])} baños',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtros() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _buscarController,
            onSubmitted: (_) => _cargarCatalogo(),
            decoration: InputDecoration(
              hintText: 'Buscar por zona, colonia o propiedad...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                onPressed: _cargarCatalogo,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(
                  label: 'Todos',
                  selected: _tipoOperacion == 'todos',
                  onTap: () {
                    setState(() => _tipoOperacion = 'todos');
                    _cargarCatalogo();
                  },
                ),
                _chip(
                  label: 'Venta',
                  selected: _tipoOperacion == 'venta',
                  onTap: () {
                    setState(() => _tipoOperacion = 'venta');
                    _cargarCatalogo();
                  },
                ),
                _chip(
                  label: 'Renta',
                  selected: _tipoOperacion == 'renta',
                  onTap: () {
                    setState(() => _tipoOperacion = 'renta');
                    _cargarCatalogo();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(
                  label: 'Todos',
                  selected: _tipoInmueble == 'todos',
                  onTap: () {
                    setState(() => _tipoInmueble = 'todos');
                    _cargarCatalogo();
                  },
                ),
                _chip(
                  label: 'Casa',
                  selected: _tipoInmueble == 'casa',
                  onTap: () {
                    setState(() => _tipoInmueble = 'casa');
                    _cargarCatalogo();
                  },
                ),
                _chip(
                  label: 'Departamento',
                  selected: _tipoInmueble == 'departamento',
                  onTap: () {
                    setState(() => _tipoInmueble = 'departamento');
                    _cargarCatalogo();
                  },
                ),
                _chip(
                  label: 'Terreno',
                  selected: _tipoInmueble == 'terreno',
                  onTap: () {
                    setState(() => _tipoInmueble = 'terreno');
                    _cargarCatalogo();
                  },
                ),
                _chip(
                  label: 'Local',
                  selected: _tipoInmueble == 'local',
                  onTap: () {
                    setState(() => _tipoInmueble = 'local');
                    _cargarCatalogo();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _activarUbicacion,
              icon: const Icon(Icons.my_location_rounded),
              label: Text(
                _usandoUbicacion
                    ? 'Mostrando propiedades cercanas'
                    : 'Usar mi ubicación para ver cercanos',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: _primary),
      );
    }

    if (_inmuebles.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargarCatalogo,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _filtros(),
            const SizedBox(height: 60),
            const Icon(
              Icons.apartment_rounded,
              size: 70,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            const Text(
              'No hay propiedades disponibles',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Prueba cambiando filtros o desactivando ubicación.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarCatalogo,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          _filtros(),
          const SizedBox(height: 14),
          Text(
            '${_inmuebles.length} propiedades disponibles',
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ..._inmuebles.whereType<Map>().map((e) {
            return _card(Map<String, dynamic>.from(e));
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Catálogo inmobiliario',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _cargarCatalogo,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _contenido(),
    );
  }
}