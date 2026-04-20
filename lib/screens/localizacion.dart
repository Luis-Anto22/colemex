import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'universal_location_button.dart';
import 'map_styles.dart';

class LocalizacionPanel extends StatefulWidget {
  final int? idProfesional;
  final String perfil;

  const LocalizacionPanel({
    super.key,
    required this.idProfesional,
    required this.perfil,
  });

  @override
  State<LocalizacionPanel> createState() => _LocalizacionPanelState();
}

class _LocalizacionPanelState extends State<LocalizacionPanel> {
  LatLng _selectedPosition = const LatLng(19.4326, -99.1332);
  bool _loadingLocation = true;
  bool _darkMode = true;

  final MapController _mapController = MapController();

  TileLayer _currentStyle = MapStyles.osm;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() => _loadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _loadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
        _loadingLocation = false;
      });

      _mapController.move(_selectedPosition, 15);
    } catch (_) {
      setState(() => _loadingLocation = false);
    }
  }

  IconData _getIconForPerfil(String perfil) {
    switch (perfil) {
      case 'Abogados':
        return Icons.gavel;
      case 'Psicólogos':
        return Icons.psychology;
      case 'Contadores':
        return Icons.calculate;
      case 'Agentes crediticios':
        return Icons.account_balance;
      case 'Asistencia Vial':
        return Icons.local_shipping;
      default:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _darkMode ? ThemeData.dark() : ThemeData.light();

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Selecciona tu ubicación'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            Switch(
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<TileLayer>(
                icon: const Icon(Icons.map, color: Colors.white),
                items: [
  DropdownMenuItem(
    value: MapStyles.osm,
    child: const Text('OpenStreetMap'),
  ),
  DropdownMenuItem(
    value: MapStyles.cartoLight,
    child: const Text('Mapa claro'),
  ),
  DropdownMenuItem(
    value: MapStyles.cartoDark,
    child: const Text('Mapa oscuro'),
  ),
],
                onChanged: (style) {
                  if (style != null) {
                    setState(() => _currentStyle = style);
                  }
                },
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            _loadingLocation
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedPosition,
                      initialZoom: 14,
                      onTap: (_, point) {
                        setState(() => _selectedPosition = point);
                      },
                    ),
                    children: [
                      _currentStyle,
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPosition,
                            width: 50,
                            height: 50,
                            child: Icon(
                              _getIconForPerfil(widget.perfil),
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
            Positioned(
              bottom: 20,
              right: 20,
              child: UniversalLocationButton(
                idProfesional: widget.idProfesional,
                lat: _selectedPosition.latitude,
                lng: _selectedPosition.longitude,
              ),
            ),
            Positioned(
              bottom: 90,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                onPressed: _getCurrentLocation,
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }
}