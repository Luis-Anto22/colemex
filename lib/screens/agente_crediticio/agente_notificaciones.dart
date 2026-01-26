import 'package:flutter/material.dart';
import 'api_service_crediticio.dart';

class AgenteNotificaciones extends StatefulWidget {
  final int? idAgente;
  const AgenteNotificaciones({super.key, this.idAgente});

  @override
  State<AgenteNotificaciones> createState() => _AgenteNotificacionesState();
}

class _AgenteNotificacionesState extends State<AgenteNotificaciones> {
  List<dynamic> _notificaciones = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    try {
      final data = await ApiServiceCrediticio.listarNotificaciones(widget.idAgente ?? 0);
      setState(() {
        _notificaciones = data;
        _cargando = false;
      });
    } catch (e) {
      debugPrint("❌ Error al cargar notificaciones: $e");
      setState(() => _cargando = false);
    }
  }

  Future<void> _marcarLeida(int id) async {
    try {
      await ApiServiceCrediticio.leerNotificacion({
        "id": id,
        "profesional_id": widget.idAgente ?? 0,
      });
      _cargarNotificaciones();
    } catch (e) {
      debugPrint("❌ Error al marcar notificación: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones"),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _notificaciones.isEmpty
              ? const Center(child: Text("No hay notificaciones"))
              : ListView.builder(
                  itemCount: _notificaciones.length,
                  itemBuilder: (context, index) {
                    final notif = _notificaciones[index];
                    final mensaje = notif["mensaje"] ?? "";
                    final fecha = notif["fecha"] ?? "";
                    final leido = notif["leido"] == 1;

                    return ListTile(
                      leading: Icon(
                        leido ? Icons.mark_email_read : Icons.mark_email_unread,
                        color: leido ? Colors.green : Colors.red,
                      ),
                      title: Text(mensaje),
                      subtitle: Text(fecha),
                      trailing: !leido
                          ? IconButton(
                              icon: const Icon(Icons.done),
                              onPressed: () => _marcarLeida(notif["id"]),
                            )
                          : null,
                    );
                  },
                ),
    );
  }
}