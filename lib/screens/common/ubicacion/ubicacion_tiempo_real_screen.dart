import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/common_api.dart';

class UbicacionTiempoRealScreen extends StatefulWidget {
  const UbicacionTiempoRealScreen({super.key});

  @override
  State<UbicacionTiempoRealScreen> createState() =>
      _UbicacionTiempoRealScreenState();
}

class _UbicacionTiempoRealScreenState extends State<UbicacionTiempoRealScreen> {
  final CommonApi api = CommonApi(ApiClient());
  bool cargando = true;
  bool detectando = false;
  bool compartiendo = false;
  int profesionalId = 0;
  double? latitude;
  double? longitude;
  LatLng? preview;
  String? direccion;
  StreamSubscription<Position>? _posSub;
  DateTime? _lastSent;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    profesionalId = prefs.getInt('id') ?? 0;
    compartiendo = prefs.getBool('compartir_ubicacion_rt') ?? false;

    if (profesionalId <= 0) {
      setState(() => cargando = false);
      return;
    }

    try {
      final data = await api.getUbicacion(profesionalId);
      final lat = data['latitude'] != null
          ? double.tryParse(data['latitude'].toString())
          : null;
      final lon = data['longitude'] != null
          ? double.tryParse(data['longitude'].toString())
          : null;

      if (!mounted) return;
      setState(() {
        latitude = lat;
        longitude = lon;
        if (lat != null && lon != null) {
          preview = LatLng(lat, lon);
        }
        cargando = false;
      });

      if (preview != null) {
        await _reverseGeocode(preview!);
      }

      if (compartiendo) {
        final ok = await _ensurePermisoUbicacion();
        if (ok) {
          await _startTiempoReal();
        } else {
          await prefs.setBool('compartir_ubicacion_rt', false);
          if (!mounted) return;
          setState(() => compartiendo = false);
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => cargando = false);
    }
  }

  Future<void> _actualizarCoordenadas() async {
    final latCtrl = TextEditingController(text: latitude?.toString() ?? '');
    final lonCtrl = TextEditingController(text: longitude?.toString() ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Actualizar ubicacion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Latitude'),
            ),
            TextField(
              controller: lonCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Longitude'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    final lat = double.tryParse(latCtrl.text.trim());
    final lon = double.tryParse(lonCtrl.text.trim());
    if (lat == null || lon == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coordenadas invalidas')),
      );
      return;
    }

    try {
      await api.actualizarUbicacion(
        profesionalId: profesionalId,
        latitude: lat,
        longitude: lon,
      );
      if (!mounted) return;
      await _updatePreview(LatLng(lat, lon));
      setState(() {
        latitude = lat;
        longitude = lon;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicacion guardada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _detectarUbicacion() async {
    if (detectando) return;
    setState(() => detectando = true);

    try {
      final okPermiso = await _ensurePermisoUbicacion();
      if (!okPermiso) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final posLatLng = LatLng(pos.latitude, pos.longitude);
      await _updatePreview(posLatLng);

      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirmar ubicacion'),
          content: SizedBox(
            width: 320,
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: posLatLng,
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'advocatus',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: posLatLng,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Si, guardar'),
            ),
          ],
        ),
      );

      if (ok != true) return;

      await api.actualizarUbicacion(
        profesionalId: profesionalId,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      if (!mounted) return;
      setState(() {
        latitude = pos.latitude;
        longitude = pos.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicacion guardada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => detectando = false);
    }
  }

  Future<void> _toggleTiempoReal(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('compartir_ubicacion_rt', value);

    if (value) {
      final ok = await _ensurePermisoUbicacion();
      if (!ok) {
        if (!mounted) return;
        setState(() => compartiendo = false);
        await prefs.setBool('compartir_ubicacion_rt', false);
        return;
      }
      await _startTiempoReal();
    } else {
      await _stopTiempoReal();
    }

    if (!mounted) return;
    setState(() => compartiendo = value);
  }

  Future<bool> _ensurePermisoUbicacion() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activa el GPS para continuar')),
      );
      return false;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de ubicacion denegado')),
      );
      return false;
    }
    return true;
  }

  Future<void> _startTiempoReal() async {
    await _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) async {
      if (!mounted) return;
      final point = LatLng(pos.latitude, pos.longitude);
      await _updatePreview(point);
      setState(() {
        latitude = pos.latitude;
        longitude = pos.longitude;
      });

      final now = DateTime.now();
      if (_lastSent == null || now.difference(_lastSent!).inSeconds >= 10) {
        _lastSent = now;
        try {
          await api.actualizarUbicacion(
            profesionalId: profesionalId,
            latitude: pos.latitude,
            longitude: pos.longitude,
          );
        } catch (_) {}
      }
    });
  }

  Future<void> _stopTiempoReal() async {
    await _posSub?.cancel();
    _posSub = null;
  }

  Future<void> _updatePreview(LatLng point) async {
    if (!mounted) return;
    setState(() => preview = point);
    await _reverseGeocode(point);
  }

  Future<void> _reverseGeocode(LatLng point) async {
    try {
      final list = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (list.isEmpty) return;
      final p = list.first;
      final parts = [
        if ((p.street ?? '').isNotEmpty) p.street!,
        if ((p.subLocality ?? '').isNotEmpty) p.subLocality!,
        if ((p.locality ?? '').isNotEmpty) p.locality!,
        if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea!,
        if ((p.country ?? '').isNotEmpty) p.country!,
      ];
      if (!mounted) return;
      setState(() => direccion = parts.join(', '));
    } catch (_) {
      if (!mounted) return;
      setState(() => direccion = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Ubicacion en tiempo real')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.location_on_outlined, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text(
              'Compartir ubicacion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'Actualiza tus coordenadas para que los clientes puedan encontrarte.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: compartiendo,
              onChanged: (v) => _toggleTiempoReal(v),
              activeThumbColor: gold,
              title: const Text('Compartir ubicacion en tiempo real'),
              subtitle: const Text(
                  'Se actualiza automaticamente cada pocos segundos'),
            ),
            if (cargando)
              const Padding(
                padding: EdgeInsets.all(12),
                child: LinearProgressIndicator(),
              ),
            ListTile(
              leading: Icon(Icons.my_location, color: gold),
              title: const Text('Coordenadas actuales'),
              subtitle: Text(
                latitude == null || longitude == null
                    ? 'Sin registrar'
                    : '$latitude, $longitude',
              ),
            ),
            if (preview != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: preview!,
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                      ),
                      onTap: (_, p) => _updatePreview(p),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'advocatus',
                      ),
                      DragMarkers(
                        markers: [
                          DragMarker(
                            point: preview!,
                            size: const Size(40, 40),
                            builder: (ctx, point, isDragging) => Icon(
                              Icons.location_pin,
                              color: isDragging ? Colors.orange : Colors.red,
                              size: 36,
                            ),
                            onDragEnd: (_, newPoint) => _updatePreview(newPoint),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (direccion != null && direccion!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  direccion!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withOpacity(.75),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: detectando || compartiendo ? null : _detectarUbicacion,
                icon: const Icon(Icons.gps_fixed),
                label: Text(detectando ? 'Detectando...' : 'Detectar ubicacion'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: compartiendo ? null : _actualizarCoordenadas,
                icon: const Icon(Icons.edit_location_alt),
                label: const Text('Ingresar coordenadas manualmente'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }
}
