<<<<<<< Updated upstream
import 'package:flutter/material.dart';

class PanelServicios extends StatelessWidget {
  const PanelServicios({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Servicios próximamente...'),
    );
  }
}
=======
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services/cliente_profesionales_api.dart';
import 'servicio_selector.dart';

class PanelServicios extends StatefulWidget {
  final List<String> serviciosDisponibles;
  final String? servicioSeleccionado;
  final String? especialidadBusqueda;
  final ValueChanged<String> onSeleccionarServicio;

  const PanelServicios({
    super.key,
    required this.serviciosDisponibles,
    required this.servicioSeleccionado,
    required this.especialidadBusqueda,
    required this.onSeleccionarServicio,
  });

  @override
  State<PanelServicios> createState() => _PanelServiciosState();
}

class _PanelServiciosState extends State<PanelServicios> {
  static const Color _primary = Color(0xFF0B2545);
  static const List<String> _especialidadesLegalesFallback = [
    'Derecho Civil',
    'Derecho Penal',
    'Derecho Familiar',
    'Derecho Laboral',
    'Derecho Mercantil / Corporativo',
    'Derecho Fiscal / Tributario',
    'Derecho Administrativo',
    'Derecho Constitucional',
    'Derecho Agrario',
    'Derecho Inmobiliario',
    'Derecho Migratorio',
    'Derecho Internacional',
    'Derecho Bancario y Financiero',
    'Derecho de Propiedad Intelectual',
    'Derecho Digital / Tecnológico',
    'Derecho Ambiental',
    'Derecho Aduanero',
    'Derecho Electoral',
    'Derecho de Seguridad Social',
    'Derecho Médico',
    'Derecho Energético',
    'Derecho de Amparo',
    'Derecho de Seguros',
    'Derecho de Consumidor',
  ];

  final ClienteProfesionalesApi _api = ClienteProfesionalesApi();
  final Distance _distance = const Distance();
  bool _cargando = false;
  bool _enviandoSolicitud = false;
  bool _cargandoEspecialidadesAbogado = false;
  List<String> _especialidadesAbogado = [];
  String _especialidadAbogado = '';
  String _mensaje = '';
  LatLng? _ubicacionCliente;
  List<Map<String, dynamic>> _profesionales = [];

  @override
  void initState() {
    super.initState();
    _cargarEspecialidadesAbogado();
    _cargarSiHayServicio();
  }

  @override
  void didUpdateWidget(covariant PanelServicios oldWidget) {
    super.didUpdateWidget(oldWidget);
    final servicio = widget.servicioSeleccionado?.trim() ?? '';
    if (_esServicioAbogados(servicio)) {
      final especialidadInicio = widget.especialidadBusqueda?.trim() ?? '';
      if (especialidadInicio.isNotEmpty &&
          especialidadInicio != _especialidadAbogado) {
        _especialidadAbogado = especialidadInicio;
      }
    }
    if (widget.servicioSeleccionado != oldWidget.servicioSeleccionado ||
        widget.especialidadBusqueda != oldWidget.especialidadBusqueda) {
      _cargarSiHayServicio();
    }
  }

  bool _esServicioAbogados(String servicio) {
    return servicio.toLowerCase().trim() == 'abogados';
  }

  String _normalizarServicio(String servicio) {
    return servicio
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
  }

  IconData _iconoServicio(String servicio) {
    switch (_normalizarServicio(servicio)) {
      case 'abogados':
      case 'abogado':
        return Icons.gavel_rounded;

      case 'ajustadores':
      case 'ajustador':
        return Icons.health_and_safety_rounded;

      case 'peritos en criminalistica':
      case 'perito en criminalistica':
        return Icons.fingerprint_rounded;

      case 'valuadores':
      case 'valuador':
        return Icons.home_work_rounded;

      case 'investigadores':
      case 'investigador':
        return Icons.search_rounded;

      case 'psicologos':
      case 'psicologo':
        return Icons.psychology_rounded;

      case 'agentes inmobiliarios':
      case 'agente inmobiliario':
        return Icons.apartment_rounded;

      case 'contadores':
      case 'contador':
        return Icons.calculate_rounded;

      case 'agentes crediticios':
      case 'agente crediticio':
        return Icons.account_balance_wallet_rounded;

      /// 🚗 NUEVO SERVICIO
      case 'asistencia vial':
      case 'asistencia_vial':
        return Icons.car_repair_rounded;

      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  Widget _infoChip({
    required IconData icono,
    required String texto,
    Color iconoColor = const Color(0xFF334155),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: iconoColor),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtroChip({
    required IconData icono,
    required String texto,
    Color fondo = const Color(0xFFE8F0FF),
    Color colorTexto = _primary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: colorTexto),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              texto,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorTexto,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cargarEspecialidadesAbogado() async {
    if (mounted) {
      setState(() {
        _cargandoEspecialidadesAbogado = true;
      });
    }

    try {
      // API (via ClienteProfesionalesApi.getEspecialidades):
      // GET /common/especialidades.php
      final items = await _api.getEspecialidades(limit: 200);
      var legales = items
          .where((e) =>
              e.toLowerCase().contains('derecho') ||
              e.toLowerCase().contains('amparo'))
          .toSet()
          .toList()
        ..sort();
      if (legales.isEmpty) {
        legales = [..._especialidadesLegalesFallback];
      }

      if (!mounted) return;
      setState(() {
        _especialidadesAbogado = legales;
        final especialidadInicio = widget.especialidadBusqueda?.trim() ?? '';
        if (especialidadInicio.isNotEmpty) {
          _especialidadAbogado = especialidadInicio;
        } else if (_especialidadAbogado.isNotEmpty &&
            !_especialidadesAbogado.contains(_especialidadAbogado)) {
          _especialidadAbogado = '';
        }
        _cargandoEspecialidadesAbogado = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _especialidadesAbogado = [..._especialidadesLegalesFallback];
        final especialidadInicio = widget.especialidadBusqueda?.trim() ?? '';
        if (especialidadInicio.isNotEmpty) {
          _especialidadAbogado = especialidadInicio;
        }
        _cargandoEspecialidadesAbogado = false;
      });
    }
  }

  Future<void> _abrirSelectorEspecialidadAbogado() async {
    if (_cargandoEspecialidadesAbogado) return;
    final buscadorController = TextEditingController();
    try {
      final seleccion = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          var filtro = '';

          return StatefulBuilder(
            builder: (context, setSheetState) {
              final especialidadesFiltradas = _especialidadesAbogado
                  .where(
                    (e) =>
                        e.toLowerCase().contains(filtro.toLowerCase().trim()),
                  )
                  .toList();

              return Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                child: SafeArea(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.82,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFDDE6F2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Especialidad para abogados',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: buscadorController,
                            onChanged: (value) {
                              setSheetState(() {
                                filtro = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Buscar especialidad...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: filtro.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        buscadorController.clear();
                                        setSheetState(() {
                                          filtro = '';
                                        });
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                            children: [
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                title: const Text('Todas las especialidades'),
                                leading: const Icon(
                                  Icons.clear_all_rounded,
                                  color: Color(0xFF475569),
                                ),
                                trailing: _especialidadAbogado.isEmpty
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: _primary,
                                      )
                                    : null,
                                onTap: () => Navigator.of(context).pop(''),
                              ),
                              if (especialidadesFiltradas.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 20,
                                  ),
                                  child: Text(
                                    'No hay especialidades con ese nombre.',
                                    style: TextStyle(color: Color(0xFF64748B)),
                                  ),
                                )
                              else
                                ...especialidadesFiltradas.map(
                                  (especialidad) => ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    title: Text(especialidad),
                                    trailing:
                                        _especialidadAbogado == especialidad
                                            ? const Icon(
                                                Icons.check_circle_rounded,
                                                color: _primary,
                                              )
                                            : null,
                                    onTap: () =>
                                        Navigator.of(context).pop(especialidad),
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
            },
          );
        },
      );

      if (!mounted || seleccion == null) return;
      setState(() {
        _especialidadAbogado = seleccion.trim();
      });
      _cargarSiHayServicio();
    } finally {
      buscadorController.dispose();
    }
  }

  String _especialidadFiltroActual(String servicio) {
    final especialidadGlobal = widget.especialidadBusqueda?.trim() ?? '';
    if (_esServicioAbogados(servicio)) {
      if (_especialidadAbogado.trim().isNotEmpty) {
        return _especialidadAbogado.trim();
      }
    }
    return especialidadGlobal;
  }

  Future<void> _cargarSiHayServicio() async {
    final servicio = widget.servicioSeleccionado?.trim() ?? '';
    final especialidad = _especialidadFiltroActual(servicio);

    if (servicio.isEmpty && especialidad.isEmpty) {
      if (mounted) {
        setState(() {
          _profesionales = [];
          _mensaje = '';
        });
      }
      return;
    }
    await _cargarProfesionales();
  }

  Future<void> _cargarProfesionales() async {
    final servicio = widget.servicioSeleccionado?.trim() ?? '';
    final especialidad = _especialidadFiltroActual(servicio);
    if (servicio.isEmpty && especialidad.isEmpty) return;

    setState(() {
      _cargando = true;
      _mensaje = '';
      _profesionales = [];
      _ubicacionCliente = null;
    });

    final ubicacion = await _obtenerUbicacion();
    if (!mounted) return;
    if (ubicacion == null) {
      setState(() {
        _cargando = false;
      });
      return;
    }

    _ubicacionCliente = ubicacion;

    try {
      // API (via ClienteProfesionalesApi.getProfesionalesCercanos):
      // GET /common/profesionales_cercanos.php
      final data = await _api.getProfesionalesCercanos(
        perfil: servicio.isEmpty ? null : servicio,
        especialidad: especialidad.isEmpty ? null : especialidad,
        lat: ubicacion.latitude,
        lng: ubicacion.longitude,
        limit: 50,
      );

      _profesionales = data;
      _ordenarPorDistancia();

      if (_profesionales.isEmpty) {
        _mensaje = 'No hay profesionales disponibles para el filtro indicado.';
      }
    } catch (_) {
      _mensaje = 'Error al cargar profesionales.';
    }

    if (mounted) {
      setState(() {
        _cargando = false;
      });
    }
  }

  void _ordenarPorDistancia() {
    _profesionales.sort((a, b) {
      final da = _distanciaKm(a) ?? double.infinity;
      final db = _distanciaKm(b) ?? double.infinity;
      return da.compareTo(db);
    });
  }

  Future<LatLng?> _obtenerUbicacion() async {
    final servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      _mensaje = 'Servicio de ubicacion desactivado.';
      return null;
    }

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      _mensaje = 'Permiso de ubicacion denegado.';
      return null;
    }

    final posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(posicion.latitude, posicion.longitude);
  }

  double? _distanciaKm(Map<String, dynamic> profesional) {
    final raw = profesional['distancia_km'];
    final parsed = raw != null ? double.tryParse(raw.toString()) : null;
    if (parsed != null) return parsed;

    if (_ubicacionCliente == null) return null;
    final lat = double.tryParse(profesional['latitude']?.toString() ?? '');
    final lng = double.tryParse(profesional['longitude']?.toString() ?? '');
    if (lat == null || lng == null) return null;
    return _distance.as(
      LengthUnit.Kilometer,
      _ubicacionCliente!,
      LatLng(lat, lng),
    );
  }

  Future<int?> _obtenerClienteId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    if (id == null || id <= 0) return null;
    return id;
  }

  Future<void> _mostrarDialogoSolicitud(
    Map<String, dynamic> profesional,
  ) async {
    final servicioSeleccionado = widget.servicioSeleccionado?.trim() ?? '';
    final servicioPerfil = (profesional['perfil']?.toString() ?? '').trim();
    final servicio =
        servicioSeleccionado.isNotEmpty ? servicioSeleccionado : servicioPerfil;

    if (servicio.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo determinar el servicio.')),
      );
      return;
    }

    final profesionalId = int.tryParse(profesional['id']?.toString() ?? '');
    if (profesionalId == null || profesionalId <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profesional invalido.')),
      );
      return;
    }

    final nombre = profesional['nombre']?.toString() ?? 'Profesional';
    final tituloController = TextEditingController(
      text: 'Solicitud de $servicio',
    );
    final descripcionController = TextEditingController();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enviar solicitud'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Se enviara una solicitud de caso a $nombre para que la acepte o rechace.',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Titulo del caso',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descripcionController,
                  minLines: 3,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripcion (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      tituloController.dispose();
      descripcionController.dispose();
      return;
    }

    final titulo = tituloController.text.trim();
    final descripcion = descripcionController.text.trim();
    tituloController.dispose();
    descripcionController.dispose();

    if (titulo.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El titulo es obligatorio.')),
      );
      return;
    }

    final clienteId = await _obtenerClienteId();
    if (clienteId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar al cliente.')),
      );
      return;
    }

    setState(() {
      _enviandoSolicitud = true;
    });

    try {
      // API (via ClienteProfesionalesApi.solicitarCaso):
      // POST /common/solicitar_caso_cliente.php
      final resp = await _api.solicitarCaso(
        clienteId: clienteId,
        profesionalId: profesionalId,
        servicio: servicio,
        titulo: titulo,
        descripcion: descripcion,
      );

      if (!mounted) return;
      final creado = resp['creado'] == true;
      final message = resp['message']?.toString() ??
          (creado
              ? 'Solicitud enviada correctamente.'
              : 'Solicitud registrada.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              creado ? const Color(0xFF166534) : const Color(0xFF9A3412),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo enviar la solicitud: $e'),
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviandoSolicitud = false;
        });
      }
    }
  }

  void _mostrarDetalle(Map<String, dynamic> profesional) {
    final nombre = profesional['nombre']?.toString() ?? 'Profesional';
    final especialidad = profesional['especialidad']?.toString() ?? '';
    final estado = profesional['estado']?.toString() ?? 'disponible';
    final distancia = _distanciaKm(profesional);
    final rating =
        double.tryParse(profesional['rating_promedio']?.toString() ?? '') ??
            0.0;
    final totalCalificaciones =
        int.tryParse(profesional['total_calificaciones']?.toString() ?? '') ??
            0;
    final ratingTexto = totalCalificaciones > 0
        ? '${rating.toStringAsFixed(1)} ($totalCalificaciones)'
        : 'Sin calificacion';
    final distanciaTexto = distancia != null
        ? '${distancia.toStringAsFixed(2)} km'
        : 'Distancia N/D';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
                if (especialidad.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      especialidad,
                      style: const TextStyle(color: Color(0xFF475569)),
                    ),
                  ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _estadoChip(estado),
                    _infoChip(
                      icono: Icons.star_rounded,
                      texto: ratingTexto,
                      iconoColor: const Color(0xFFF59E0B),
                    ),
                    _infoChip(
                      icono: Icons.near_me_rounded,
                      texto: distanciaTexto,
                      iconoColor: const Color(0xFF2563EB),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _enviandoSolicitud
                        ? null
                        : () => _mostrarDialogoSolicitud(profesional),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    icon: const Icon(Icons.assignment_rounded),
                    label: Text(
                      _enviandoSolicitud
                          ? 'Enviando solicitud...'
                          : 'Enviar solicitud',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'disponible':
        return const Color(0xFF15803D);
      case 'ocupado':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFFDC2626);
    }
  }

  String _textoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'disponible':
        return 'Disponible';
      case 'ocupado':
        return 'Ocupado';
      default:
        return 'Fuera de servicio';
    }
  }

  Widget _estadoChip(String estado) {
    final color = _colorEstado(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _textoEstado(estado),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _mensajeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        border: Border.all(color: const Color(0xFFF7B5B5)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE3E3),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFB91C1C),
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _mensaje,
              style: const TextStyle(
                color: Color(0xFFB91C1C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadoVacio({
    required IconData icono,
    required String titulo,
    required String subtitulo,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.hasBoundedHeight && constraints.maxHeight < 190;
        final iconSize = compact ? 30.0 : 44.0;
        final titleSize = compact ? 14.5 : 17.0;
        final subtitleSize = compact ? 12.5 : 14.0;
        final padding = compact ? 12.0 : 24.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDDE6F2)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icono, size: iconSize, color: const Color(0xFF64748B)),
                SizedBox(height: compact ? 8 : 12),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF475569),
                    height: 1.3,
                    fontSize: subtitleSize,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _abrirMapaPantallaCompleta() async {
    final cliente = _ubicacionCliente;
    if (cliente == null) return;

    // El mapa se abre en otra pantalla para mejorar visibilidad y navegacion.
    final seleccionado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => _MapaProfesionalesFullScreen(
          ubicacionCliente: cliente,
          profesionales: _profesionales,
          servicioSeleccionado: widget.servicioSeleccionado?.trim() ?? '',
          iconoServicioBuilder: _iconoServicio,
          colorEstadoBuilder: _colorEstado,
        ),
      ),
    );

    if (!mounted || seleccionado == null) return;
    _mostrarDetalle(seleccionado);
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final servicioSel = widget.servicioSeleccionado?.trim() ?? '';
    final especialidadSelGlobal = widget.especialidadBusqueda?.trim() ?? '';
    final especialidadSelActiva = _especialidadFiltroActual(servicioSel);
    final esAbogados = _esServicioAbogados(servicioSel);
    final tieneFiltro =
        servicioSel.isNotEmpty || especialidadSelActiva.isNotEmpty;
    final isSmallPhone = screen.width < 380 || screen.height < 700;
    final hPad = isSmallPhone ? 12.0 : 16.0;
    final titleSize = isSmallPhone ? 16.0 : 17.0;

    return Column(
      children: [
        if (tieneFiltro)
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: _primary,
                  ),
                  onPressed: () {
                    widget.onSeleccionarServicio('');
                    setState(() {
                      _especialidadAbogado = '';
                      _profesionales = [];
                      _mensaje = '';
                    });
                  },
                ),
                const SizedBox(width: 4),
                const Text(
                  'Servicios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, isSmallPhone ? 8 : 10),
          child: Container(
            padding: EdgeInsets.all(isSmallPhone ? 12 : 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFDFEFF), Color(0xFFF1F6FF)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFDDE6F2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.045),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4EDFA),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.travel_explore_rounded,
                        color: _primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Encuentra profesionales cercanos',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: _primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Selecciona un servicio y/o usa la especialidad para filtrar profesionales.',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    height: 1.3,
                    fontSize: isSmallPhone ? 12.8 : 14,
                  ),
                ),
                if (tieneFiltro) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (servicioSel.isNotEmpty)
                        _filtroChip(
                          icono: _iconoServicio(servicioSel),
                          texto: servicioSel,
                        ),
                      if (especialidadSelActiva.isNotEmpty)
                        _filtroChip(
                          icono: Icons.balance_rounded,
                          texto: especialidadSelActiva,
                          fondo: const Color(0xFFEAF7EC),
                          colorTexto: const Color(0xFF0F5132),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                ServicioSelector(
                  servicios: widget.serviciosDisponibles,
                  seleccionado: widget.servicioSeleccionado,
                  onSeleccionar: widget.onSeleccionarServicio,
                ),
                if (esAbogados) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Especialidad para abogados',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_cargandoEspecialidadesAbogado)
                    const SizedBox(
                      height: 36,
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else
                    InkWell(
                      onTap: _abrirSelectorEspecialidadAbogado,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFC6D4E6)),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.balance_rounded,
                              size: 18,
                              color: Color(0xFF475569),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _especialidadAbogado.isEmpty
                                    ? 'Todas las especialidades'
                                    : _especialidadAbogado,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _especialidadAbogado.isEmpty
                                      ? const Color(0xFF64748B)
                                      : _primary,
                                  fontWeight: _especialidadAbogado.isEmpty
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF475569),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                if (!esAbogados && especialidadSelGlobal.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Filtro recibido desde Inicio.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!tieneFiltro)
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, hPad),
              child: _estadoVacio(
                icono: Icons.travel_explore_rounded,
                titulo: 'Elige un servicio o una especialidad',
                subtitulo:
                    'Mostraremos en el mapa a los profesionales mas cercanos que coincidan con tu filtro.',
              ),
            ),
          )
        else ...[
          if (_cargando)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          if (_mensaje.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
              child: _mensajeBanner(),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, isSmallPhone ? 8 : 10, hPad, 0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD8E3F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.map_rounded,
                        color: _primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mapa de profesionales cercanos',
                          style: TextStyle(
                            fontSize: isSmallPhone ? 14.5 : 15.5,
                            color: _primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${_profesionales.length} cercanos',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Para mejor visibilidad, el mapa se abre en pantalla completa.',
                    style: TextStyle(
                      color: const Color(0xFF475569),
                      fontSize: isSmallPhone ? 12.6 : 13.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _ubicacionCliente == null
                          ? null
                          : _abrirMapaPantallaCompleta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 46),
                      ),
                      icon: const Icon(Icons.fullscreen),
                      label: Text(
                        servicioSel.isNotEmpty
                            ? 'Abrir mapa de $servicioSel'
                            : 'Abrir mapa en pantalla completa',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_profesionales.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, hPad),
              child: _estadoVacio(
                icono: Icons.touch_app_rounded,
                titulo: 'Abre el mapa completo y toca un pin',
                subtitulo:
                    'Al seleccionar un marcador se abre la ficha del profesional para solicitar caso.',
              ),
            ),
        ],
      ],
    );
  }
}

class _MapaProfesionalesFullScreen extends StatelessWidget {
  final LatLng ubicacionCliente;
  final List<Map<String, dynamic>> profesionales;
  final String servicioSeleccionado;
  final IconData Function(String servicio) iconoServicioBuilder;
  final Color Function(String estado) colorEstadoBuilder;

  const _MapaProfesionalesFullScreen({
    required this.ubicacionCliente,
    required this.profesionales,
    required this.servicioSeleccionado,
    required this.iconoServicioBuilder,
    required this.colorEstadoBuilder,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0B2545);
    final tagText = servicioSeleccionado.isNotEmpty
        ? servicioSeleccionado
        : 'Profesionales cercanos';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de servicios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: ubicacionCliente,
                initialZoom: 13,
                minZoom: 5,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.advocatus.app',
                  maxZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: ubicacionCliente,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFF1D4ED8),
                        size: 34,
                      ),
                    ),
                    ...profesionales.map((p) {
                      final lat =
                          double.tryParse(p['latitude']?.toString() ?? '');
                      final lng =
                          double.tryParse(p['longitude']?.toString() ?? '');
                      if (lat == null || lng == null) return null;

                      final estado = p['estado']?.toString() ?? 'disponible';
                      final perfilRaw = p['perfil']?.toString().trim() ?? '';
                      final perfil = perfilRaw.isNotEmpty
                          ? perfilRaw
                          : servicioSeleccionado;

                      return Marker(
                        point: LatLng(lat, lng),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(p),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorEstadoBuilder(estado),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              iconoServicioBuilder(perfil),
                              color: colorEstadoBuilder(estado),
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    }).whereType<Marker>(),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFD6E1EF)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    servicioSeleccionado.isNotEmpty
                        ? iconoServicioBuilder(servicioSeleccionado)
                        : Icons.pin_drop_rounded,
                    size: 14,
                    color: primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tagText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${profesionales.length} cercanos',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              top: false,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.93),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Toca un marcador para abrir la ficha del profesional.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
>>>>>>> Stashed changes
