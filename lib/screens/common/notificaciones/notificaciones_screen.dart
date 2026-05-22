import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets_global/notificaciones_widget.dart';

class NotificacionesScreen extends StatefulWidget {
  final int? profesionalId;
  final int? clienteId;

  const NotificacionesScreen({
    super.key,
    this.profesionalId,
    this.clienteId,
  });

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  int? _profesionalId;
  int? _clienteId;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _resolverUsuario();
  }

  Future<void> _resolverUsuario() async {
    final profesionalArg = widget.profesionalId ?? 0;
    final clienteArg = widget.clienteId ?? 0;

    if (profesionalArg > 0 || clienteArg > 0) {
      setState(() {
        _profesionalId = profesionalArg > 0 ? profesionalArg : null;
        _clienteId = clienteArg > 0 ? clienteArg : null;
        _cargando = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final perfil = (prefs.getString('perfil') ?? '').toLowerCase().trim();
    final id = prefs.getInt('id') ?? 0;

    if (!mounted) return;

    setState(() {
      if (perfil.contains('cliente')) {
        _clienteId = id > 0 ? id : null;
      } else {
        _profesionalId = id > 0 ? id : null;
      }

      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final esCliente = _clienteId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esCliente ? 'Mis notificaciones' : 'Notificaciones'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : (_profesionalId == null && _clienteId == null)
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No se encontró el usuario para cargar notificaciones.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: NotificacionesWidget(
                    profesionalId: _profesionalId,
                    clienteId: _clienteId,
                  ),
                ),
    );
  }
}