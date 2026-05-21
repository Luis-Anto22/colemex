import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_services/api_client.dart';

class PerfilClienteScreen extends StatefulWidget {
  const PerfilClienteScreen({super.key});

  @override
  State<PerfilClienteScreen> createState() => _PerfilClienteScreenState();
}

class _PerfilClienteScreenState extends State<PerfilClienteScreen> {
  final ApiClient _api = ApiClient();

  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  int? _clienteId;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _ciudadCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id') ?? 0;

    if (id <= 0) {
      setState(() => _cargando = false);
      return;
    }

    _clienteId = id;

    final res = await _api.get('/clientes/$id');

    if (!mounted) return;

    if (res['success'] == true) {
      final cliente = Map<String, dynamic>.from(res['cliente'] ?? {});

      _nombreCtrl.text = (cliente['nombre'] ?? '').toString();
      _correoCtrl.text = (cliente['correo'] ?? '').toString();
      _telefonoCtrl.text = (cliente['telefono'] ?? '').toString();
      _ciudadCtrl.text = (cliente['ciudad'] ?? '').toString();
    }

    setState(() => _cargando = false);
  }

  Future<void> _guardar() async {
    if (_clienteId == null) return;

    setState(() => _guardando = true);

    final res = await _api.put('/clientes/$_clienteId', {
      'nombre': _nombreCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'ciudad': _ciudadCtrl.text.trim(),
    });

    if (!mounted) return;

    setState(() => _guardando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res['success'] == true
              ? 'Perfil actualizado correctamente'
              : (res['message'] ?? res['mensaje'] ?? 'Error al actualizar'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nombreCtrl,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _correoCtrl,
            enabled: false,
            decoration: const InputDecoration(labelText: 'Correo'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telefonoCtrl,
            decoration: const InputDecoration(labelText: 'Teléfono'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ciudadCtrl,
            decoration: const InputDecoration(labelText: 'Ciudad'),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: const Icon(Icons.save_rounded),
            label: Text(_guardando ? 'Guardando...' : 'Guardar cambios'),
          ),
        ],
      ),
    );
  }
}