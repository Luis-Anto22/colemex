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
      if (!mounted) return;

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
        _profesionalId = null;
      } else {
        _profesionalId = id > 0 ? id : null;
        _clienteId = null;
      }

      _cargando = false;
    });
  }

  Future<void> _recargar() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
    });

    await _resolverUsuario();
  }

  Widget _background() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/iconos/mazo-libro.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(.68),
          ),
        ),
      ],
    );
  }

  Widget _loading(Color gold) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF12161C).withOpacity(.90),
          border: Border.all(
            color: gold.withOpacity(.22),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: gold,
            ),
            const SizedBox(height: 14),
            const Text(
              'Cargando notificaciones...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _usuarioNoEncontrado(Color gold) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF12161C).withOpacity(.90),
            border: Border.all(
              color: gold.withOpacity(.22),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_off_outlined,
                color: gold,
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'No se encontró el usuario',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No fue posible cargar tus notificaciones porque no se encontró un cliente o profesional activo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(.72),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _recargar,
                icon: const Icon(Icons.refresh),
                label: const Text('Intentar de nuevo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header({
    required bool esCliente,
    required Color gold,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF12161C).withOpacity(.88),
        border: Border.all(
          color: gold.withOpacity(.22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: gold.withOpacity(.12),
              border: Border.all(
                color: gold.withOpacity(.22),
              ),
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: gold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  esCliente ? 'Mis notificaciones' : 'Centro de notificaciones',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  esCliente
                      ? 'Alertas, respuestas y avances de tus casos.'
                      : 'Asignaciones, avisos y movimientos recientes.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.72),
                    fontSize: 12.5,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenido({
    required bool esCliente,
    required Color gold,
  }) {
    if (_cargando) {
      return _loading(gold);
    }

    if (_profesionalId == null && _clienteId == null) {
      return _usuarioNoEncontrado(gold);
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _recargar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(
                    esCliente: esCliente,
                    gold: gold,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xFF12161C).withOpacity(.88),
                      border: Border.all(
                        color: gold.withOpacity(.18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.22),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: NotificacionesWidget(
                      profesionalId: _profesionalId,
                      clienteId: _clienteId,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esCliente = _clienteId != null;
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
        title: Text(
          esCliente ? 'Mis notificaciones' : 'Notificaciones',
        ),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          _background(),
          _contenido(
            esCliente: esCliente,
            gold: gold,
          ),
        ],
      ),
    );
  }
}