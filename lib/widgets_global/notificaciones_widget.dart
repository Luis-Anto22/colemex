import 'package:flutter/material.dart';
import 'package:advocatus/services/api_services/api_client.dart';
import 'package:advocatus/services/api_services/notificaciones_api.dart';
import 'dart:convert';

import '../screens/cliente_panels/calificar_profesional_screen.dart';

class NotificacionesWidget extends StatefulWidget {
  final int? profesionalId;
  final int? clienteId;

  const NotificacionesWidget({
    super.key,
    this.profesionalId,
    this.clienteId,
  });

  @override
  State<NotificacionesWidget> createState() => _NotificacionesWidgetState();
}

class _NotificacionesWidgetState extends State<NotificacionesWidget> {
  final NotificacionesApi _api = NotificacionesApi(ApiClient());

  List<Map<String, dynamic>> _notificaciones = [];

  bool _cargando = true;
  bool _marcandoTodas = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);

    try {
      final items = await _api.listar(
        profesionalId: widget.profesionalId,
        clienteId: widget.clienteId,
        limit: 80,
      );

      if (!mounted) return;

      setState(() {
        _notificaciones = items;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar notificaciones: $e')),
      );
    }
  }

  bool _isLeida(Map<String, dynamic> n) {
    return (n['leido']?.toString() ?? '0') == '1';
  }

  String _texto(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _fecha(dynamic value) {
    final text = _texto(value, 'Fecha no disponible');

    if (text.length >= 16) {
      return text.replaceFirst('T', ' ').substring(0, 16);
    }

    return text;
  }

  IconData _iconoNotificacion(Map<String, dynamic> n) {
    final mensaje = _texto(n['mensaje']).toLowerCase();
    final tipo = _texto(n['tipo']).toLowerCase();

    if (tipo.contains('cita') || mensaje.contains('cita')) {
      return Icons.event_available_outlined;
    }

    if (tipo.contains('pago') ||
        tipo.contains('ingreso') ||
        mensaje.contains('pago') ||
        mensaje.contains('ingreso')) {
      return Icons.payments_outlined;
    }

    if (tipo.contains('caso') ||
        tipo.contains('solicitud') ||
        mensaje.contains('solicitud') ||
        mensaje.contains('caso')) {
      return Icons.folder_open_outlined;
    }

    if (tipo.contains('calificacion') ||
        tipo.contains('calificación') ||
        mensaje.contains('calificacion') ||
        mensaje.contains('calificación')) {
      return Icons.star_outline;
    }

    return Icons.notifications_none_rounded;
  }

  Color _colorNotificacion(Map<String, dynamic> n) {
    final leido = _isLeida(n);
    final mensaje = _texto(n['mensaje']).toLowerCase();
    final tipo = _texto(n['tipo']).toLowerCase();

    if (leido) return Colors.grey;

    if (tipo.contains('pago') ||
        tipo.contains('ingreso') ||
        mensaje.contains('pago') ||
        mensaje.contains('ingreso')) {
      return Colors.green;
    }

    if (tipo.contains('cita') || mensaje.contains('cita')) {
      return Colors.blue;
    }

    if (tipo.contains('calificacion') ||
        tipo.contains('calificación') ||
        mensaje.contains('calificacion') ||
        mensaje.contains('calificación')) {
      return Colors.amber.shade700;
    }

    return Theme.of(context).primaryColor;
  }

  Future<void> _marcarLeida(Map<String, dynamic> n) async {
    final id = int.tryParse(n['id']?.toString() ?? '') ?? 0;
    final leido = _isLeida(n);

    if (id <= 0 || leido) return;

    try {
      await _api.marcarLeida(
        notificacionId: id,
        profesionalId: widget.profesionalId,
        clienteId: widget.clienteId,
      );

      if (!mounted) return;

      setState(() {
        n['leido'] = 1;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo marcar como leída: $e')),
      );
    }
  }

  Future<void> _marcarTodas() async {
    if (_marcandoTodas) return;

    setState(() => _marcandoTodas = true);

    try {
      await _api.marcarTodasLeidas(
        profesionalId: widget.profesionalId,
        clienteId: widget.clienteId,
      );

      if (!mounted) return;

      setState(() {
        for (final item in _notificaciones) {
          item['leido'] = 1;
        }
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron marcar todas como leídas: $e')),
      );
    } finally {
      if (mounted) setState(() => _marcandoTodas = false);
    }
  }

  void _verDetalle(Map<String, dynamic> n) async {
  await _marcarLeida(n);

  if (!mounted) return;

  final titulo = _texto(n['titulo'], 'Detalle de notificación');
  final mensaje = _texto(n['mensaje'], 'Notificación');
  final fecha = _fecha(n['fecha']);
  final leido = _isLeida(n);
  final tipo = _texto(n['tipo'], 'General');
  final color = _colorNotificacion(n);
  final icono = _iconoNotificacion(n);

  Map<String, dynamic> data = {};

  try {
    final raw = n['data'];

    if (raw is String && raw.isNotEmpty) {
      data = Map<String, dynamic>.from(jsonDecode(raw));
    } else if (raw is Map) {
      data = Map<String, dynamic>.from(raw);
    }
  } catch (_) {}

  final profesionalId =
      int.tryParse('${data['profesional_id'] ?? ''}') ?? 0;

  final casoId =
      int.tryParse('${data['caso_id'] ?? ''}') ?? 0;

  final esCalificacion =
      tipo == 'caso_finalizado_calificacion';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(icono, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _detalleLinea(Icons.message_outlined, 'Mensaje', mensaje),

              _detalleLinea(
                Icons.category_outlined,
                'Tipo',
                tipo,
              ),

              _detalleLinea(
                Icons.calendar_today_outlined,
                'Fecha',
                fecha,
              ),

              _detalleLinea(
                leido
                    ? Icons.mark_email_read
                    : Icons.mark_email_unread,
                'Estado',
                leido ? 'Leída' : 'Nueva',
              ),

              if (esCalificacion && profesionalId > 0) ...[
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.star_rounded),
                    label: const Text('Calificar profesional'),
                    onPressed: () async {
                      Navigator.pop(context);

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CalificarProfesionalScreen(
                            profesionalId: profesionalId,
                            casoId: casoId,
                          ),
                        ),
                      );

                      if (mounted) {
                        _cargar();
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

  Widget _detalleLinea(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(int noLeidas) {
    final gold = Theme.of(context).primaryColor;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: gold.withValues(alpha: 0.12),
              child: Icon(Icons.notifications, color: gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notificaciones',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    noLeidas > 0 ? '$noLeidas sin leer' : 'Todo al día',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _marcandoTodas ? null : _marcarTodas,
              child: Text(
                _marcandoTodas ? 'Marcando...' : 'Marcar todas',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificacionCard(Map<String, dynamic> n) {
    final leido = _isLeida(n);
    final titulo = _texto(n['titulo']);
    final mensaje = _texto(n['mensaje'], 'Notificación');
    final fecha = _fecha(n['fecha']);
    final color = _colorNotificacion(n);
    final icono = _iconoNotificacion(n);

    return Card(
      elevation: leido ? 0.8 : 2,
      color: leido ? Colors.white : color.withValues(alpha: 0.045),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: leido ? Colors.grey.shade200 : color.withValues(alpha: 0.25),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _verDetalle(n),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icono, color: color, size: 21),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (titulo.isNotEmpty) ...[
                      Text(
                        titulo,
                        style: TextStyle(
                          fontWeight:
                              leido ? FontWeight.w700 : FontWeight.w900,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      mensaje,
                      style: TextStyle(
                        fontWeight: leido ? FontWeight.w500 : FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fecha,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: leido
                      ? Colors.grey.withValues(alpha: 0.12)
                      : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  leido ? 'Leído' : 'Nuevo',
                  style: TextStyle(
                    color: leido ? Colors.grey.shade700 : color,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccion({
    required String titulo,
    required List<Map<String, dynamic>> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(_notificacionCard),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notificaciones.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 140),
            Icon(Icons.notifications_off_outlined, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Center(
              child: Text(
                'No hay notificaciones',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    final noLeidasItems = _notificaciones.where((n) => !_isLeida(n)).toList();
    final leidasItems = _notificaciones.where((n) => _isLeida(n)).toList();

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _header(noLeidasItems.length),
          _seccion(
            titulo: 'Pendientes',
            items: noLeidasItems,
          ),
          _seccion(
            titulo: 'Leídas',
            items: leidasItems,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}