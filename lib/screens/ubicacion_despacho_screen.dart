<<<<<<< Updated upstream:lib/screens/ubicacion_despacho_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UbicacionDespachoScreen extends StatefulWidget {
  final int idAbogado;

  const UbicacionDespachoScreen({super.key, required this.idAbogado});

  @override
  State<UbicacionDespachoScreen> createState() => _UbicacionDespachoScreenState();
}

class _UbicacionDespachoScreenState extends State<UbicacionDespachoScreen> {
  LatLng? posicionSeleccionada;
  bool cargando = true;
  String mensaje = '';

  @override
  void initState() {
    super.initState();
    if (widget.idAbogado <= 0) {
      setState(() {
        mensaje = '❌ ID de abogado inválido';
        cargando = false;
      });
    } else {
      consultarUbicacionGuardada();
    }
  }

  Future<void> consultarUbicacionGuardada() async {
    final url = Uri.parse(
      'https://corporativolegaldigital.com/api/obtener_ubicacion_abogado.php?id=${widget.idAbogado}',
    );

    try {
      final respuesta = await http.get(url);
      print('Respuesta cruda: ${respuesta.body}');

      final datos = json.decode(respuesta.body.trim());
      print('Datos decodificados: $datos');

      final latRaw = datos['latitude'];
      final lngRaw = datos['longitude'];
      final lat = latRaw != null ? double.tryParse(latRaw.toString()) : null;
      final lng = lngRaw != null ? double.tryParse(lngRaw.toString()) : null;

      if (datos['success'] == true && lat != null && lng != null) {
        setState(() {
          posicionSeleccionada = LatLng(lat, lng);
          mensaje = '📍 Ubicación cargada desde el servidor';
          cargando = false;
        });
      } else {
        setState(() {
          mensaje = datos['message'] ?? '⚠️ Ubicación no registrada';
          cargando = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, selecciona tu ubicación en el mapa.'),
              backgroundColor: Color(0xFFD4AF37),
            ),
          );
        });
      }
    } catch (e) {
      print('Error al decodificar: $e');
      setState(() {
        mensaje = '❌ Error al consultar ubicación';
        cargando = false;
      });
    }
  }

  Future<void> obtenerUbicacionActual() async {
    final permiso = await Geolocator.requestPermission();
    if (permiso == LocationPermission.denied || permiso == LocationPermission.deniedForever) {
      setState(() {
        mensaje = '❌ Permiso de ubicación denegado';
        cargando = false;
      });
      return;
    }

    final posicion = await Geolocator.getCurrentPosition();
    setState(() {
      posicionSeleccionada = LatLng(posicion.latitude, posicion.longitude);
      mensaje = '📍 Ubicación actual detectada';
      cargando = false;
    });
  }

  Future<void> guardarUbicacion() async {
    if (posicionSeleccionada == null) return;

    final url = Uri.parse('https://corporativolegaldigital.com/api/guardar_ubicacion_abogado.php');
    try {
      final respuesta = await http.post(url, body: {
        'id': widget.idAbogado.toString(),
        'latitude': posicionSeleccionada!.latitude.toString(),
        'longitude': posicionSeleccionada!.longitude.toString(),
      });

      final datos = json.decode(respuesta.body.trim());
      final mensajeServidor = datos['message'] ?? '❌ Error inesperado';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeServidor),
          backgroundColor: datos['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (datos['success'] == true) {
        Navigator.pushReplacementNamed(context, '/panel-abogado');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No se pudo conectar al servidor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación del despacho'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : posicionSeleccionada == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        mensaje.isNotEmpty ? mensaje : '❌ No se pudo obtener la ubicación',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: obtenerUbicacionActual,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Detectar ubicación actual'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    SizedBox.expand(
                      child: FlutterMap(
                        options: MapOptions(
                          center: posicionSeleccionada!,
                          zoom: 16,
                          onTap: (tapPosition, punto) {
                            setState(() {
                              posicionSeleccionada = punto;
                              mensaje = '📍 Posición marcada manualmente';
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: posicionSeleccionada!,
                                width: 40,
                                height: 40,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      mensaje = '📍 Marcador tocado';
                                    });
                                  },
                                  child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (mensaje.isNotEmpty)
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            mensaje,
                            style: const TextStyle(color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 80,
                      left: 20,
                      right: 20,
                      child: ElevatedButton.icon(
                        onPressed: obtenerUbicacionActual,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Detectar ubicación actual'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: ElevatedButton.icon(
                        onPressed: guardarUbicacion,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar ubicación'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
=======
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../services/api_services/api_client.dart';
import '../../services/api_services/common_api.dart';

// Pantalla de abogado conectada al flujo comun de ubicacion.
// Integracion:
// UbicacionDespachoScreen -> CommonApi -> ApiClient -> rutas de backend.
class UbicacionDespachoScreen extends StatefulWidget {
  final int idAbogado;

  const UbicacionDespachoScreen({super.key, required this.idAbogado});

  @override
  State<UbicacionDespachoScreen> createState() =>
      _UbicacionDespachoScreenState();
}

class _UbicacionDespachoScreenState extends State<UbicacionDespachoScreen> {
  // Servicio compartido con otras pantallas de ubicacion del proyecto.
  final CommonApi _api = CommonApi(ApiClient());

  LatLng? posicionSeleccionada;
  bool cargando = true;
  bool guardando = false;
  String mensaje = '';

  @override
  void initState() {
    super.initState();
    _cargarUbicacionInicial();
  }

  Future<void> _cargarUbicacionInicial() async {
    if (widget.idAbogado <= 0) {
      setState(() {
        mensaje = 'ID de abogado invalido';
        cargando = false;
      });
      return;
    }

    setState(() => cargando = true);

    try {
      // Lectura desde API comun (/common/ubicacion.php).
      final data = await _api.getUbicacion(widget.idAbogado);
      final lat = _asDouble(data['latitude'] ?? data['latitud']);
      final lng = _asDouble(data['longitude'] ?? data['longitud']);

      if (lat != null && lng != null) {
        setState(() {
          posicionSeleccionada = LatLng(lat, lng);
          mensaje = 'Ubicacion cargada desde API comun';
          cargando = false;
        });
        return;
      }

      setState(() {
        mensaje = 'Aun no tienes una ubicacion guardada';
        cargando = false;
      });
    } catch (_) {
      // Fallback para servidores antiguos donde aun existe la ruta exclusiva.
      final legacy = await _cargarUbicacionLegacy();
      if (legacy != null) {
        setState(() {
          posicionSeleccionada = legacy;
          mensaje = 'Ubicacion cargada desde endpoint legacy';
          cargando = false;
        });
      } else {
        setState(() {
          mensaje = 'No se pudo cargar la ubicacion';
          cargando = false;
        });
      }
    }
  }

  Future<LatLng?> _cargarUbicacionLegacy() async {
    try {
      final apiClient = ApiClient();
      final uri = Uri.parse(
        '${apiClient.baseUrl}/obtener_ubicacion_abogado.php?id=${widget.idAbogado}',
      );

      final response = await http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) return null;

      final lat = _asDouble(decoded['latitude'] ?? decoded['latitud']);
      final lng = _asDouble(decoded['longitude'] ?? decoded['longitud']);

      if (lat == null || lng == null) return null;
      return LatLng(lat, lng);
    } catch (_) {
      return null;
    }
  }

  Future<void> _obtenerUbicacionActual() async {
    final permiso = await _validarPermisos();
    if (!permiso) return;

    try {
      final posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        posicionSeleccionada = LatLng(posicion.latitude, posicion.longitude);
        mensaje = 'Ubicacion actual detectada';
      });
    } catch (_) {
      _toast('No se pudo obtener la ubicacion actual');
    }
  }

  Future<void> _guardarUbicacion() async {
    final punto = posicionSeleccionada;
    if (punto == null) {
      _toast('Selecciona una ubicacion primero');
      return;
    }

    if (guardando) return;
    setState(() => guardando = true);

    try {
      // Guardado principal; CommonApi maneja fallback admin automaticamente.
      await _api.actualizarUbicacion(
        profesionalId: widget.idAbogado,
        latitude: punto.latitude,
        longitude: punto.longitude,
      );

      if (!mounted) return;
      _toast('Ubicacion guardada correctamente');
    } catch (e) {
      final okLegacy = await _guardarUbicacionLegacy(
        latitude: punto.latitude,
        longitude: punto.longitude,
      );

      if (!mounted) return;
      if (okLegacy) {
        _toast('Ubicacion guardada correctamente');
      } else {
        _toast('No se pudo guardar la ubicacion: $e');
      }
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  Future<bool> _guardarUbicacionLegacy({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final apiClient = ApiClient();
      final uri =
          Uri.parse('${apiClient.baseUrl}/guardar_ubicacion_abogado.php');

      final response = await http.post(
        uri,
        body: {
          'id': widget.idAbogado.toString(),
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) return false;

      return decoded['success'] == true || decoded['status'] == 'success';
    } catch (_) {
      return false;
    }
  }

  Future<bool> _validarPermisos() async {
    final servicio = await Geolocator.isLocationServiceEnabled();
    if (!servicio) {
      _toast('Activa el GPS para continuar');
      return false;
    }

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      _toast('Permiso de ubicacion denegado');
      return false;
    }

    return true;
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicacion del despacho'),
        backgroundColor: gold,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : posicionSeleccionada == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off,
                            color: Colors.red, size: 42),
                        const SizedBox(height: 10),
                        Text(
                          mensaje,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _obtenerUbicacionActual,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Detectar ubicacion actual'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Positioned.fill(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: posicionSeleccionada!,
                          initialZoom: 16,
                          onTap: (_, point) {
                            setState(() {
                              posicionSeleccionada = point;
                              mensaje = 'Posicion actualizada manualmente';
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'advocatus',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: posicionSeleccionada!,
                                width: 44,
                                height: 44,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (mensaje.isNotEmpty)
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.93),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            mensaje,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 20,
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _obtenerUbicacionActual,
                                icon: const Icon(Icons.my_location),
                                label: const Text('Detectar ubicacion actual'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: gold,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: guardando ? null : _guardarUbicacion,
                                icon: guardando
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: Text(
                                  guardando
                                      ? 'Guardando...'
                                      : 'Guardar ubicacion',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: gold,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
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
>>>>>>> Stashed changes:lib/screens/abogados/ubicacion_despacho_screen.dart
