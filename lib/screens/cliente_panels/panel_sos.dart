import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services/cliente_profesionales_api.dart';

class PanelSOS extends StatefulWidget {
  const PanelSOS({super.key});

  @override
  State<PanelSOS> createState() => _PanelSOSState();
}

class _PanelSOSState extends State<PanelSOS> {
  static const Color _primary = Color(0xFF0B2545);

  final ClienteProfesionalesApi _api = ClienteProfesionalesApi();
  final Distance _distance = const Distance();
  bool _buscando = false;
  bool _enviandoSolicitud = false;
  String _mensaje = '';

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

  double _distanciaKm(Map<String, dynamic> profesional, LatLng origen) {
    final raw = profesional['distancia_km'];
    final parsed = raw != null ? double.tryParse(raw.toString()) : null;
    if (parsed != null) return parsed;

    final lat = double.tryParse(profesional['latitude']?.toString() ?? '');
    final lng = double.tryParse(profesional['longitude']?.toString() ?? '');
    if (lat == null || lng == null) return double.infinity;
    return _distance.as(LengthUnit.Kilometer, origen, LatLng(lat, lng));
  }

  Future<int?> _obtenerClienteId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    if (id == null || id <= 0) return null;
    return id;
  }

  Future<void> _buscarEmergencia(String tipo) async {
    if (_buscando) return;

    setState(() {
      _buscando = true;
      _mensaje = '';
    });

    final ubicacion = await _obtenerUbicacion();
    if (!mounted) return;
    if (ubicacion == null) {
      setState(() {
        _buscando = false;
      });
      return;
    }

    List<Map<String, dynamic>> candidatos = [];
    try {
      if (tipo == 'penal') {
        // API (via ClienteProfesionalesApi.getProfesionalesCercanos):
        // GET /common/profesionales_cercanos.php
        candidatos = await _api.getProfesionalesCercanos(
          perfil: 'Abogados',
          especialidad: 'Derecho Penal',
          lat: ubicacion.latitude,
          lng: ubicacion.longitude,
          limit: 20,
        );
      } else {
        // API (via ClienteProfesionalesApi.getProfesionalesCercanos):
        // GET /common/profesionales_cercanos.php
        final ajustadores = await _api.getProfesionalesCercanos(
          perfil: 'Ajustadores',
          lat: ubicacion.latitude,
          lng: ubicacion.longitude,
          limit: 20,
        );
        final civiles = await _api.getProfesionalesCercanos(
          perfil: 'Abogados',
          especialidad: 'Derecho Civil',
          lat: ubicacion.latitude,
          lng: ubicacion.longitude,
          limit: 20,
        );
        candidatos = [...ajustadores, ...civiles];
      }
    } catch (_) {
      _mensaje = 'Error al buscar emergencia.';
    }

    if (_mensaje.isEmpty) {
      if (candidatos.isEmpty) {
        _mensaje = 'No hay profesionales disponibles para la emergencia.';
      } else {
        candidatos.sort((a, b) =>
            _distanciaKm(a, ubicacion).compareTo(_distanciaKm(b, ubicacion)));
        final seleccionado = candidatos.first;
        _mostrarContacto(seleccionado, ubicacion, tipo);
      }
    }

    if (mounted) {
      setState(() {
        _buscando = false;
      });
    }
  }

  void _mostrarContacto(
    Map<String, dynamic> profesional,
    LatLng ubicacion,
    String tipo,
  ) {
    final nombre = profesional['nombre']?.toString() ?? 'Profesional';
    final especialidad = profesional['especialidad']?.toString() ?? '';
    final estado = profesional['estado']?.toString() ?? 'disponible';
    final distancia = _distanciaKm(profesional, ubicacion);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: estado == 'disponible'
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      estado == 'disponible' ? 'Disponible' : estado,
                      style: TextStyle(
                        color: estado == 'disponible'
                            ? const Color(0xFF166534)
                            : const Color(0xFF9A3412),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${distancia.toStringAsFixed(2)} km',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Se enviara una solicitud al profesional para que la acepte o rechace.',
                style: TextStyle(
                  color: Color(0xFF475569),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _enviandoSolicitud
                      ? null
                      : () => _mostrarDialogoSolicitudSOS(
                            profesional: profesional,
                            tipo: tipo,
                            navigator: Navigator.of(sheetContext),
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  icon: const Icon(Icons.assignment_rounded),
                  label: Text(
                    _enviandoSolicitud
                        ? 'Enviando solicitud...'
                        : 'Enviar solicitud SOS',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _enviarSolicitudSOS({
    required Map<String, dynamic> profesional,
    required String tipo,
    required NavigatorState navigator,
    required String titulo,
    required String descripcion,
  }) async {
    if (_enviandoSolicitud) return;

    final profesionalId = int.tryParse(profesional['id']?.toString() ?? '');
    if (profesionalId == null || profesionalId <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profesional invalido.')),
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

    final perfilRaw = (profesional['perfil']?.toString() ?? '').trim();
    final servicio = perfilRaw.isNotEmpty
        ? perfilRaw
        : (tipo == 'penal' ? 'Abogados' : 'Ajustadores');
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
      if (navigator.canPop()) {
        navigator.pop();
      }
      final message = resp['message']?.toString() ??
          'Solicitud SOS enviada correctamente.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF166534),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo enviar la solicitud SOS: $e'),
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

  Future<void> _mostrarDialogoSolicitudSOS({
    required Map<String, dynamic> profesional,
    required String tipo,
    required NavigatorState navigator,
  }) async {
    if (_enviandoSolicitud) return;

    final nombre = (profesional['nombre']?.toString() ?? 'Profesional').trim();
    final tipoTexto = tipo == 'penal' ? 'Penal' : 'Civil';
    final tituloController = TextEditingController(
      text: 'Solicitud SOS $tipoTexto',
    );
    final descripcionController = TextEditingController(
      text: 'Solicitud urgente generada desde Centro SOS.',
    );

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
              onPressed: _enviandoSolicitud
                  ? null
                  : () => Navigator.of(dialogContext).pop(true),
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

    await _enviarSolicitudSOS(
      profesional: profesional,
      tipo: tipo,
      navigator: navigator,
      titulo: titulo,
      descripcion: descripcion,
    );
  }

  Widget _botonEmergencia({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required List<Color> colores,
    required Color iconBg,
    required VoidCallback? onTap,
    Color texto = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colores,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colores.first.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icono, color: texto, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          color: texto,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitulo,
                        style: TextStyle(
                          color: texto.withValues(alpha: 0.92),
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: texto),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primary, Color(0xFF134074)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Centro SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Selecciona el tipo de emergencia para contactar al profesional mas cercano.',
                  style: TextStyle(
                    color: Color(0xFFD9E5F3),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (_buscando)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          if (_mensaje.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  border: Border.all(color: const Color(0xFFFECACA)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFB91C1C),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _mensaje,
                        style: const TextStyle(color: Color(0xFFB91C1C)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _botonEmergencia(
                    titulo: 'Emergencia Penal',
                    subtitulo: 'Contacto inmediato con abogado penal.',
                    icono: Icons.gavel_rounded,
                    colores: const [Color(0xFFDC2626), Color(0xFFB91C1C)],
                    iconBg: Colors.white.withValues(alpha: 0.2),
                    onTap: _buscando ? null : () => _buscarEmergencia('penal'),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _botonEmergencia(
                    titulo: 'Emergencia Civil',
                    subtitulo:
                        'Contacto inmediato con ajustador o abogado civil.',
                    icono: Icons.balance_rounded,
                    colores: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                    iconBg: Colors.white.withValues(alpha: 0.22),
                    onTap: _buscando ? null : () => _buscarEmergencia('civil'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
