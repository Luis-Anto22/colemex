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