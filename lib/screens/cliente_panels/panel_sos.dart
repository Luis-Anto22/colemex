import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services/cliente_profesionales_api.dart';

class PanelSOS extends StatefulWidget {
  const PanelSOS({super.key});

  @override
  State<PanelSOS> createState() => _PanelSOSState();
}

class _PanelSOSState extends State<PanelSOS> {
  static const Color _bg = Color(0xFF050B14);
  static const Color _card = Color(0xFF111B28);
  static const Color _card2 = Color(0xFF162232);
  static const Color _gold = Color(0xFFD6A84F);
  static const Color _red = Color(0xFFB8322D);
  static const Color _orange = Color(0xFFF59E0B);
  static const Color _green = Color(0xFF54C26B);
  static const Color _blue = Color(0xFF5D93FF);

  final ClienteProfesionalesApi _api = ClienteProfesionalesApi();
  final Distance _distance = const Distance();

  bool _buscando = false;
  bool _enviandoSolicitud = false;
  String _mensaje = '';

  Future<LatLng?> _obtenerUbicacion() async {
    final servicioActivo = await Geolocator.isLocationServiceEnabled();

    if (!servicioActivo) {
      _mensaje = 'Servicio de ubicación desactivado.';
      return null;
    }

    var permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      _mensaje = 'Permiso de ubicación denegado.';
      return null;
    }

    try {
      final posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );

      return LatLng(posicion.latitude, posicion.longitude);
    } catch (_) {
      _mensaje = 'No se pudo obtener tu ubicación. Intenta nuevamente.';
      return null;
    }
  }

  double _distanciaKm(Map<String, dynamic> profesional, LatLng origen) {
    final raw = profesional['distancia_km'];
    final parsed = raw != null ? double.tryParse(raw.toString()) : null;

    if (parsed != null) return parsed;

    final lat = double.tryParse(profesional['latitude']?.toString() ?? '');
    final lng = double.tryParse(profesional['longitude']?.toString() ?? '');

    if (lat == null || lng == null) return double.infinity;

    return _distance.as(
      LengthUnit.Kilometer,
      origen,
      LatLng(lat, lng),
    );
  }

  Future<int?> _obtenerClienteId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');

    if (id == null || id <= 0) return null;

    return id;
  }

  Future<void> _buscarEmergencia(String tipo) async {
    if (_buscando) return;

    setState(() {
      _buscando = true;
      _mensaje = '';
    });

    final ubicacion = await _obtenerUbicacion();

    if (!mounted) return;

    if (ubicacion == null) {
      setState(() {
        _buscando = false;
        if (_mensaje.isEmpty) {
          _mensaje = 'No se pudo obtener tu ubicación.';
        }
      });
      return;
    }

    List<Map<String, dynamic>> candidatos = [];

    try {
      if (tipo == 'penal') {
        try {
          candidatos = await _api.getProfesionalesCercanos(
            perfil: 'Abogados',
            especialidad: 'Derecho Penal',
            lat: ubicacion.latitude,
            lng: ubicacion.longitude,
            limit: 20,
          );
        } catch (e) {
          debugPrint('Error buscando abogado penal exacto: $e');

          candidatos = await _api.getProfesionalesCercanos(
            perfil: 'Abogados',
            lat: ubicacion.latitude,
            lng: ubicacion.longitude,
            limit: 30,
          );

          final penales = candidatos.where((p) {
            final especialidad =
                (p['especialidad']?.toString() ?? '').toLowerCase();

            return especialidad.contains('penal') ||
                especialidad.contains('criminal');
          }).toList();

          if (penales.isNotEmpty) {
            candidatos = penales;
          }
        }
      } else {
        final List<Map<String, dynamic>> resultados = [];

        try {
          final ajustadores = await _api.getProfesionalesCercanos(
            perfil: 'Ajustadores',
            lat: ubicacion.latitude,
            lng: ubicacion.longitude,
            limit: 20,
          );

          resultados.addAll(ajustadores);
        } catch (e) {
          debugPrint('Error buscando ajustadores: $e');
        }

        try {
          final civiles = await _api.getProfesionalesCercanos(
            perfil: 'Abogados',
            especialidad: 'Derecho Civil',
            lat: ubicacion.latitude,
            lng: ubicacion.longitude,
            limit: 20,
          );

          resultados.addAll(civiles);
        } catch (e) {
          debugPrint('Error buscando abogados civiles exactos: $e');

          try {
            final abogados = await _api.getProfesionalesCercanos(
              perfil: 'Abogados',
              lat: ubicacion.latitude,
              lng: ubicacion.longitude,
              limit: 30,
            );

            final civilesFiltrados = abogados.where((p) {
              final especialidad =
                  (p['especialidad']?.toString() ?? '').toLowerCase();

              return especialidad.contains('civil') ||
                  especialidad.contains('familiar') ||
                  especialidad.contains('mercantil');
            }).toList();

            resultados.addAll(
              civilesFiltrados.isNotEmpty ? civilesFiltrados : abogados,
            );
          } catch (e2) {
            debugPrint('Error buscando abogados generales para civil: $e2');
          }
        }

        candidatos = resultados;
      }

      if (!mounted) return;

      if (candidatos.isEmpty) {
        setState(() {
          _mensaje = 'No hay profesionales disponibles para esta emergencia.';
        });
        return;
      }

      candidatos.sort(
        (a, b) => _distanciaKm(a, ubicacion).compareTo(
          _distanciaKm(b, ubicacion),
        ),
      );

      final seleccionado = candidatos.first;

      _mostrarContacto(
        seleccionado,
        ubicacion,
        tipo,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _mensaje = 'Error al buscar emergencia: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _buscando = false;
        });
      }
    }
  }

  void _mostrarContacto(
    Map<String, dynamic> profesional,
    LatLng ubicacion,
    String tipo,
  ) {
    final nombre = profesional['nombre']?.toString() ?? 'Profesional';
    final especialidad = profesional['especialidad']?.toString() ?? '';
    final estado = profesional['estado']?.toString() ?? 'disponible';
    final distancia = _distanciaKm(profesional, ubicacion);
    final isDisponible = estado.toLowerCase() == 'disponible';
    final colorEstado = isDisponible ? _green : _orange;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 28,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _gold.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(
                          tipo == 'penal'
                              ? Icons.gavel_rounded
                              : Icons.car_crash_rounded,
                          color: _gold,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              especialidad.isNotEmpty
                                  ? especialidad
                                  : tipo == 'penal'
                                      ? 'Abogado penal'
                                      : 'Atención civil / vial',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoBadge(
                        icon: Icons.check_circle_rounded,
                        text: isDisponible ? 'Disponible' : estado,
                        color: colorEstado,
                      ),
                      _InfoBadge(
                        icon: Icons.near_me_rounded,
                        text: distancia.isFinite
                            ? '${distancia.toStringAsFixed(2)} km'
                            : 'Distancia N/D',
                        color: _blue,
                      ),
                      _InfoBadge(
                        icon: Icons.priority_high_rounded,
                        text: 'SOS',
                        color: tipo == 'penal' ? _red : _orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.055),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white.withValues(alpha: 0.74),
                          size: 21,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Se enviará una solicitud urgente al profesional para que la acepte o rechace.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.58),
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _enviandoSolicitud
                          ? null
                          : () => _mostrarDialogoSolicitudSOS(
                                profesional: profesional,
                                tipo: tipo,
                                navigator: Navigator.of(sheetContext),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tipo == 'penal' ? _red : _orange,
                        disabledBackgroundColor:
                            Colors.white.withValues(alpha: 0.12),
                        foregroundColor: Colors.white,
                        disabledForegroundColor:
                            Colors.white.withValues(alpha: 0.35),
                        minimumSize: const Size(double.infinity, 52),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      icon: _enviandoSolicitud
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _enviandoSolicitud
                            ? 'Enviando solicitud...'
                            : 'Enviar solicitud SOS',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _enviarSolicitudSOS({
    required Map<String, dynamic> profesional,
    required String tipo,
    required NavigatorState navigator,
    required String titulo,
    required String descripcion,
  }) async {
    if (_enviandoSolicitud) return;

    final profesionalId = int.tryParse(profesional['id']?.toString() ?? '');

    if (profesionalId == null || profesionalId <= 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profesional inválido.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
      return;
    }

    final clienteId = await _obtenerClienteId();

    if (clienteId == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo identificar al cliente.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
      return;
    }

    final perfilRaw = (profesional['perfil']?.toString() ?? '').trim();
    final servicio = perfilRaw.isNotEmpty
        ? perfilRaw
        : (tipo == 'penal' ? 'Abogados' : 'Ajustadores');

    setState(() {
      _enviandoSolicitud = true;
    });

    try {
      final resp = await _api.solicitarCaso(
        clienteId: clienteId,
        profesionalId: profesionalId,
        servicio: servicio,
        titulo: titulo,
        descripcion: descripcion,
      );

      if (!mounted) return;

      if (navigator.canPop()) {
        navigator.pop();
      }

      final message = resp['message']?.toString() ??
          resp['mensaje']?.toString() ??
          'Solicitud SOS enviada correctamente.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF166534),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo enviar la solicitud SOS: $e'),
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviandoSolicitud = false;
        });
      }
    }
  }

  Future<void> _mostrarDialogoSolicitudSOS({
    required Map<String, dynamic> profesional,
    required String tipo,
    required NavigatorState navigator,
  }) async {
    if (_enviandoSolicitud) return;

    final nombre = (profesional['nombre']?.toString() ?? 'Profesional').trim();
    final tipoTexto = tipo == 'penal' ? 'Penal' : 'Civil / Vial';

    final tituloController = TextEditingController(
      text: 'Solicitud SOS $tipoTexto',
    );

    final descripcionController = TextEditingController(
      text: 'Solicitud urgente generada desde Centro SOS.',
    );

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: (tipo == 'penal' ? _red : _orange)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.assignment_rounded,
                          color: tipo == 'penal' ? _red : _orange,
                        ),
                      ),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Text(
                          'Enviar solicitud SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Se enviará una solicitud de caso a $nombre para que la acepte o rechace.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DarkTextField(
                    controller: tituloController,
                    label: 'Título del caso',
                    icon: Icons.title_rounded,
                    minLines: 1,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 12),
                  _DarkTextField(
                    controller: descripcionController,
                    label: 'Descripción',
                    icon: Icons.notes_rounded,
                    minLines: 3,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Colors.white.withValues(alpha: 0.7),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _enviandoSolicitud
                              ? null
                              : () => Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                tipo == 'penal' ? _red : _orange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: const Text(
                            'Enviar',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmar != true) {
      tituloController.dispose();
      descripcionController.dispose();
      return;
    }

    final titulo = tituloController.text.trim();
    final descripcion = descripcionController.text.trim();

    tituloController.dispose();
    descripcionController.dispose();

    if (titulo.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El título es obligatorio.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
      return;
    }

    await _enviarSolicitudSOS(
      profesional: profesional,
      tipo: tipo,
      navigator: navigator,
      titulo: titulo,
      descripcion: descripcion,
    );
  }

  Widget _buildGlow() {
    return Positioned(
      top: -90,
      left: -100,
      right: -100,
      height: 280,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 0.9,
            colors: [
              const Color(0xFF51202A).withValues(alpha: 0.92),
              const Color(0xFF161322).withValues(alpha: 0.78),
              _bg.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool compact) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -45,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _red.withValues(alpha: 0.08),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: compact ? 58 : 66,
                height: compact ? 58 : 66,
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _red.withValues(alpha: 0.28),
                  ),
                ),
                child: const Icon(
                  Icons.emergency_share_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Centro SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Atención urgente con profesionales cercanos.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: compact ? 12.5 : 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    if (!_buscando && _mensaje.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card2.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.055),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: _green,
                size: 21,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                'Presiona una emergencia. Buscaremos al profesional más cercano disponible.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.60),
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_buscando) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _blue.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _blue.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 27,
              height: 27,
              child: CircularProgressIndicator(
                color: _blue,
                strokeWidth: 2.6,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Buscando profesionales cercanos...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF3A1114),
        border: Border.all(
          color: const Color(0xFF7F1D1D),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFFA4A4),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _mensaje,
              style: const TextStyle(
                color: Color(0xFFFFC6C6),
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton({
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback? onTap,
    required double height,
  }) {
    final disabled = onTap == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: height,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: disabled
                  ? [
                      colors.first.withValues(alpha: 0.35),
                      colors.last.withValues(alpha: 0.35),
                    ]
                  : colors,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
            boxShadow: disabled
                ? []
                : [
                    BoxShadow(
                      color: colors.first.withValues(alpha: 0.30),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -35,
                bottom: -42,
                child: Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.09),
                  size: 132,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 31,
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.17),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.16),
                              ),
                            ),
                            child: Text(
                              badge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      height: 1.04,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      Text(
                        'Solicitar ayuda',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.96),
                          fontSize: 13.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final compact = media.size.width < 380;
    final smallHeight = media.size.height < 720;
    final buttonHeight = smallHeight ? 178.0 : 210.0;

    return Container(
      color: _bg,
      child: Stack(
        children: [
          _buildGlow(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 132),
              children: [
                _buildHeader(compact),
                const SizedBox(height: 14),
                _buildStatusCard(),
                const SizedBox(height: 14),
                _buildEmergencyButton(
                  title: 'Emergencia Penal',
                  subtitle: 'Contacto inmediato con un abogado penal cercano.',
                  badge: 'ALTA PRIORIDAD',
                  icon: Icons.gavel_rounded,
                  colors: const [
                    Color(0xFFDC2626),
                    Color(0xFF991B1B),
                  ],
                  height: buttonHeight,
                  onTap: _buscando ? null : () => _buscarEmergencia('penal'),
                ),
                const SizedBox(height: 14),
                _buildEmergencyButton(
                  title: 'Emergencia Civil',
                  subtitle: 'Contacto inmediato con ajustador o abogado civil.',
                  badge: 'ASISTENCIA RÁPIDA',
                  icon: Icons.car_crash_rounded,
                  colors: const [
                    Color(0xFFF59E0B),
                    Color(0xFFB45309),
                  ],
                  height: buttonHeight,
                  onTap: _buscando ? null : () => _buscarEmergencia('civil'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int minLines;
  final int maxLines;

  const _DarkTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.minLines,
    required this.maxLines,
  });

  static const Color _gold = Color(0xFFD6A84F);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.58),
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(
          icon,
          color: _gold,
        ),
        filled: true,
        fillColor: const Color(0xFF0C1420),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _gold,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}