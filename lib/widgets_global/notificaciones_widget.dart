import 'package:flutter/material.dart';
import 'package:advocatus/services/api_services/api_client.dart';
import 'package:advocatus/services/api_services/notificaciones_api.dart';

class NotificacionesWidget extends StatefulWidget {
  final int profesionalId;

  const NotificacionesWidget({
    super.key,
    required this.profesionalId,
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
        limit: 80,
      );
      if (!mounted) return;
      setState(() {
        _notificaciones = items;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  Future<void> _marcarLeida(Map<String, dynamic> n) async {
    final id = int.tryParse(n['id']?.toString() ?? '') ?? 0;
    final leido = (n['leido']?.toString() ?? '0') == '1';
    if (id <= 0 || leido) return;

    try {
      await _api.marcarLeida(
        notificacionId: id,
        profesionalId: widget.profesionalId,
      );
      if (!mounted) return;
      setState(() {
        n['leido'] = 1;
      });
    } catch (_) {}
  }

  Future<void> _marcarTodas() async {
    if (_marcandoTodas) return;
    setState(() => _marcandoTodas = true);
    try {
      await _api.marcarTodasLeidas(profesionalId: widget.profesionalId);
      if (!mounted) return;
      setState(() {
        for (final item in _notificaciones) {
          item['leido'] = 1;
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudieron marcar todas como leídas'),
        ),
      );
    } finally {
      if (mounted) setState(() => _marcandoTodas = false);
    }
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
          children: const [
            SizedBox(height: 140),
            Center(child: Text('No hay notificaciones')),
          ],
        ),
      );
    }

    final noLeidas = _notificaciones
        .where((n) => (n['leido']?.toString() ?? '0') != '1')
        .length;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.blue),
            title: const Text('Notificaciones'),
            subtitle: Text(
              noLeidas > 0 ? '$noLeidas sin leer' : 'Todo al día',
            ),
            trailing: TextButton(
              onPressed: _marcandoTodas ? null : _marcarTodas,
              child: Text(_marcandoTodas ? 'Marcando...' : 'Marcar todas'),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _cargar,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _notificaciones.length,
                itemBuilder: (_, i) {
                  final n = _notificaciones[i];
                  final leido = (n['leido']?.toString() ?? '0') == '1';

                  return ListTile(
                    onTap: () => _marcarLeida(n),
                    leading: Icon(
                      leido
                          ? Icons.mark_email_read
                          : Icons.notifications_active,
                      color: leido ? Colors.grey : Colors.red,
                    ),
                    title: Text(n['mensaje']?.toString() ?? ''),
                    subtitle: Text('Fecha: ${n['fecha']?.toString() ?? ''}'),
                    trailing: Text(
                      leido ? 'Leído' : 'Nuevo',
                      style: TextStyle(
                        color: leido ? Colors.grey : Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}