import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ProfesionalesMapaFullscreen extends StatelessWidget {
  final LatLng ubicacionCliente;
  final List<Map<String, dynamic>> profesionales;
  final String servicioSeleccionado;

  const ProfesionalesMapaFullscreen({
    super.key,
    required this.ubicacionCliente,
    required this.profesionales,
    required this.servicioSeleccionado,
  });

  IconData _iconoServicio(String servicio) {
    final normalizado = servicio
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');

    switch (normalizado) {
      case 'abogados':
      case 'abogado':
        return Icons.gavel_rounded;
      case 'ajustadores':
      case 'ajustador':
        return Icons.health_and_safety_rounded;
      case 'peritos en criminalistica':
      case 'perito en criminalistica':
        return Icons.fingerprint_rounded;
      case 'valuadores':
      case 'valuador':
        return Icons.home_work_rounded;
      case 'investigadores':
      case 'investigador':
        return Icons.search_rounded;
      case 'psicologos':
      case 'psicologo':
        return Icons.psychology_rounded;
      case 'agentes inmobiliarios':
      case 'agente inmobiliario':
        return Icons.apartment_rounded;
      case 'contadores':
      case 'contador':
        return Icons.calculate_rounded;
      case 'agentes crediticios':
      case 'agente crediticio':
        return Icons.account_balance_wallet_rounded;
      case 'asistencia vial':
      case 'asistencia_vial':
        return Icons.car_repair_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  Color _colorEstado(String estadoRaw) {
    final estado = estadoRaw.toLowerCase().trim();
    if (estado == 'activo' || estado == 'disponible') {
      return const Color(0xFF16A34A);
    }
    if (estado == 'ocupado') {
      return const Color(0xFFEA580C);
    }
    return const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Mapa de profesionales'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: ubicacionCliente,
                initialZoom: 13,
                minZoom: 5,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.advocatus.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: ubicacionCliente,
                      width: 42,
                      height: 42,
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFF1D4ED8),
                        size: 36,
                      ),
                    ),
                    ...profesionales.map((p) {
                      final lat = double.tryParse(p['latitude']?.toString() ?? '');
                      final lng =
                          double.tryParse(p['longitude']?.toString() ?? '');
                      if (lat == null || lng == null) {
                        return null;
                      }

                      final estado = p['estado']?.toString() ?? 'disponible';
                      final perfilRaw = p['perfil']?.toString().trim() ?? '';
                      final perfil = perfilRaw.isNotEmpty
                          ? perfilRaw
                          : servicioSeleccionado.trim();
                      final icono = _iconoServicio(perfil);
                      final colorEstado = _colorEstado(estado);

                      return Marker(
                        point: LatLng(lat, lng),
                        width: 42,
                        height: 42,
                        child: GestureDetector(
                          // Regresa al panel y muestra la ficha del profesional seleccionado.
                          onTap: () => Navigator.of(context).pop(p),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: colorEstado, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(icono, color: colorEstado, size: 20),
                          ),
                        ),
                      );
                    }).whereType<Marker>(),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0B2545).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${profesionales.length} cercanos',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFD6E1EF)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_rounded, size: 14, color: Color(0xFF334155)),
                  SizedBox(width: 5),
                  Text(
                    'Toca un pin para ver ficha',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w600,
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
