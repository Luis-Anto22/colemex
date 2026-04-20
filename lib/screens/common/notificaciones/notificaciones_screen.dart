import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets_global/notificaciones_widget.dart';

class NotificacionesScreen extends StatefulWidget {
  final int? profesionalId;

  const NotificacionesScreen({super.key, this.profesionalId});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  int? _profesionalId;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _resolverProfesionalId();
  }

  Future<void> _resolverProfesionalId() async {
    final fromArg = widget.profesionalId ?? 0;
    if (fromArg > 0) {
      setState(() {
        _profesionalId = fromArg;
        _cargando = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final fromSession = prefs.getInt('id') ?? 0;
    if (!mounted) return;
    setState(() {
      _profesionalId = fromSession > 0 ? fromSession : null;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : (_profesionalId == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No se encontro el profesional_id para cargar notificaciones.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  // Conexion con widget global que consume /api/notificaciones.
                  child: NotificacionesWidget(profesionalId: _profesionalId!),
                )),
    );
  }
}
