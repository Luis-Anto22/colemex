import 'package:flutter/material.dart';
import 'package:advocatus/services/api_services/api_client.dart';
import 'package:advocatus/services/api_services/notificaciones_api.dart';

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
    if (!mounted) return;

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
    final value = n['leido'] ?? n['leida'] ?? n['visto'] ?? n['vista'] ?? 0;
    return value.toString() == '1' || value.toString().toLowerCase() == 'true';
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

  Map<String, dynamic> _data(Map<String, dynamic> n) {
    final raw = n['data'];

    if (raw is Map<String, dynamic>) {
      return raw;
    }

    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }

    return {};
  }

  String _valor(
    Map<String, dynamic> n,
    List<String> keys, [
    String fallback = '',
  ]) {
    final data = _data(n);

    for (final key in keys) {
      final topValue = n[key];
      final topText = _texto(topValue);

      if (topText.isNotEmpty) {
        return topText;
      }

      final dataValue = data[key];
      final dataText = _texto(dataValue);

      if (dataText.isNotEmpty) {
        return dataText;
      }
    }

    return fallback;
  }

  bool _boolValor(
    Map<String, dynamic> n,
    List<String> keys, {
    bool fallback = false,
  }) {
    final data = _data(n);

    for (final key in keys) {
      final value = n.containsKey(key) ? n[key] : data[key];

      if (value == null) continue;

      if (value is bool) return value;
      if (value is num) return value.toInt() == 1;

      final text = value.toString().toLowerCase().trim();

      if (text == '1' || text == 'true' || text == 'si' || text == 'sí') {
        return true;
      }

      if (text == '0' || text == 'false' || text == 'no') {
        return false;
      }
    }

    return fallback;
  }

  IconData _iconoNotificacion(Map<String, dynamic> n) {
    final mensaje = _texto(n['mensaje']).toLowerCase();
    final titulo = _texto(n['titulo']).toLowerCase();
    final tipo = _texto(n['tipo']).toLowerCase();

    if (tipo.contains('cita') ||
        mensaje.contains('cita') ||
        titulo.contains('cita')) {
      return Icons.event_available_outlined;
    }

    if (tipo.contains('pago') ||
        tipo.contains('ingreso') ||
        mensaje.contains('pago') ||
        mensaje.contains('ingreso') ||
        titulo.contains('pago')) {
      return Icons.payments_outlined;
    }

    if (tipo.contains('caso') ||
        tipo.contains('solicitud') ||
        mensaje.contains('solicitud') ||
        mensaje.contains('caso') ||
        mensaje.contains('acept') ||
        titulo.contains('caso') ||
        titulo.contains('solicitud') ||
        titulo.contains('acept')) {
      return Icons.folder_open_outlined;
    }

    if (tipo.contains('calificacion') ||
        tipo.contains('calificación') ||
        mensaje.contains('calificacion') ||
        mensaje.contains('calificación') ||
        titulo.contains('calificacion') ||
        titulo.contains('calificación')) {
      return Icons.star_outline;
    }

    if (tipo.contains('alerta') ||
        mensaje.contains('urgente') ||
        mensaje.contains('sos') ||
        titulo.contains('urgente')) {
      return Icons.warning_amber_rounded;
    }

    return Icons.notifications_none_rounded;
  }

  Color _colorNotificacion(Map<String, dynamic> n) {
    final leido = _isLeida(n);
    final mensaje = _texto(n['mensaje']).toLowerCase();
    final titulo = _texto(n['titulo']).toLowerCase();
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

    if (tipo.contains('alerta') ||
        mensaje.contains('urgente') ||
        mensaje.contains('sos') ||
        titulo.contains('urgente')) {
      return Colors.redAccent;
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
        n['leida'] = 1;
        n['visto'] = 1;
        n['vista'] = 1;
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
          item['leida'] = 1;
          item['visto'] = 1;
          item['vista'] = 1;
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

  Future<void> _verDetalle(Map<String, dynamic> n) async {
    await _marcarLeida(n);

    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleNotificacionScreen(
          notificacion: Map<String, dynamic>.from(n),
          icono: _iconoNotificacion(n),
          color: _colorNotificacion(n),
          profesionalId: widget.profesionalId,
        ),
      ),
    );

    if (!mounted) return;

    if (result is Map && result['recargar'] == true) {
      await _cargar();

      final mensaje = result['mensaje']?.toString() ?? '';
      if (mensaje.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje)),
        );
      }
    }
  }

  Widget _header(int noLeidas) {
    final gold = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(
          color: noLeidas > 0 ? gold.withOpacity(.28) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                backgroundColor: gold.withOpacity(.12),
                child: Icon(Icons.notifications, color: gold),
              ),
              if (noLeidas > 0)
                Positioned(
                  right: -3,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      noLeidas > 99 ? '99+' : '$noLeidas',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notificaciones',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  noLeidas > 0
                      ? '$noLeidas pendiente(s) por revisar'
                      : 'Todo al día',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _marcandoTodas || noLeidas == 0 ? null : _marcarTodas,
            child: Text(
              _marcandoTodas ? 'Marcando...' : 'Marcar todas',
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificacionCard(Map<String, dynamic> n) {
    final leido = _isLeida(n);

    final tituloCaso = _valor(
      n,
      [
        'titulo_caso',
        'caso_titulo',
        'nombre_caso',
        'titulo_del_caso',
        'asunto',
      ],
    );

    final titulo = tituloCaso.isNotEmpty
        ? tituloCaso
        : _texto(n['titulo'], 'Notificación');

    final clienteNombre = _valor(
      n,
      [
        'cliente_nombre',
        'nombre_cliente',
      ],
    );

    final mensaje = _texto(n['mensaje'], 'Notificación');
    final fecha = _fecha(n['fecha'] ?? n['created_at']);
    final color = _colorNotificacion(n);
    final icono = _iconoNotificacion(n);

    final puedeAceptar = _boolValor(n, ['puede_aceptar']);
    final puedeRechazar = _boolValor(n, ['puede_rechazar']);
    final tieneAccion = puedeAceptar || puedeRechazar;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: leido ? Colors.white : color.withOpacity(.055),
        border: Border.all(
          color: leido ? Colors.grey.shade200 : color.withOpacity(.28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(leido ? .035 : .07),
            blurRadius: leido ? 8 : 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _verDetalle(n),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: color.withOpacity(.12),
                    child: Icon(icono, color: color, size: 22),
                  ),
                  if (!leido)
                    Positioned(
                      right: -1,
                      top: -1,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontWeight: leido ? FontWeight.w700 : FontWeight.w900,
                        fontSize: 14.7,
                        color: Colors.black87,
                      ),
                    ),
                    if (clienteNombre.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 15,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              clienteNombre,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 12.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      mensaje,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: leido ? FontWeight.w500 : FontWeight.w700,
                        fontSize: 13.5,
                        height: 1.28,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            fecha,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: tieneAccion
                          ? Colors.redAccent.withOpacity(.12)
                          : leido
                              ? Colors.grey.withOpacity(.12)
                              : color.withOpacity(.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tieneAccion
                          ? 'Acción'
                          : leido
                              ? 'Leído'
                              : 'Nuevo',
                      style: TextStyle(
                        color: tieneAccion
                            ? Colors.redAccent
                            : leido
                                ? Colors.grey.shade700
                                : color,
                        fontWeight: FontWeight.w900,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccion({
    required String titulo,
    required String subtitulo,
    required List<Map<String, dynamic>> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: TextStyle(
                  fontSize: 12.2,
                  color: Colors.white.withOpacity(.70),
                ),
              ),
            ],
          ),
        ),
        ...items.map(_notificacionCard),
      ],
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 90),
        Center(
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.07),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 58,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No hay notificaciones',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Cuando tengas avisos, solicitudes o movimientos aparecerán aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    if (_notificaciones.isEmpty) {
      return _emptyState();
    }

    final noLeidasItems = _notificaciones.where((n) => !_isLeida(n)).toList();
    final leidasItems = _notificaciones.where((n) => _isLeida(n)).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(noLeidasItems.length),
        _seccion(
          titulo: 'Pendientes',
          subtitulo: 'Notificaciones nuevas o sin revisar.',
          items: noLeidasItems,
        ),
        _seccion(
          titulo: 'Leídas',
          subtitulo: 'Historial reciente de avisos revisados.',
          items: leidasItems,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class DetalleNotificacionScreen extends StatefulWidget {
  final Map<String, dynamic> notificacion;
  final IconData icono;
  final Color color;
  final int? profesionalId;

  const DetalleNotificacionScreen({
    super.key,
    required this.notificacion,
    required this.icono,
    required this.color,
    this.profesionalId,
  });

  @override
  State<DetalleNotificacionScreen> createState() =>
      _DetalleNotificacionScreenState();
}

class _DetalleNotificacionScreenState extends State<DetalleNotificacionScreen> {
  final NotificacionesApi _api = NotificacionesApi(ApiClient());

  late Map<String, dynamic> _notificacion;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _notificacion = Map<String, dynamic>.from(widget.notificacion);
  }

  Map<String, dynamic> _data() {
    final raw = _notificacion['data'];

    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);

    return {};
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

  String _valor(List<String> keys, [String fallback = '']) {
    final data = _data();

    for (final key in keys) {
      final topValue = _notificacion[key];
      final topText = _texto(topValue);

      if (topText.isNotEmpty) {
        return topText;
      }

      final dataValue = data[key];
      final dataText = _texto(dataValue);

      if (dataText.isNotEmpty) {
        return dataText;
      }
    }

    return fallback;
  }

  bool _boolValor(List<String> keys, {bool fallback = false}) {
    final data = _data();

    for (final key in keys) {
      final value = _notificacion.containsKey(key) ? _notificacion[key] : data[key];

      if (value == null) continue;

      if (value is bool) return value;
      if (value is num) return value.toInt() == 1;

      final text = value.toString().toLowerCase().trim();

      if (text == '1' || text == 'true' || text == 'si' || text == 'sí') {
        return true;
      }

      if (text == '0' || text == 'false' || text == 'no') {
        return false;
      }
    }

    return fallback;
  }

  bool _isLeida() {
    final value =
        _notificacion['leido'] ??
        _notificacion['leida'] ??
        _notificacion['visto'] ??
        _notificacion['vista'] ??
        0;

    return value.toString() == '1' || value.toString().toLowerCase() == 'true';
  }

  String _tipoBonito(String value) {
    final limpio = value
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim()
        .toLowerCase();

    if (limpio.isEmpty) return 'General';

    return limpio
        .split(' ')
        .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }

  int _notificacionId() {
    return int.tryParse(_notificacion['id']?.toString() ?? '') ?? 0;
  }

  int _profesionalId() {
    final fromWidget = widget.profesionalId ?? 0;
    if (fromWidget > 0) return fromWidget;

    return int.tryParse(
          _valor([
            'profesional_id',
            'abogado_id',
            'investigador_id',
          ]),
        ) ??
        0;
  }

  Future<void> _aceptarCaso() async {
    final notificacionId = _notificacionId();
    final profesionalId = _profesionalId();

    if (notificacionId <= 0 || profesionalId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo identificar la solicitud o el profesional.'),
        ),
      );
      return;
    }

    setState(() => _procesando = true);

    try {
      final nueva = await _api.aceptarCaso(
        notificacionId: notificacionId,
        profesionalId: profesionalId,
      );

      if (!mounted) return;

      setState(() {
        _notificacion = nueva;
        _procesando = false;
      });

      Navigator.pop(context, {
        'recargar': true,
        'mensaje': 'Caso aceptado correctamente.',
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _procesando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo aceptar el caso: $e')),
      );
    }
  }

  Future<void> _rechazarCaso() async {
    final motivoController = TextEditingController();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rechazar caso'),
          content: TextField(
            controller: motivoController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Motivo opcional',
              hintText: 'Escribe el motivo del rechazo...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Rechazar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    final notificacionId = _notificacionId();
    final profesionalId = _profesionalId();

    if (notificacionId <= 0 || profesionalId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo identificar la solicitud o el profesional.'),
        ),
      );
      return;
    }

    setState(() => _procesando = true);

    try {
      final nueva = await _api.rechazarCaso(
        notificacionId: notificacionId,
        profesionalId: profesionalId,
        motivo: motivoController.text,
      );

      if (!mounted) return;

      setState(() {
        _notificacion = nueva;
        _procesando = false;
      });

      Navigator.pop(context, {
        'recargar': true,
        'mensaje': 'Caso rechazado correctamente.',
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _procesando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo rechazar el caso: $e')),
      );
    }
  }

  void _modificarCaso() {
    final casoId = _valor(['caso_id', 'casoId', 'id_caso']);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          casoId.isEmpty
              ? 'Todavía no hay un caso vinculado para modificar.'
              : 'Abre el módulo de casos asignados para modificar el caso #$casoId.',
        ),
      ),
    );
  }

  List<MapEntry<String, dynamic>> _extras() {
    const ocultar = {
      'id',
      'titulo',
      'mensaje',
      'tipo',
      'fecha',
      'created_at',
      'updated_at',
      'leido',
      'leida',
      'visto',
      'vista',
      'data',
      'caso_id',
      'casoId',
      'id_caso',
      'cliente_id',
      'profesional_id',
      'abogado_id',
      'investigador_id',
      'estado',
      'estatus',
      'status',
      'cliente_nombre',
      'nombre_cliente',
      'cliente_telefono',
      'titulo_caso',
      'caso_titulo',
      'nombre_caso',
      'descripcion_caso',
      'motivo_caso',
      'estado_caso',
      'estado_solicitud',
      'puede_aceptar',
      'puede_rechazar',
      'puede_modificar',
    };

    final merged = <String, dynamic>{
      ..._data(),
      ..._notificacion,
    };

    return merged.entries.where((entry) {
      final key = entry.key.toString();
      final value = entry.value;

      if (ocultar.contains(key)) return false;
      if (value == null) return false;
      if (value is Map || value is List) return false;
      if (value.toString().trim().isEmpty) return false;

      return true;
    }).toList();
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color gold,
  }) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: gold.withOpacity(.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gold, size: 21),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.65),
                    fontSize: 12.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.2,
                    height: 1.32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color chipColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: chipColor.withOpacity(.28),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _acciones({
    required bool puedeAceptar,
    required bool puedeRechazar,
    required bool puedeModificar,
  }) {
    if (!puedeAceptar && !puedeRechazar && !puedeModificar) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF12161C).withOpacity(.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Acciones disponibles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (_procesando)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
          if (puedeAceptar)
            ElevatedButton.icon(
              onPressed: _procesando ? null : _aceptarCaso,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Aceptar caso'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          if (puedeAceptar && puedeRechazar) const SizedBox(height: 10),
          if (puedeRechazar)
            OutlinedButton.icon(
              onPressed: _procesando ? null : _rechazarCaso,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Rechazar caso'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          if ((puedeAceptar || puedeRechazar) && puedeModificar)
            const SizedBox(height: 10),
          if (puedeModificar)
            OutlinedButton.icon(
              onPressed: _procesando ? null : _modificarCaso,
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text('Modificar / gestionar caso'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(.32)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? theme.primaryColor;

    final tituloCaso = _valor([
      'titulo_caso',
      'caso_titulo',
      'nombre_caso',
      'titulo_del_caso',
      'asunto',
    ]);

    final titulo = tituloCaso.isNotEmpty
        ? tituloCaso
        : _texto(
            _notificacion['titulo'],
            'Detalle de notificación',
          );

    final mensaje = _texto(
      _notificacion['mensaje'],
      'Sin mensaje disponible.',
    );

    final tipoOriginal = _texto(
      _notificacion['tipo'],
      'General',
    );

    final tipo = _tipoBonito(tipoOriginal);

    final fecha = _fecha(
      _notificacion['fecha'] ?? _notificacion['created_at'],
    );

    final casoId = _valor([
      'caso_id',
      'casoId',
      'id_caso',
    ]);

    final clienteId = _valor([
      'cliente_id',
    ]);

    final clienteNombre = _valor([
      'cliente_nombre',
      'nombre_cliente',
    ]);

    final clienteTelefono = _valor([
      'cliente_telefono',
      'telefono_cliente',
    ]);

    final profesionalId = _valor([
      'profesional_id',
      'abogado_id',
      'investigador_id',
    ]);

    final profesionalNombre = _valor([
      'profesional_nombre',
      'nombre_profesional',
    ]);

    final descripcionCaso = _valor([
      'descripcion_caso',
      'motivo_caso',
      'descripcion',
      'motivo',
    ]);

    final estadoCaso = _valor([
      'estado_caso',
      'estado',
      'estatus',
      'status',
    ]);

    final estadoSolicitud = _valor([
      'estado_solicitud',
    ], _isLeida() ? 'Leída' : 'Nueva');

    final puedeAceptar = _boolValor(['puede_aceptar']);
    final puedeRechazar = _boolValor(['puede_rechazar']);
    final puedeModificar = _boolValor(['puede_modificar']);

    final extras = _extras();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
        title: const Text('Detalle de notificación'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/iconos/mazo-libro.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(.70),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12161C).withOpacity(.90),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: gold.withOpacity(.20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.28),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: widget.color.withOpacity(.14),
                                    border: Border.all(
                                      color: widget.color.withOpacity(.26),
                                    ),
                                  ),
                                  child: Icon(
                                    widget.icono,
                                    color: widget.color,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        titulo,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          height: 1.15,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _chip(tipo, widget.color),
                                          _chip(estadoSolicitud, gold),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Mensaje',
                              style: TextStyle(
                                color: Colors.white.withOpacity(.65),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              mensaje,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.38,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12161C).withOpacity(.90),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: gold.withOpacity(.18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información del caso',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _infoCard(
                              icon: Icons.person_outline,
                              label: 'Cliente',
                              value: clienteNombre.isEmpty
                                  ? 'No disponible'
                                  : clienteNombre,
                              gold: gold,
                            ),
                            _infoCard(
                              icon: Icons.phone_outlined,
                              label: 'Teléfono del cliente',
                              value: clienteTelefono.isEmpty
                                  ? 'No disponible'
                                  : clienteTelefono,
                              gold: gold,
                            ),
                            _infoCard(
                              icon: Icons.title_outlined,
                              label: 'Título del caso',
                              value: tituloCaso.isEmpty
                                  ? titulo
                                  : tituloCaso,
                              gold: gold,
                            ),
                            _infoCard(
                              icon: Icons.description_outlined,
                              label: 'Descripción / motivo',
                              value: descripcionCaso.isEmpty
                                  ? 'No disponible'
                                  : descripcionCaso,
                              gold: gold,
                            ),
                            _infoCard(
                              icon: Icons.calendar_today_outlined,
                              label: 'Fecha',
                              value: fecha,
                              gold: gold,
                            ),
                            _infoCard(
                              icon: Icons.folder_open_outlined,
                              label: 'Caso ID',
                              value: casoId.isEmpty
                                  ? 'No vinculado a un caso'
                                  : casoId,
                              gold: gold,
                            ),
                            _infoCard(
                              icon: Icons.person_pin_outlined,
                              label: 'Cliente ID',
                              value: clienteId.isEmpty
                                  ? 'No disponible'
                                  : clienteId,
                              gold: gold,
                            ),
                            _infoCard(
                              icon: Icons.badge_outlined,
                              label: 'Profesional',
                              value: profesionalNombre.isNotEmpty
                                  ? profesionalNombre
                                  : profesionalId.isEmpty
                                      ? 'No disponible'
                                      : 'ID $profesionalId',
                              gold: gold,
                            ),
                            _infoCard(
                              icon: Icons.verified_outlined,
                              label: 'Estado del caso',
                              value: estadoCaso.isEmpty
                                  ? estadoSolicitud
                                  : estadoCaso,
                              gold: gold,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _acciones(
                        puedeAceptar: puedeAceptar,
                        puedeRechazar: puedeRechazar,
                        puedeModificar: puedeModificar,
                      ),

                      if (extras.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12161C).withOpacity(.90),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: gold.withOpacity(.18),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Información adicional',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...extras.map(
                                (entry) => _infoCard(
                                  icon: Icons.info_outline,
                                  label: entry.key.toString(),
                                  value: entry.value.toString(),
                                  gold: gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      ElevatedButton.icon(
                        onPressed: _procesando
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Volver a notificaciones'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}