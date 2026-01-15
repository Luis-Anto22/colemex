import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UbicacionTiempoRealScreen extends StatefulWidget {
  const UbicacionTiempoRealScreen({super.key});

  @override
  State<UbicacionTiempoRealScreen> createState() => _UbicacionTiempoRealScreenState();
}

class _UbicacionTiempoRealScreenState extends State<UbicacionTiempoRealScreen> {
  bool compartiendo = false;
  bool cargando = false;

  double? lat;
  double? lng;

  Future<void> detectarUbicacion() async {
    setState(() => cargando = true);

    try {
      final servicioActivo = await Geolocator.isLocationServiceEnabled();
      if (!servicioActivo) {
        _snack('❌ El servicio de ubicación está desactivado');
        setState(() => cargando = false);
        return;
      }

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied || permiso == LocationPermission.deniedForever) {
        _snack('❌ Permiso de ubicación denegado');
        setState(() => cargando = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        lat = pos.latitude;
        lng = pos.longitude;
      });

      _snack('📍 Ubicación detectada');
    } catch (e) {
      _snack('❌ Error: $e');
    } finally {
      setState(() => cargando = false);
    }
  }

  Future<void> guardarUbicacionServidor() async {
    if (lat == null || lng == null) {
      _snack('⚠️ Primero detecta tu ubicación');
      return;
    }

    setState(() => cargando = true);

    try {
      // ✅ Cambia este endpoint al tuyo real
      final url = Uri.parse('https://corporativolegaldigital.com/api/guardar_ubicacion_investigador.php');

      final resp = await http.post(url, body: {
        // ⚠️ cuando tengas login real del investigador, manda su id:
        // 'id': '123',
        'latitude': lat.toString(),
        'longitude': lng.toString(),
        'activo': compartiendo ? '1' : '0',
      });

      final body = resp.body.trim();
      if (resp.statusCode == 200 && body.startsWith('{')) {
        final data = json.decode(body);
        final ok = data['success'] == true;
        _snack(ok ? '✅ Ubicación guardada' : '❌ ${data['message'] ?? "Error"}');
      } else {
        _snack('❌ Respuesta inválida del servidor');
      }
    } catch (e) {
      _snack('❌ No se pudo conectar: $e');
    } finally {
      setState(() => cargando = false);
    }
  }

  void _snack(String msg) {
    final theme = Theme.of(context);
    final bg = theme.appBarTheme.backgroundColor ?? theme.primaryColor;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? gold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación en tiempo real'),
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/iconos/mazo-libro.png', fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(.62))),
          SafeArea(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                constraints: const BoxConstraints(maxWidth: 720),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: gold.withOpacity(.22)),
                  color: const Color(0xFF12161C).withOpacity(.88),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.30),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: gold, size: 28),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Comparte tu ubicación cuando estés activo.',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(height: 1, color: gold.withOpacity(.18)),
                    const SizedBox(height: 14),

                    SwitchListTile(
                      value: compartiendo,
                      activeColor: gold,
                      title: const Text('Compartir ubicación', style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                        compartiendo ? 'Activa (visible para clientes)' : 'Desactivada',
                        style: TextStyle(color: Colors.white.withOpacity(.72)),
                      ),
                      onChanged: cargando ? null : (v) => setState(() => compartiendo = v),
                    ),

                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: gold.withOpacity(.20)),
                        color: Colors.white.withOpacity(.05),
                      ),
                      child: Text(
                        lat == null
                            ? '📍 Sin ubicación detectada'
                            : '📍 Lat: ${lat!.toStringAsFixed(6)}\n📍 Lng: ${lng!.toStringAsFixed(6)}',
                        style: TextStyle(color: Colors.white.withOpacity(.85), height: 1.35),
                      ),
                    ),

                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: cargando ? null : detectarUbicacion,
                      icon: const Icon(Icons.my_location),
                      label: Text(cargando ? 'Detectando...' : 'Detectar ubicación'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: cargando ? null : guardarUbicacionServidor,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar en servidor'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: gold.withOpacity(.65)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
}
