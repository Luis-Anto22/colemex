import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuscarAbogadoMapScreen extends StatefulWidget {
  const BuscarAbogadoMapScreen({super.key});

  @override
  State<BuscarAbogadoMapScreen> createState() => _BuscarAbogadoMapScreenState();
}

class _BuscarAbogadoMapScreenState extends State<BuscarAbogadoMapScreen> {
  LatLng? ubicacionCliente;
  List<Map<String, dynamic>> abogados = [];
  bool cargando = true;
  String mensaje = '';

  @override
  void initState() {
    super.initState();
    obtenerUbicacionYAbogados();
  }

  Future<void> obtenerUbicacionYAbogados() async {
    try {
      // Verificar si el servicio de ubicación está habilitado
      final servicioActivo = await Geolocator.isLocationServiceEnabled();
      if (!servicioActivo) {
        setState(() {
          mensaje = '❌ El servicio de ubicación está desactivado';
          cargando = false;
        });
        return;
      }

      // Solicitar permisos
      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied || permiso == LocationPermission.deniedForever) {
        setState(() {
          mensaje = '❌ Permiso de ubicación denegado';
          cargando = false;
        });
        return;
      }

      // Obtener ubicación actual
      final posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      ubicacionCliente = LatLng(posicion.latitude, posicion.longitude);

      // Consumir API de abogados
      final url = Uri.parse('https://corporativolegaldigital.com/api/listar-abogados.php');
      final respuesta = await http.get(url);
      print('Respuesta cruda: ${respuesta.body}');

      final datos = json.decode(respuesta.body.trim());
      if (datos['abogados'] != null && datos['abogados'] is List) {
        abogados = List<Map<String, dynamic>>.from(datos['abogados']);
        if (abogados.isEmpty) {
          mensaje = '⚠️ No hay abogados registrados';
        }
      } else {
        mensaje = '⚠️ Formato inesperado en la respuesta del servidor';
      }
    } catch (e) {
      mensaje = '❌ Error al obtener datos: $e';
    }

    setState(() {
      cargando = false;
    });
  }

  Widget mostrarFoto(String? url) {
    if (url == null || url.isEmpty) {
      return const Text('📷 Sin foto registrada');
    }

    return Image.network(
      url,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        print('❌ Error al cargar imagen: $url');
        return Column(
          children: const [
            Icon(Icons.broken_image, color: Colors.red, size: 40),
            Text('❌ Foto no disponible'),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar abogado'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : ubicacionCliente == null
              ? Center(
                  child: Text(
                    mensaje.isNotEmpty ? mensaje : '❌ No se pudo obtener la ubicación',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : Stack(
                  children: [
                    SizedBox.expand(
                      child: FlutterMap(
                        options: MapOptions(
                          center: ubicacionCliente!,
                          zoom: 14,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: ubicacionCliente!,
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                              ),
                              ...abogados.map((abogado) {
                                final lat = double.tryParse(abogado['latitude'].toString());
                                final lng = double.tryParse(abogado['longitude'].toString());
                                if (lat == null || lng == null) {
                                  return const Marker(
                                    point: LatLng(0, 0),
                                    width: 0,
                                    height: 0,
                                    child: SizedBox(),
                                  );
                                }

                                final fotoUrl = abogado['foto']?.toString() ?? '';
                                print('🖼️ URL de foto: $fotoUrl');

                                return Marker(
                                  point: LatLng(lat, lng),
                                  width: 200,
                                  height: 80,
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text(abogado['nombre'] ?? 'Sin nombre'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(abogado['especialidad'] ?? 'Sin especialidad'),
                                              const SizedBox(height: 12),
                                              mostrarFoto(fotoUrl),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cerrar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.pushNamed(
                                                  context,
                                                  '/ubicacion-despacho',
                                                  arguments: {'id': abogado['id']},
                                                );
                                              },
                                              child: const Text('Ver despacho'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                                  ),
                                );
                              }).toList(),
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
                  ],
                ),
    );
  }
}