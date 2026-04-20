import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class FullscreenLocationPickerScreen extends StatefulWidget {
  final LatLng initialPoint;
  final String title;
  final String confirmLabel;
  final bool allowDrag;
  final bool allowTapSelection;
  final bool allowDetectCurrentLocation;

  const FullscreenLocationPickerScreen({
    super.key,
    required this.initialPoint,
    this.title = 'Seleccionar ubicacion',
    this.confirmLabel = 'Guardar ubicacion',
    this.allowDrag = true,
    this.allowTapSelection = true,
    this.allowDetectCurrentLocation = true,
  });

  @override
  State<FullscreenLocationPickerScreen> createState() =>
      _FullscreenLocationPickerScreenState();
}

class _FullscreenLocationPickerScreenState
    extends State<FullscreenLocationPickerScreen> {
  late LatLng _selectedPoint;
  final MapController _mapController = MapController();
  bool _detecting = false;

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialPoint;
  }

  Future<void> _detectCurrentLocation() async {
    if (_detecting) return;
    setState(() => _detecting = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activa el GPS para continuar')),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de ubicacion denegado')),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      final point = LatLng(pos.latitude, pos.longitude);
      setState(() => _selectedPoint = point);
      _mapController.move(point, 16);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo detectar la ubicacion')),
      );
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedPoint,
                initialZoom: 15,
                minZoom: 4,
                maxZoom: 19,
                onTap: widget.allowTapSelection
                    ? (_, point) => setState(() => _selectedPoint = point)
                    : null,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.advocatus.app',
                ),
                if (widget.allowDrag)
                  DragMarkers(
                    markers: [
                      DragMarker(
                        point: _selectedPoint,
                        size: const Size(42, 42),
                        builder: (context, point, isDragging) => Icon(
                          Icons.location_pin,
                          color: isDragging ? Colors.orange : Colors.red,
                          size: 40,
                        ),
                        onDragEnd: (_, point) => setState(() {
                          _selectedPoint = point;
                        }),
                      ),
                    ],
                  )
                else
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedPoint,
                        width: 42,
                        height: 42,
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
          if (widget.allowDetectCurrentLocation)
            Positioned(
              right: 16,
              bottom: 88,
              child: FloatingActionButton(
                heroTag: 'fab_detect_current_location',
                onPressed: _detecting ? null : _detectCurrentLocation,
                child: _detecting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: ElevatedButton.icon(
              // Retorna la coordenada elegida al flujo que abrió esta pantalla.
              onPressed: () => Navigator.of(context).pop(_selectedPoint),
              icon: const Icon(Icons.save),
              label: Text(widget.confirmLabel),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
