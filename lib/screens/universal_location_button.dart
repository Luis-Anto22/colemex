import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_services/api_client.dart';
import '../services/api_services/common_api.dart';

// Widget reutilizable para todos los paneles que necesitan "Guardar ubicacion".
// Integracion:
// Pantalla con mapa (ej. localizacion.dart) -> UniversalLocationButton
// -> CommonApi.actualizarUbicacion -> ApiClient -> backend.
class UniversalLocationButton extends StatefulWidget {
  final int? idProfesional;
  final double? lat;
  final double? lng;
  final bool usarFallbackLegacy;

  const UniversalLocationButton({
    super.key,
    required this.idProfesional,
    this.lat,
    this.lng,
    this.usarFallbackLegacy = true,
  });

  @override
  State<UniversalLocationButton> createState() =>
      _UniversalLocationButtonState();
}

class _UniversalLocationButtonState extends State<UniversalLocationButton> {
  bool _isSaving = false;

  Future<void> _guardarUbicacion(BuildContext context) async {
    if (_isSaving) return;

    final profesionalId = await _resolverIdProfesional();
    if (profesionalId == null || profesionalId <= 0) {
      _toast('ID de profesional no valido');
      return;
    }

    final coords = await _resolverCoordenadas();
    if (coords == null) {
      _toast('No se pudo obtener una ubicacion valida');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Se conecta con lib/services/api_services/common_api.dart.
      final api = CommonApi(ApiClient());

      // Flujo principal: endpoint comun con fallback REST en CommonApi.
      await api.actualizarUbicacion(
        profesionalId: profesionalId,
        latitude: coords.latitude,
        longitude: coords.longitude,
      );

      if (!mounted) return;
      _toast('Ubicacion guardada correctamente');
    } catch (e) {
      // Compatibilidad extra con despliegues antiguos que solo exponen /universal.
      if (widget.usarFallbackLegacy) {
        final okLegacy = await _guardarConRutaUniversalLegacy(
          profesionalId: profesionalId,
          latitude: coords.latitude,
          longitude: coords.longitude,
        );

        if (okLegacy) {
          if (!mounted) return;
          _toast('Ubicacion guardada correctamente');
          return;
        }
      }

      if (!mounted) return;
      _toast('Error al guardar ubicacion: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Si el id no llega por parametro, se toma el id de sesion local.
  Future<int?> _resolverIdProfesional() async {
    if (widget.idProfesional != null && widget.idProfesional! > 0) {
      return widget.idProfesional;
    }

    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    if (id != null && id > 0) return id;

    final asString = prefs.getString('id');
    final parsed = int.tryParse(asString ?? '');
    if (parsed != null && parsed > 0) return parsed;

    return null;
  }

  // Usa coordenadas de pantalla; si no hay, detecta GPS en ese momento.
  Future<_Coords?> _resolverCoordenadas() async {
    final lat = widget.lat;
    final lng = widget.lng;

    if (_coordenadasValidas(lat, lng)) {
      return _Coords(latitude: lat!, longitude: lng!);
    }

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!_coordenadasValidas(pos.latitude, pos.longitude)) {
        return null;
      }

      return _Coords(latitude: pos.latitude, longitude: pos.longitude);
    } catch (_) {
      return null;
    }
  }

  bool _coordenadasValidas(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    return true;
  }

  Future<bool> _guardarConRutaUniversalLegacy({
    required int profesionalId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Fallback directo para despliegues que solo exponen /universal/*.
      final apiClient = ApiClient();
      final uri = Uri.parse(
        '${apiClient.baseUrl}/universal/ubicacion_universal.php',
      );

      final response = await http.post(
        uri,
        body: {
          'profesional_id': profesionalId.toString(),
          'latitud': latitude.toString(),
          'longitud': longitude.toString(),
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) return false;

      return decoded['status'] == 'success' || decoded['success'] == true;
    } catch (_) {
      return false;
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _isSaving ? null : () => _guardarUbicacion(context),
      label: _isSaving
          ? const Text('Guardando...')
          : const Text('Guardar ubicacion'),
      icon: _isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.save),
    );
  }
}

class _Coords {
  final double latitude;
  final double longitude;

  const _Coords({
    required this.latitude,
    required this.longitude,
  });
}
