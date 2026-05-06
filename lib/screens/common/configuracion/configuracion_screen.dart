import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/common_api.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final CommonApi api = CommonApi(ApiClient());

  bool cargando = true;
  bool guardando = false;

  bool notifs = true;
  bool compartirUbicacion = false;

  int profesionalId = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  bool _toBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;

    if (value is bool) return value;

    if (value is num) {
      return value == 1;
    }

    final text = value.toString().trim().toLowerCase();

    return text == '1' ||
        text == 'true' ||
        text == 'si' ||
        text == 'sí' ||
        text == 'activo' ||
        text == 'on';
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();

    profesionalId = prefs.getInt('id') ?? 0;

    if (profesionalId <= 0) {
      setState(() {
        cargando = false;
      });
      return;
    }

    try {
      final data = await api.getConfiguracion(profesionalId);

      if (!mounted) return;

      setState(() {
        notifs = _toBool(
          data['notificaciones'],
          fallback: true,
        );

        compartirUbicacion = _toBool(
          data['compartir_ubicacion'],
          fallback: false,
        );

        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar configuración: $e')),
      );
    }
  }

  Future<void> _guardar() async {
    if (profesionalId <= 0 || guardando) return;

    setState(() {
      guardando = true;
    });

    try {
      await api.actualizarConfiguracion(
        profesionalId: profesionalId,
        notificaciones: notifs,
        compartirUbicacion: compartirUbicacion,
      );

      final data = await api.getConfiguracion(profesionalId);

      if (!mounted) return;

      setState(() {
        notifs = _toBool(
          data['notificaciones'],
          fallback: notifs,
        );

        compartirUbicacion = _toBool(
          data['compartir_ubicacion'],
          fallback: compartirUbicacion,
        );

        guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración guardada')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar configuración: $e')),
      );
    }
  }

  Future<void> _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (cargando)
            const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(),
            ),

          ListTile(
            leading: Icon(Icons.person_outline, color: gold),
            title: const Text('Cuenta'),
            subtitle: Text(
              profesionalId > 0
                  ? 'Profesional ID: $profesionalId'
                  : 'Datos básicos',
            ),
          ),

          const SizedBox(height: 8),

          SwitchListTile(
            value: notifs,
            onChanged: cargando || guardando
                ? null
                : (v) {
                    setState(() {
                      notifs = v;
                    });
                  },
            activeThumbColor: gold,
            title: const Text('Notificaciones'),
            subtitle: const Text('Recibir alertas'),
            secondary: Icon(
              Icons.notifications_active_outlined,
              color: gold,
            ),
          ),

          SwitchListTile(
            value: compartirUbicacion,
            onChanged: cargando || guardando
                ? null
                : (v) {
                    setState(() {
                      compartirUbicacion = v;
                    });
                  },
            activeThumbColor: gold,
            title: const Text('Compartir ubicación'),
            subtitle: const Text('Visible para clientes'),
            secondary: Icon(
              Icons.location_on_outlined,
              color: gold,
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: cargando || guardando ? null : _guardar,
            icon: guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(
              guardando ? 'Guardando...' : 'Guardar configuración',
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: guardando ? null : _cerrarSesion,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}