import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Pantalla reutilizable para elegir un punto en mapa a pantalla completa.
// Se usa cuando una pantalla necesita mapa, pero la seleccion debe hacerse
// en una vista dedicada con mejor visibilidad.
class MapaSelectorFullscreenScreen extends StatefulWidget {
  final LatLng initialPoint;
  final String titulo;
  final String subtitulo;
  final bool permitirEdicion;

  const MapaSelectorFullscreenScreen({
    super.key,
    required this.initialPoint,
    required this.titulo,
    this.subtitulo = 'Toca el mapa para ajustar el pin.',
    this.permitirEdicion = true,
  });

  @override
  State<MapaSelectorFullscreenScreen> createState() =>
      _MapaSelectorFullscreenScreenState();
}

class _MapaSelectorFullscreenScreenState
    extends State<MapaSelectorFullscreenScreen> {
  late LatLng _selectedPoint;

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialPoint;
  }

  void _confirmarSeleccion() {
    Navigator.of(context).pop(_selectedPoint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
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
                initialCenter: _selectedPoint,
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                ),
                onTap: widget.permitirEdicion
                    ? (_, point) => setState(() => _selectedPoint = point)
                    : null,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'advocatus',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPoint,
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
          if (widget.subtitulo.trim().isNotEmpty)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.93),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.subtitulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: ElevatedButton.icon(
                onPressed: _confirmarSeleccion,
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirmar ubicacion'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
