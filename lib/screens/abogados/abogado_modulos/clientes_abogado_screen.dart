import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClientesAbogadoScreen extends StatefulWidget {
  const ClientesAbogadoScreen({super.key});

  @override
  State<ClientesAbogadoScreen> createState() => _ClientesAbogadoScreenState();
}

class _ClientesAbogadoScreenState extends State<ClientesAbogadoScreen> {
  static const String baseUrl = 'https://corporativolegaldigital.com/api';

  final TextEditingController _buscarController = TextEditingController();

  final List<ClienteItem> _clientes = [];
  List<ClienteItem> _clientesFiltrados = [];

  bool _cargando = true;
  String _token = '';

  @override
  void initState() {
    super.initState();
    _inicializar();
    _buscarController.addListener(_filtrarClientes);
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    await _cargarClientes();
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (_token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Map<String, dynamic> _decodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<void> _cargarClientes() async {
    setState(() {
      _cargando = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientes'),
        headers: _headers(),
      );

      final body = _decodeBody(response.body);

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['mensaje']?.toString() ?? 'No se pudieron cargar los clientes',
        );
      }

      final clientesJson = (body['clientes'] as List?) ?? [];

      final clientes = clientesJson
          .whereType<Map<String, dynamic>>()
          .map(ClienteItem.fromJson)
          .toList();

      setState(() {
        _clientes
          ..clear()
          ..addAll(clientes);
        _clientesFiltrados = List<ClienteItem>.from(_clientes);
        _cargando = false;
      });

      _filtrarClientes();
    } catch (e) {
      setState(() {
        _cargando = false;
      });
      _mostrarSnack('Error al cargar clientes');
    }
  }

  void _filtrarClientes() {
    final texto = _buscarController.text.trim().toLowerCase();

    setState(() {
      if (texto.isEmpty) {
        _clientesFiltrados = List<ClienteItem>.from(_clientes);
      } else {
        _clientesFiltrados = _clientes.where((cliente) {
          return cliente.nombre.toLowerCase().contains(texto) ||
              cliente.correo.toLowerCase().contains(texto) ||
              cliente.telefono.toLowerCase().contains(texto) ||
              cliente.ciudad.toLowerCase().contains(texto) ||
              cliente.estado.toLowerCase().contains(texto);
        }).toList();
      }
    });
  }

  void _mostrarSnack(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'inactivo':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  void _verDetalle(ClienteItem cliente) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(cliente.nombre),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detalleFila('Correo', cliente.correo),
                _detalleFila('Teléfono', cliente.telefono),
                _detalleFila('Ciudad', cliente.ciudad),
                _detalleFila('Estado', cliente.estado),
                _detalleFila('Fecha registro', cliente.fechaRegistro),
                _detalleFila('Última conexión', cliente.ultimaConexion),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _detalleFila(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: '$titulo: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: valor.isEmpty ? 'Sin dato' : valor),
          ],
        ),
      ),
    );
  }

  Widget _buscador() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: _buscarController,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, correo, teléfono o ciudad',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: _buscarController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _buscarController.clear();
                    _filtrarClientes();
                  },
                  icon: const Icon(Icons.close),
                )
              : null,
        ),
      ),
    );
  }

  Widget _estadoVacio() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_alt_outlined, size: 64),
            SizedBox(height: 12),
            Text(
              'No hay clientes disponibles',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Cuando existan clientes registrados, aparecerán aquí.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _listaClientes() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_clientesFiltrados.isEmpty) {
      return _estadoVacio();
    }

    return RefreshIndicator(
      onRefresh: _cargarClientes,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _clientesFiltrados.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final cliente = _clientesFiltrados[index];

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                backgroundColor: _colorEstado(cliente.estado).withOpacity(.15),
                child: Icon(
                  Icons.person_outline,
                  color: _colorEstado(cliente.estado),
                ),
              ),
              title: Text(
                cliente.nombre.isEmpty ? 'Sin nombre' : cliente.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Correo: ${cliente.correo.isEmpty ? 'Sin dato' : cliente.correo}'),
                    Text('Teléfono: ${cliente.telefono.isEmpty ? 'Sin dato' : cliente.telefono}'),
                    Text('Ciudad: ${cliente.ciudad.isEmpty ? 'Sin dato' : cliente.ciudad}'),
                    Text('Estado: ${cliente.estado.isEmpty ? 'Sin dato' : cliente.estado}'),
                  ],
                ),
              ),
              trailing: IconButton(
                onPressed: () => _verDetalle(cliente),
                icon: const Icon(Icons.visibility_outlined),
                tooltip: 'Ver detalle',
              ),
              isThreeLine: false,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      body: Column(
        children: [
          _buscador(),
          Expanded(child: _listaClientes()),
        ],
      ),
    );
  }
}

class ClienteItem {
  final int id;
  final String nombre;
  final String correo;
  final String telefono;
  final String ciudad;
  final String estado;
  final String foto;
  final String fechaRegistro;
  final String ultimaConexion;

  ClienteItem({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.ciudad,
    required this.estado,
    required this.foto,
    required this.fechaRegistro,
    required this.ultimaConexion,
  });

  factory ClienteItem.fromJson(Map<String, dynamic> json) {
    return ClienteItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
      correo: (json['correo'] ?? '').toString(),
      telefono: (json['telefono'] ?? '').toString(),
      ciudad: (json['ciudad'] ?? '').toString(),
      estado: (json['estado'] ?? '').toString(),
      foto: (json['foto'] ?? '').toString(),
      fechaRegistro: (json['fecha_registro'] ?? '').toString(),
      ultimaConexion: (json['ultima_conexion'] ?? '').toString(),
    );
  }
}