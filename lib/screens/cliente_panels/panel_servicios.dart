import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services/cliente_profesionales_api.dart';
import 'catalogo_inmuebles_screen.dart';
import 'profesionales_mapa_fullscreen.dart';
import 'solicitar_asistencia_vial_screen.dart';

enum _OpcionAbogado {
  todos,
  especialidad,
}

class PanelServicios extends StatefulWidget {
  final String nombreUsuario;
  final List<String> serviciosDisponibles;
  final String? servicioSeleccionado;
  final String? especialidadBusqueda;
  final ValueChanged<String> onSeleccionarServicio;

  const PanelServicios({
    super.key,
    required this.nombreUsuario,
    required this.serviciosDisponibles,
    required this.servicioSeleccionado,
    required this.especialidadBusqueda,
    required this.onSeleccionarServicio,
  });

  @override
  State<PanelServicios> createState() => _PanelServiciosState();
}

class _PanelServiciosState extends State<PanelServicios> {
  static const Color _bg = Color(0xFF050B14);
  static const Color _card = Color(0xFF111B28);
  static const Color _gold = Color(0xFFD6A84F);
  static const Color _red = Color(0xFFB8322D);

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
  bool _mapaAutoAbierto = false;
  bool _esperandoEspecialidadAbogado = false;

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
      _mapaAutoAbierto = false;
      _cargarSiHayServicio();
    }
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

  bool _esServicioAbogados(String servicio) {
    final s = _normalizarServicio(servicio);
    return s == 'abogados' || s == 'abogado';
  }

  bool _esAsistenciaVial(String servicio) {
    final s = _normalizarServicio(servicio);
    return s == 'asistencia vial' || s == 'asistencia_vial';
  }

  bool _esAgenteInmobiliario(String servicio) {
    final s = _normalizarServicio(servicio);
    return s == 'agente inmobiliario' || s == 'agentes inmobiliarios';
  }

  IconData _iconoServicio(String servicio) {
    switch (_normalizarServicio(servicio)) {
      case 'abogados':
      case 'abogado':
        return Icons.balance_rounded;
      case 'ajustadores':
      case 'ajustador':
        return Icons.directions_car_filled_rounded;
      case 'peritos en criminalistica':
      case 'perito en criminalistica':
        return Icons.manage_search_rounded;
      case 'valuadores':
      case 'valuador':
        return Icons.real_estate_agent_rounded;
      case 'investigadores':
      case 'investigador':
        return Icons.travel_explore_rounded;
      case 'psicologos':
      case 'psicologo':
        return Icons.psychology_alt_rounded;
      case 'agentes inmobiliarios':
      case 'agente inmobiliario':
        return Icons.home_work_rounded;
      case 'contadores':
      case 'contador':
        return Icons.calculate_rounded;
      case 'agentes crediticios':
      case 'agente crediticio':
        return Icons.account_balance_wallet_rounded;
      case 'asistencia vial':
      case 'asistencia_vial':
        return Icons.car_repair_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  Color _colorServicio(String servicio) {
    switch (_normalizarServicio(servicio)) {
      case 'abogados':
      case 'abogado':
        return const Color(0xFFD6A84F);
      case 'ajustadores':
      case 'ajustador':
        return const Color(0xFF54C26B);
      case 'peritos en criminalistica':
      case 'perito en criminalistica':
        return const Color(0xFF5D93FF);
      case 'valuadores':
      case 'valuador':
        return const Color(0xFF49C591);
      case 'investigadores':
      case 'investigador':
        return const Color(0xFF5D93FF);
      case 'psicologos':
      case 'psicologo':
        return const Color(0xFF9B5CFF);
      case 'agentes inmobiliarios':
      case 'agente inmobiliario':
        return const Color(0xFF49C591);
      case 'contadores':
      case 'contador':
        return const Color(0xFF9B5CFF);
      case 'agentes crediticios':
      case 'agente crediticio':
        return const Color(0xFF59C37A);
      case 'asistencia vial':
      case 'asistencia_vial':
        return const Color(0xFFE59A36);
      default:
        return _gold;
    }
  }

  String _nombreCortoServicio(String servicio) {
    switch (_normalizarServicio(servicio)) {
      case 'peritos en criminalistica':
        return 'Peritos';
      case 'agentes inmobiliarios':
        return 'Inmobiliario';
      case 'agentes crediticios':
        return 'Agentes\nCrediticios';
      case 'asistencia vial':
        return 'Asistencia\nVial';
      default:
        return servicio;
    }
  }

  void _abrirCatalogoInmuebles() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CatalogoInmueblesScreen(),
      ),
    );
  }

  void _abrirAsistenciaVial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SolicitarAsistenciaVialScreen(),
      ),
    );
  }

  Widget _infoChip({
    required IconData icono,
    required String texto,
    Color iconoColor = _gold,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: iconoColor),
          const SizedBox(width: 5),
          Text(
            texto,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 12,
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
      final items = await _api.getEspecialidades(limit: 200);
      var legales = items
          .where(
            (e) =>
                e.toLowerCase().contains('derecho') ||
                e.toLowerCase().contains('amparo'),
          )
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
                      color: _card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 9),
                        Container(
                          width: 46,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Especialidad para abogados',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: TextField(
                            controller: buscadorController,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (value) {
                              setSheetState(() {
                                filtro = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Buscar especialidad...',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: _gold,
                              ),
                              suffixIcon: filtro.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        buscadorController.clear();
                                        setSheetState(() {
                                          filtro = '';
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                              filled: true,
                              fillColor: const Color(0xFF0C1420),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: _gold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                            children: [
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                title: const Text(
                                  'Todas las especialidades',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                leading: const Icon(
                                  Icons.clear_all_rounded,
                                  color: _gold,
                                ),
                                trailing: _especialidadAbogado.isEmpty
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: _gold,
                                      )
                                    : null,
                                onTap: () => Navigator.of(context).pop(''),
                              ),
                              if (especialidadesFiltradas.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 20,
                                  ),
                                  child: Text(
                                    'No hay especialidades con ese nombre.',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.58),
                                    ),
                                  ),
                                )
                              else
                                ...especialidadesFiltradas.map(
                                  (especialidad) => ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    title: Text(
                                      especialidad,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    trailing:
                                        _especialidadAbogado == especialidad
                                            ? const Icon(
                                                Icons.check_circle_rounded,
                                                color: _gold,
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

      if (!mounted) return;

      if (seleccion == null) {
        setState(() {
          _esperandoEspecialidadAbogado = false;
        });
        return;
      }

      setState(() {
        _especialidadAbogado = seleccion.trim();
        _esperandoEspecialidadAbogado = false;
        _mapaAutoAbierto = false;
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

    if (_esServicioAbogados(servicio) && _esperandoEspecialidadAbogado) {
      return;
    }

    if (servicio.isEmpty && especialidad.isEmpty) {
      if (mounted) {
        setState(() {
          _profesionales = [];
          _mensaje = '';
        });
      }
      return;
    }

    if (_esAgenteInmobiliario(servicio) || _esAsistenciaVial(servicio)) {
      if (mounted) {
        setState(() {
          _profesionales = [];
          _mensaje = '';
          _ubicacionCliente = null;
          _cargando = false;
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
      final data = await _api.getProfesionalesCercanos(
        perfil: servicio.isEmpty ? null : servicio,
        especialidad: especialidad.isEmpty ? null : especialidad,
        lat: ubicacion.latitude,
        lng: ubicacion.longitude,
        limit: 20,
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

      await _abrirMapaAutomaticoSiListo();
    }
  }

  Future<void> _abrirMapaAutomaticoSiListo() async {
    if (!mounted) return;
    if (_mapaAutoAbierto) return;
    if (_ubicacionCliente == null) return;
    if (_profesionales.isEmpty) return;

    final servicio = widget.servicioSeleccionado?.trim() ?? '';

    if (_esAsistenciaVial(servicio) || _esAgenteInmobiliario(servicio)) {
      return;
    }

    _mapaAutoAbierto = true;

    await Future.delayed(const Duration(milliseconds: 150));

    if (!mounted) return;

    await _abrirMapaPantallaCompleta();
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
      _mensaje = 'Servicio de ubicación desactivado.';
      return null;
    }

    var permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      _mensaje = 'Permiso de ubicación denegado.';
      return null;
    }

    try {
      try {
        final posicion = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 6),
        );

        return LatLng(posicion.latitude, posicion.longitude);
      } catch (_) {
        final posicion = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 8),
        );

        return LatLng(posicion.latitude, posicion.longitude);
      }
    } catch (_) {
      _mensaje = 'No se pudo obtener tu ubicación. Intenta de nuevo.';
      return null;
    }
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
    if (_enviandoSolicitud) return;

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
        const SnackBar(content: Text('Profesional inválido.')),
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
      barrierDismissible: !_enviandoSolicitud,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enviar solicitud'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Se enviará una solicitud de caso a $nombre para que la acepte o rechace.',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título del caso',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descripcionController,
                  minLines: 3,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
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
        const SnackBar(content: Text('El título es obligatorio.')),
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

    if (!mounted) return;

    setState(() {
      _enviandoSolicitud = true;
    });

    try {
      final resp = await _api.solicitarCaso(
        clienteId: clienteId,
        profesionalId: profesionalId,
        servicio: servicio,
        titulo: titulo,
        descripcion: descripcion,
      );

      if (!mounted) return;

      final creado = resp['creado'] == true ||
          resp['success'] == true ||
          resp['data']?['creado'] == true;

      final message = resp['message']?.toString() ??
          resp['mensaje']?.toString() ??
          (creado
              ? 'Solicitud enviada correctamente.'
              : 'Solicitud registrada correctamente.');

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

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
        int.tryParse(profesional['total_calificaciones']?.toString() ?? '') ?? 0;

    final ratingTexto = totalCalificaciones > 0
        ? '${rating.toStringAsFixed(1)} ($totalCalificaciones)'
        : 'Sin calificación';

    final distanciaTexto = distancia != null
        ? '${distancia.toStringAsFixed(2)} km'
        : 'Distancia N/D';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                if (especialidad.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      especialidad,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
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
                      iconoColor: const Color(0xFF5D93FF),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _enviandoSolicitud
                        ? null
                        : () => _mostrarDialogoSolicitud(profesional),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: const Color(0xFF111827),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.assignment_rounded),
                    label: Text(
                      _enviandoSolicitud
                          ? 'Enviando solicitud...'
                          : 'Enviar solicitud',
                      style: const TextStyle(fontWeight: FontWeight.w900),
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
        return const Color(0xFF54C26B);
      case 'ocupado':
        return const Color(0xFFE59A36);
      default:
        return const Color(0xFFEF4444);
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
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        _textoEstado(estado),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _mensajeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A1114),
        border: Border.all(color: const Color(0xFF7F1D1D)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFFA4A4),
            size: 22,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              _mensaje,
              style: const TextStyle(
                color: Color(0xFFFFC6C6),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirMapaPantallaCompleta() async {
    if (_ubicacionCliente == null) return;
    if (_profesionales.isEmpty) return;

    final seleccionado = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => ProfesionalesMapaFullscreen(
          ubicacionCliente: _ubicacionCliente!,
          profesionales: _profesionales,
          servicioSeleccionado: widget.servicioSeleccionado ?? '',
        ),
      ),
    );

    if (!mounted || seleccionado == null) return;

    _mostrarDetalle(seleccionado);
  }

  Future<void> _seleccionarServicioTipoUber(String servicio) async {
    final selected = servicio == widget.servicioSeleccionado;

    if (selected) {
      setState(() {
        _mapaAutoAbierto = false;
        _esperandoEspecialidadAbogado = false;
        _especialidadAbogado = '';
        _profesionales = [];
        _mensaje = '';
      });

      widget.onSeleccionarServicio('');
      return;
    }

    if (_esAgenteInmobiliario(servicio)) {
      _abrirCatalogoInmuebles();
      return;
    }

    if (_esAsistenciaVial(servicio)) {
      _abrirAsistenciaVial();
      return;
    }

    if (_esServicioAbogados(servicio)) {
      final opcion = await showModalBottomSheet<_OpcionAbogado>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.72,
                ),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '¿Qué abogados quieres buscar?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Puedes ver todos los abogados cercanos o filtrar por especialidad.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.58),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _OpcionAbogadoTile(
                        icon: Icons.groups_rounded,
                        title: 'Todos los abogados',
                        subtitle: 'Abrir mapa con abogados disponibles',
                        color: _gold,
                        onTap: () {
                          Navigator.pop(context, _OpcionAbogado.todos);
                        },
                      ),
                      const SizedBox(height: 10),
                      _OpcionAbogadoTile(
                        icon: Icons.balance_rounded,
                        title: 'Elegir especialidad',
                        subtitle: 'Penal, civil, familiar, laboral y más',
                        color: _gold,
                        onTap: () {
                          Navigator.pop(context, _OpcionAbogado.especialidad);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      if (!mounted || opcion == null) return;

      if (opcion == _OpcionAbogado.todos) {
        setState(() {
          _especialidadAbogado = '';
          _esperandoEspecialidadAbogado = false;
          _mapaAutoAbierto = false;
        });

        widget.onSeleccionarServicio(servicio);
        return;
      }

      setState(() {
        _esperandoEspecialidadAbogado = true;
        _mapaAutoAbierto = false;
        _especialidadAbogado = '';
      });

      widget.onSeleccionarServicio(servicio);

      await Future.delayed(const Duration(milliseconds: 150));

      if (!mounted) return;

      await _abrirSelectorEspecialidadAbogado();

      return;
    }

    setState(() {
      _especialidadAbogado = '';
      _esperandoEspecialidadAbogado = false;
      _mapaAutoAbierto = false;
    });

    widget.onSeleccionarServicio(servicio);
  }

  Widget _buildHeader(bool compact) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22, compact ? 14 : 20, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Servicios',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 29 : 33,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Elige un servicio y encuentra profesionales verificados cerca de ti.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: compact ? 13.5 : 15,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(bool compact) {
    return Container(
      height: compact ? 154 : 168,
      margin: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF142033), Color(0xFF070D15)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -22,
            bottom: -22,
            width: 210,
            child: Opacity(
              opacity: 0.32,
              child: Image.asset(
                'assets/iconos/mazo-libro.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF0B111B),
                    const Color(0xFF0B111B).withValues(alpha: 0.82),
                    const Color(0xFF0B111B).withValues(alpha: 0.20),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            top: 22,
            right: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Qué necesitas resolver?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 23 : 26,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Abogados, peritos, psicólogos, ajustadores y más servicios.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    height: 1.25,
                    fontSize: compact ? 12.5 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 18,
            top: 28,
            child: InkWell(
              onTap: _abrirAsistenciaVial,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: compact ? 92 : 104,
                height: compact ? 104 : 112,
                decoration: BoxDecoration(
                  color: _red,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _red.withValues(alpha: 0.34),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emergency_share_rounded,
                      color: Colors.white,
                      size: 31,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Asistencia\nvial',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiciosGrid(bool compact) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Selecciona un servicio'),
          const SizedBox(height: 14),
          GridView.builder(
            itemCount: widget.serviciosDisponibles.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: compact ? 10 : 13,
              mainAxisSpacing: compact ? 10 : 13,
              childAspectRatio: compact ? 0.72 : 0.78,
            ),
            itemBuilder: (context, index) {
              final servicio = widget.serviciosDisponibles[index];
              final selected = servicio == widget.servicioSeleccionado;
              final color = _colorServicio(servicio);

              return InkWell(
                onTap: () => _seleccionarServicioTipoUber(servicio),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? color.withValues(alpha: 0.13) : _card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? color.withValues(alpha: 0.72)
                          : Colors.white.withValues(alpha: 0.055),
                      width: selected ? 1.4 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selected
                            ? color.withValues(alpha: 0.13)
                            : Colors.black.withValues(alpha: 0.15),
                        blurRadius: selected ? 16 : 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      if (selected)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: color,
                            size: 18,
                          ),
                        ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _iconoServicio(servicio),
                              color: color,
                              size: compact ? 36 : 42,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _nombreCortoServicio(servicio),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.90),
                                fontSize: compact ? 11.2 : 13,
                                height: 1.10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isSmallPhone = screen.width < 380 || screen.height < 700;

    return Container(
      color: _bg,
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            right: -80,
            height: 260,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.9,
                  colors: [
                    const Color(0xFF233653).withValues(alpha: 0.86),
                    const Color(0xFF0B1420).withValues(alpha: 0.74),
                    _bg.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 170,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/iconos/mazo-libro.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: _gold,
              backgroundColor: _card,
              onRefresh: _cargarSiHayServicio,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 122),
                children: [
                  _buildHeader(isSmallPhone),
                  _buildHeroCard(isSmallPhone),
                  _buildServiciosGrid(isSmallPhone),
                  if (_cargando)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(22, 18, 22, 0),
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        color: _gold,
                        backgroundColor: Color(0xFF243247),
                      ),
                    ),
                  if (_mensaje.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                      child: _mensajeBanner(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcionAbogadoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OpcionAbogadoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 25,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.52),
                        fontSize: 12.5,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.55),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
