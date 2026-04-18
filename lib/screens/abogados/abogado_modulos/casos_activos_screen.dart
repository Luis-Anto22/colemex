import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CasosActivosScreen extends StatefulWidget {
  const CasosActivosScreen({super.key});

  @override
  State<CasosActivosScreen> createState() => _CasosActivosScreenState();
}

class _CasosActivosScreenState extends State<CasosActivosScreen> {
  static const String baseUrl = 'https://corporativolegaldigital.com/api';

  final List<CasoItem> _casos = [];
  final List<ClienteItem> _clientes = [];

  bool _cargandoCasos = true;
  bool _cargandoClientes = true;

  int? _profesionalId;
  String _token = '';

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id') ?? 0;
    final token = prefs.getString('token') ?? '';

    _profesionalId = id > 0 ? id : null;
    _token = token;

    if (_profesionalId == null) {
      setState(() {
        _cargandoCasos = false;
        _cargandoClientes = false;
      });
      _mostrarSnack('No se encontró la sesión del profesional');
      return;
    }

    await Future.wait([
      _cargarClientes(),
      _cargarCasos(),
    ]);
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
      _cargandoClientes = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientes'),
        headers: _headers(),
      );

      final body = _decodeBody(response.body);

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['mensaje']?.toString() ?? 'Error al cargar clientes',
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
        _cargandoClientes = false;
      });
    } catch (e) {
      setState(() {
        _clientes.clear();
        _cargandoClientes = false;
      });
      _mostrarSnack('Error al cargar clientes');
    }
  }

  Future<void> _cargarCasos() async {
    if (_profesionalId == null) return;

    setState(() {
      _cargandoCasos = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/casos/mis-casos/$_profesionalId'),
        headers: _headers(),
      );

      final body = _decodeBody(response.body);

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['mensaje']?.toString() ?? 'Error al cargar casos',
        );
      }

      final casosJson = (body['casos'] as List?) ?? [];

      final casos = casosJson
          .whereType<Map<String, dynamic>>()
          .map(CasoItem.fromJson)
          .toList();

      setState(() {
        _casos
          ..clear()
          ..addAll(casos);
        _cargandoCasos = false;
      });
    } catch (e) {
      setState(() {
        _cargandoCasos = false;
      });
      _mostrarSnack('Error al cargar casos');
    }
  }

  Future<void> _abrirFormulario({CasoItem? item}) async {
    if (_cargandoClientes) {
      _mostrarSnack('Espera, se están cargando los clientes');
      return;
    }

    if (_clientes.isEmpty) {
      _mostrarSnack(
        'No hay clientes disponibles. Revisa la API /api/clientes o crea clientes primero.',
      );
      return;
    }

    final resultado = await Navigator.push<CasoFormResult>(
      context,
      MaterialPageRoute(
        builder: (_) => CasoFormularioScreen(
          itemInicial: item,
          clientes: _clientes,
        ),
      ),
    );

    if (resultado == null) return;

    if (item == null) {
      await _crearCaso(resultado);
    } else {
      await _actualizarCaso(item.id, resultado);
    }
  }

  Future<void> _crearCaso(CasoFormResult form) async {
    if (_profesionalId == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/casos'),
        headers: _headers(),
        body: jsonEncode({
          'profesional_id': _profesionalId,
          'cliente_id': form.clienteId,
          'servicio': form.servicio,
          'titulo': form.titulo,
          'descripcion': form.descripcion,
          'estado': form.estado,
        }),
      );

      final body = _decodeBody(response.body);

      if (response.statusCode != 201 || body['success'] != true) {
        throw Exception(
          body['mensaje']?.toString() ?? 'No se pudo crear el caso',
        );
      }

      _mostrarSnack('Caso creado correctamente');
      await _cargarCasos();
    } catch (e) {
      _mostrarSnack('Error al crear caso');
    }
  }

  Future<void> _actualizarCaso(int casoId, CasoFormResult form) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/casos/$casoId'),
        headers: _headers(),
        body: jsonEncode({
          'cliente_id': form.clienteId,
          'servicio': form.servicio,
          'titulo': form.titulo,
          'descripcion': form.descripcion,
          'estado': form.estado,
        }),
      );

      final body = _decodeBody(response.body);

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['mensaje']?.toString() ?? 'No se pudo actualizar el caso',
        );
      }

      _mostrarSnack('Caso actualizado correctamente');
      await _cargarCasos();
    } catch (e) {
      _mostrarSnack('Error al actualizar caso');
    }
  }

  Future<void> _eliminarCaso(CasoItem item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar caso'),
        content: Text('¿Seguro que quieres eliminar el caso "${item.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/casos/${item.id}'),
        headers: _headers(),
      );

      final body = _decodeBody(response.body);

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['mensaje']?.toString() ?? 'No se pudo eliminar el caso',
        );
      }

      _mostrarSnack('Caso eliminado correctamente');
      await _cargarCasos();
    } catch (e) {
      _mostrarSnack('Error al eliminar caso');
    }
  }

  void _mostrarSnack(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      case 'finalizado':
        return Colors.green;
      case 'cancelado':
        return Colors.redAccent;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _estadoVacio() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined, size: 64),
            SizedBox(height: 12),
            Text(
              'Aún no hay casos registrados',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Presiona el botón + para crear un nuevo caso.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bannerClientes() {
    if (_cargandoClientes) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Cargando clientes...',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    if (_clientes.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No se pudieron cargar clientes. Revisa la API /api/clientes o crea clientes primero.',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _listaCasos() {
    if (_cargandoCasos) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_casos.isEmpty) {
      return _estadoVacio();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          _cargarClientes(),
          _cargarCasos(),
        ]);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _casos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _casos[index];

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                backgroundColor: _colorEstado(item.estado).withOpacity(.15),
                child: Icon(
                  Icons.folder_open_outlined,
                  color: _colorEstado(item.estado),
                ),
              ),
              title: Text(
                item.titulo,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cliente: ${item.clienteNombre}'),
                    Text('Servicio: ${item.servicio}'),
                    Text('Estado: ${item.estado}'),
                    if (item.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(item.descripcion),
                    ],
                  ],
                ),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'editar') {
                    _abrirFormulario(item: item);
                  } else if (value == 'eliminar') {
                    _eliminarCaso(item);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: Text('Eliminar'),
                  ),
                ],
              ),
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
        title: const Text('Casos activos'),
      ),
      body: Column(
        children: [
          _bannerClientes(),
          Expanded(child: _listaCasos()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CasoFormularioScreen extends StatefulWidget {
  final CasoItem? itemInicial;
  final List<ClienteItem> clientes;

  const CasoFormularioScreen({
    super.key,
    this.itemInicial,
    required this.clientes,
  });

  @override
  State<CasoFormularioScreen> createState() => _CasoFormularioScreenState();
}

class _CasoFormularioScreenState extends State<CasoFormularioScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController tituloController;
  late final TextEditingController descripcionController;

  late int clienteId;
  late String servicio;
  late String estado;

  @override
  void initState() {
    super.initState();

    final item = widget.itemInicial;

    tituloController = TextEditingController(text: item?.titulo ?? '');
    descripcionController = TextEditingController(text: item?.descripcion ?? '');

    clienteId = item?.clienteId ??
        (widget.clientes.isNotEmpty ? widget.clientes.first.id : 0);

    servicio = item?.servicio ?? 'Abogados';
    estado = item?.estado ?? 'pendiente';
  }

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    if (clienteId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente inválido')),
      );
      return;
    }

    Navigator.pop(
      context,
      CasoFormResult(
        clienteId: clienteId,
        servicio: servicio,
        titulo: tituloController.text.trim(),
        descripcion: descripcionController.text.trim(),
        estado: estado,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.itemInicial != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar caso' : 'Nuevo caso'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    editando
                        ? 'Actualiza la información del caso'
                        : 'Llena los datos para crear un nuevo caso',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: clienteId > 0 ? clienteId : null,
                    decoration: _inputDecoration('Cliente'),
                    items: widget.clientes.map((cliente) {
                      return DropdownMenuItem<int>(
                        value: cliente.id,
                        child: Text('${cliente.nombre} • ${cliente.correo}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => clienteId = value);
                      }
                    },
                    validator: (value) {
                      if (value == null || value <= 0) {
                        return 'Selecciona un cliente';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: servicio,
                    decoration: _inputDecoration('Servicio'),
                    items: const [
                      DropdownMenuItem(value: 'Abogados', child: Text('Abogados')),
                      DropdownMenuItem(value: 'Ajustadores', child: Text('Ajustadores')),
                      DropdownMenuItem(
                        value: 'Peritos en criminalística',
                        child: Text('Peritos en criminalística'),
                      ),
                      DropdownMenuItem(value: 'Valuadores', child: Text('Valuadores')),
                      DropdownMenuItem(value: 'Investigadores', child: Text('Investigadores')),
                      DropdownMenuItem(value: 'Psicólogos', child: Text('Psicólogos')),
                      DropdownMenuItem(
                        value: 'Agentes inmobiliarios',
                        child: Text('Agentes inmobiliarios'),
                      ),
                      DropdownMenuItem(value: 'Contadores', child: Text('Contadores')),
                      DropdownMenuItem(
                        value: 'Agentes crediticios',
                        child: Text('Agentes crediticios'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => servicio = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: tituloController,
                    decoration: _inputDecoration('Título del caso'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Campo obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descripcionController,
                    maxLines: 4,
                    decoration: _inputDecoration('Descripción'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: estado,
                    decoration: _inputDecoration('Estado'),
                    items: const [
                      DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                      DropdownMenuItem(value: 'en proceso', child: Text('En proceso')),
                      DropdownMenuItem(value: 'finalizado', child: Text('Finalizado')),
                      DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => estado = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _guardar,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(editando ? 'Guardar cambios' : 'Crear caso'),
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
}

class CasoItem {
  final int id;
  final int clienteId;
  final String clienteNombre;
  final String titulo;
  final String descripcion;
  final String servicio;
  final String estado;

  CasoItem({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.titulo,
    required this.descripcion,
    required this.servicio,
    required this.estado,
  });

  factory CasoItem.fromJson(Map<String, dynamic> json) {
    final cliente = json['cliente'] as Map<String, dynamic>?;

    return CasoItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      clienteId: int.tryParse(cliente?['id']?.toString() ?? '0') ?? 0,
      clienteNombre: (cliente?['nombre'] ?? 'Cliente').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      servicio: (json['servicio'] ?? '').toString(),
      estado: (json['estado'] ?? '').toString(),
    );
  }
}

class ClienteItem {
  final int id;
  final String nombre;
  final String correo;

  ClienteItem({
    required this.id,
    required this.nombre,
    required this.correo,
  });

  factory ClienteItem.fromJson(Map<String, dynamic> json) {
    return ClienteItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
      correo: (json['correo'] ?? '').toString(),
    );
  }
}

class CasoFormResult {
  final int clienteId;
  final String servicio;
  final String titulo;
  final String descripcion;
  final String estado;

  CasoFormResult({
    required this.clienteId,
    required this.servicio,
    required this.titulo,
    required this.descripcion,
    required this.estado,
  });
}