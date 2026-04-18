import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BitacoraLegalScreen extends StatefulWidget {
  const BitacoraLegalScreen({super.key});

  @override
  State<BitacoraLegalScreen> createState() => _BitacoraLegalScreenState();
}

class _BitacoraLegalScreenState extends State<BitacoraLegalScreen> {
  static const String baseUrl = 'https://corporativolegaldigital.com/api';

  final List<CasoItem> _casos = [];
  final List<CasoBitacoraItem> _bitacoras = [];

  bool _cargandoCasos = true;
  bool _cargandoBitacoras = false;

  int? _profesionalId;
  String _token = '';
  int? _casoSeleccionadoId;

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
      });
      _mostrarSnack('No se encontró la sesión del profesional');
      return;
    }

    await _cargarCasos();
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
          body['mensaje']?.toString() ?? 'No se pudieron cargar los casos',
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

        if (_casos.isNotEmpty) {
          _casoSeleccionadoId ??= _casos.first.id;
        } else {
          _casoSeleccionadoId = null;
        }

        _cargandoCasos = false;
      });

      if (_casoSeleccionadoId != null) {
        await _cargarBitacoras(_casoSeleccionadoId!);
      } else {
        setState(() {
          _bitacoras.clear();
        });
      }
    } catch (e) {
      setState(() {
        _cargandoCasos = false;
      });
      _mostrarSnack('Error al cargar casos');
    }
  }

  Future<void> _cargarBitacoras(int casoId) async {
    setState(() {
      _cargandoBitacoras = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/casos/$casoId/bitacora'),
        headers: _headers(),
      );

      final body = _decodeBody(response.body);

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['mensaje']?.toString() ?? 'No se pudo cargar la bitácora',
        );
      }

      final bitacorasJson = (body['bitacoras'] as List?) ?? [];

      final bitacoras = bitacorasJson
          .whereType<Map<String, dynamic>>()
          .map(CasoBitacoraItem.fromJson)
          .toList();

      setState(() {
        _bitacoras
          ..clear()
          ..addAll(bitacoras);
        _cargandoBitacoras = false;
      });
    } catch (e) {
      setState(() {
        _cargandoBitacoras = false;
      });
      _mostrarSnack('Error al cargar bitácoras');
    }
  }

  Future<void> _abrirFormulario({CasoBitacoraItem? item}) async {
    if (_casos.isEmpty) {
      _mostrarSnack('Primero necesitas tener casos');
      return;
    }

    final resultado = await Navigator.push<BitacoraFormResult>(
      context,
      MaterialPageRoute(
        builder: (_) => BitacoraFormularioScreen(
          casos: _casos,
          casoIdInicial: item?.casoId ?? _casoSeleccionadoId ?? _casos.first.id,
          itemInicial: item,
        ),
      ),
    );

    if (resultado == null) return;

    if (item == null) {
      await _crearBitacora(resultado);
    } else {
      await _actualizarBitacora(item.id, resultado);
    }
  }

  Future<void> _crearBitacora(BitacoraFormResult form) async {
    if (_profesionalId == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/casos/${form.casoId}/bitacora'),
        headers: _headers(),
        body: jsonEncode({
          'profesional_id': _profesionalId,
          'nota': form.nota,
          'estado': form.estado,
        }),
      );

      final body = _decodeBody(response.body);

      if (response.statusCode != 201 || body['success'] != true) {
        throw Exception(
          body['mensaje']?.toString() ?? 'No se pudo crear la bitácora',
        );
      }

      _mostrarSnack('Bitácora creada correctamente');

      setState(() {
        _casoSeleccionadoId = form.casoId;
      });

      await _cargarBitacoras(form.casoId);
    } catch (e) {
      _mostrarSnack('Error al crear bitácora');
    }
  }

  Future<void> _actualizarBitacora(
    int bitacoraId,
    BitacoraFormResult form,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/casos/bitacora/$bitacoraId'),
        headers: _headers(),
        body: jsonEncode({
          'nota': form.nota,
          'estado': form.estado,
        }),
      );

      final body = _decodeBody(response.body);

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['mensaje']?.toString() ?? 'No se pudo actualizar la bitácora',
        );
      }

      _mostrarSnack('Bitácora actualizada correctamente');

      if (_casoSeleccionadoId != null) {
        await _cargarBitacoras(_casoSeleccionadoId!);
      }
    } catch (e) {
      _mostrarSnack('Error al actualizar bitácora');
    }
  }

  Future<void> _eliminarBitacora(CasoBitacoraItem item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Eliminar bitácora'),
          content: const Text('¿Seguro que quieres eliminar este registro?'),
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
        );
      },
    );

    if (confirmar != true) return;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/casos/bitacora/${item.id}'),
        headers: _headers(),
      );

      final body = _decodeBody(response.body);

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['mensaje']?.toString() ?? 'No se pudo eliminar la bitácora',
        );
      }

      _mostrarSnack('Bitácora eliminada correctamente');

      if (_casoSeleccionadoId != null) {
        await _cargarBitacoras(_casoSeleccionadoId!);
      }
    } catch (e) {
      _mostrarSnack('Error al eliminar bitácora');
    }
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

  void _mostrarSnack(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Color _colorEstado(String? estado) {
    switch ((estado ?? '').toLowerCase()) {
      case 'cerrado':
      case 'finalizado':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'activo':
      case 'seguimiento':
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _selectorCasos() {
    if (_casos.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: DropdownButtonFormField<int>(
        value: _casoSeleccionadoId,
        decoration: InputDecoration(
          labelText: 'Selecciona un caso',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: _casos.map((caso) {
          return DropdownMenuItem<int>(
            value: caso.id,
            child: Text('${caso.titulo} • ${caso.clienteNombre}'),
          );
        }).toList(),
        onChanged: (value) async {
          if (value == null) return;
          setState(() {
            _casoSeleccionadoId = value;
          });
          await _cargarBitacoras(value);
        },
      ),
    );
  }

  Widget _estadoVacioCasos() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined, size: 64),
            SizedBox(height: 12),
            Text(
              'No tienes casos registrados',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Cuando tengas casos, aquí podrás administrar su bitácora.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoVacioBitacoras() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note_outlined, size: 64),
            SizedBox(height: 12),
            Text(
              'Aún no hay movimientos registrados',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Presiona el botón + para crear una nueva bitácora.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _listaBitacoras() {
    if (_cargandoCasos || _cargandoBitacoras) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_casos.isEmpty) {
      return _estadoVacioCasos();
    }

    if (_bitacoras.isEmpty) {
      return _estadoVacioBitacoras();
    }

    final casoActual = _casos.cast<CasoItem?>().firstWhere(
          (c) => c?.id == _casoSeleccionadoId,
          orElse: () => null,
        );

    return RefreshIndicator(
      onRefresh: () async {
        if (_casoSeleccionadoId != null) {
          await _cargarBitacoras(_casoSeleccionadoId!);
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _bitacoras.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _bitacoras[index];

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                backgroundColor:
                    _colorEstado(item.estado).withOpacity(0.15),
                child: Icon(
                  Icons.edit_note_outlined,
                  color: _colorEstado(item.estado),
                ),
              ),
              title: Text(
                casoActual != null
                    ? '${casoActual.titulo} • ${casoActual.clienteNombre}'
                    : 'Caso #${item.casoId}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estado: ${item.estado ?? 'Sin estado'}'),
                    Text('Fecha: ${item.creadoEn ?? 'Sin fecha'}'),
                    const SizedBox(height: 6),
                    Text(item.nota),
                  ],
                ),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'editar') {
                    _abrirFormulario(item: item);
                  } else if (value == 'eliminar') {
                    _eliminarBitacora(item);
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
    final puedeCrear = !_cargandoCasos && _casos.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora legal'),
      ),
      body: Column(
        children: [
          _selectorCasos(),
          Expanded(child: _listaBitacoras()),
        ],
      ),
      floatingActionButton: puedeCrear
          ? FloatingActionButton(
              onPressed: () => _abrirFormulario(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class BitacoraFormularioScreen extends StatefulWidget {
  final List<CasoItem> casos;
  final int casoIdInicial;
  final CasoBitacoraItem? itemInicial;

  const BitacoraFormularioScreen({
    super.key,
    required this.casos,
    required this.casoIdInicial,
    this.itemInicial,
  });

  @override
  State<BitacoraFormularioScreen> createState() =>
      _BitacoraFormularioScreenState();
}

class _BitacoraFormularioScreenState extends State<BitacoraFormularioScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController notaController;
  late int casoIdSeleccionado;
  late String estado;

  @override
  void initState() {
    super.initState();
    notaController = TextEditingController(text: widget.itemInicial?.nota ?? '');
    casoIdSeleccionado = widget.itemInicial?.casoId ?? widget.casoIdInicial;
    estado = widget.itemInicial?.estado ?? 'activo';
  }

  @override
  void dispose() {
    notaController.dispose();
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

    Navigator.pop(
      context,
      BitacoraFormResult(
        casoId: casoIdSeleccionado,
        nota: notaController.text.trim(),
        estado: estado,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.itemInicial != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar bitácora' : 'Nueva bitácora'),
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
                        ? 'Actualiza la información del movimiento'
                        : 'Llena los datos para crear una nueva bitácora',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: casoIdSeleccionado,
                    decoration: _inputDecoration('Caso'),
                    items: widget.casos.map((caso) {
                      return DropdownMenuItem<int>(
                        value: caso.id,
                        child: Text('${caso.titulo} • ${caso.clienteNombre}'),
                      );
                    }).toList(),
                    onChanged: editando
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                casoIdSeleccionado = value;
                              });
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: estado,
                    decoration: _inputDecoration('Estado'),
                    items: const [
                      DropdownMenuItem(
                        value: 'activo',
                        child: Text('Activo'),
                      ),
                      DropdownMenuItem(
                        value: 'seguimiento',
                        child: Text('Seguimiento'),
                      ),
                      DropdownMenuItem(
                        value: 'pendiente',
                        child: Text('Pendiente'),
                      ),
                      DropdownMenuItem(
                        value: 'cerrado',
                        child: Text('Cerrado'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          estado = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notaController,
                    maxLines: 6,
                    decoration: _inputDecoration('Nota'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Campo obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _guardar,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        editando ? 'Guardar cambios' : 'Crear bitácora',
                      ),
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
  final String titulo;
  final String clienteNombre;
  final String estado;

  CasoItem({
    required this.id,
    required this.titulo,
    required this.clienteNombre,
    required this.estado,
  });

  factory CasoItem.fromJson(Map<String, dynamic> json) {
    final cliente = json['cliente'] as Map<String, dynamic>?;

    return CasoItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      titulo: (json['titulo'] ?? '').toString(),
      clienteNombre: (cliente?['nombre'] ?? 'Cliente').toString(),
      estado: (json['estado'] ?? '').toString(),
    );
  }
}

class CasoBitacoraItem {
  final int id;
  final int casoId;
  final int profesionalId;
  final String nota;
  final String? estado;
  final String? creadoEn;

  CasoBitacoraItem({
    required this.id,
    required this.casoId,
    required this.profesionalId,
    required this.nota,
    this.estado,
    this.creadoEn,
  });

  factory CasoBitacoraItem.fromJson(Map<String, dynamic> json) {
    return CasoBitacoraItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      casoId: int.tryParse(json['caso_id'].toString()) ?? 0,
      profesionalId: int.tryParse(json['profesional_id'].toString()) ?? 0,
      nota: (json['nota'] ?? '').toString(),
      estado: json['estado']?.toString(),
      creadoEn: json['creado_en']?.toString(),
    );
  }
}

class BitacoraFormResult {
  final int casoId;
  final String nota;
  final String estado;

  BitacoraFormResult({
    required this.casoId,
    required this.nota,
    required this.estado,
  });
}