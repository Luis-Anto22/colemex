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
  bool notifs = true;
  bool compartirUbicacion = false;
  int profesionalId = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    profesionalId = prefs.getInt('id') ?? 0;
    if (profesionalId <= 0) {
      setState(() => cargando = false);
      return;
    }
    try {
      final data = await api.getConfiguracion(profesionalId);
      if (!mounted) return;
      setState(() {
        notifs = (data['notificaciones'] ?? 1).toString() == '1';
        compartirUbicacion =
            (data['compartir_ubicacion'] ?? 0).toString() == '1';
        cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => cargando = false);
    }
  }

  Future<void> _guardar() async {
    if (profesionalId <= 0) return;
    try {
      await api.actualizarConfiguracion(
        profesionalId: profesionalId,
        notificaciones: notifs,
        compartirUbicacion: compartirUbicacion,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuracion guardada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracion')),
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
            subtitle: const Text('Datos basicos'),
            onTap: () {},
          ),
          SwitchListTile(
            value: notifs,
            onChanged: (v) => setState(() => notifs = v),
            activeThumbColor: gold,
            title: const Text('Notificaciones'),
            subtitle: const Text('Recibir alertas'),
          ),
          SwitchListTile(
            value: compartirUbicacion,
            onChanged: (v) => setState(() => compartirUbicacion = v),
            activeThumbColor: gold,
            title: const Text('Compartir ubicacion'),
            subtitle: const Text('Visible para clientes'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _guardar,
            icon: const Icon(Icons.save),
            label: const Text('Guardar configuracion'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesion'),
          ),
        ],
      ),
    );
  }
}
