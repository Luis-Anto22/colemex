import 'package:flutter/material.dart';

import '../api_service_perito.dart';

class AgendaInspeccionesScreen extends StatefulWidget {
  final int peritoId;

  const AgendaInspeccionesScreen({
    super.key,
    required this.peritoId,
  });

  @override
  State<AgendaInspeccionesScreen> createState() =>
      _AgendaInspeccionesScreenState();
}

class _AgendaInspeccionesScreenState extends State<AgendaInspeccionesScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  final _tituloCtrl = TextEditingController();
  final _lugarCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _horaCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();

  String _tipoInspeccion = 'inspeccion_lugar_hechos';

  @override
  void initState() {
    super.initState();
    _cargarAgenda();
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _lugarCtrl.dispose();
    _fechaCtrl.dispose();
    _horaCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  void _cargarAgenda() {
    _future = ApiServicePerito.getAgendaInspecciones(
      peritoId: widget.peritoId,
    );
  }

  Future<void> _recargar() async {
    setState(_cargarAgenda);
    await _future;
  }

  String _texto(
    Map<String, dynamic> item,
    List<String> keys, {
    String defecto = '-',
  }) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return defecto;
  }

  int _obtenerId(Map<String, dynamic> item) {
    final value = item['id'] ?? item['inspeccion_id'];
    return int.tryParse(value.toString()) ?? 0;
  }

  String _labelTipo(String value) {
    switch (value) {
      case 'inspeccion_lugar_hechos':
        return 'Inspección de lugar de hechos';
      case 'toma_fotografica':
        return 'Toma fotográfica';
      case 'levantamiento_indicios':
        return 'Levantamiento de indicios';
      case 'entrevista_tecnica':
        return 'Entrevista técnica';
      case 'revision_documental':
        return 'Revisión documental';
      default:
        return value;
    }
  }

  Color _colorEstado(String estado) {
    final e = estado.toLowerCase();

    if (e.contains('programada')) return Colors.blueGrey;
    if (e.contains('confirmada')) return Colors.blue;
    if (e.contains('realizada')) return Colors.green;
    if (e.contains('cancelada')) return Colors.redAccent;
    if (e.contains('reprogramada')) return Colors.orange;

    return Colors.blueGrey;
  }

  Widget _chipEstado(String estado) {
    return Chip(
      label: Text(
        estado,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
      backgroundColor: _colorEstado(estado),
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _crearInspeccion() async {
    _tituloCtrl.clear();
    _lugarCtrl.clear();
    _fechaCtrl.clear();
    _horaCtrl.clear();
    _observacionesCtrl.clear();

    _tipoInspeccion = 'inspeccion_lugar_hechos';

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Nueva inspección'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _tipoInspeccion,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de inspección',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'inspeccion_lugar_hechos',
                          child: Text('Inspección de lugar de hechos'),
                        ),
                        DropdownMenuItem(
                          value: 'toma_fotografica',
                          child: Text('Toma fotográfica'),
                        ),
                        DropdownMenuItem(
                          value: 'levantamiento_indicios',
                          child: Text('Levantamiento de indicios'),
                        ),
                        DropdownMenuItem(
                          value: 'entrevista_tecnica',
                          child: Text('Entrevista técnica'),
                        ),
                        DropdownMenuItem(
                          value: 'revision_documental',
                          child: Text('Revisión documental'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => _tipoInspeccion = value);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tituloCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                      ),
                    ),
                    TextField(
                      controller: _lugarCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Lugar / ubicación',
                      ),
                    ),
                    TextField(
                      controller: _fechaCtrl,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        labelText: 'Fecha YYYY-MM-DD',
                      ),
                    ),
                    TextField(
                      controller: _horaCtrl,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        labelText: 'Hora HH:mm',
                      ),
                    ),
                    TextField(
                      controller: _observacionesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Observaciones',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (guardar != true) return;

    if (_tituloCtrl.text.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El título es obligatorio'),
        ),
      );
      return;
    }

    try {
      await ApiServicePerito.crearInspeccion(
        payload: {
          'perito_id': widget.peritoId,
          'titulo': _tituloCtrl.text.trim(),
          'tipo_inspeccion': _tipoInspeccion,
          'lugar': _lugarCtrl.text.trim(),
          'ubicacion': _lugarCtrl.text.trim(),
          'fecha': _fechaCtrl.text.trim(),
          'hora': _horaCtrl.text.trim(),
          'observaciones': _observacionesCtrl.text.trim(),
          'estado': 'programada',
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inspección registrada correctamente'),
        ),
      );

      await _recargar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar inspección: $e'),
        ),
      );
    }
  }

  Future<void> _cambiarEstado({
    required int inspeccionId,
    required String estado,
  }) async {
    if (inspeccionId <= 0) return;

    try {
      await ApiServicePerito.cambiarEstadoInspeccion(
        inspeccionId: inspeccionId,
        estado: estado,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estado actualizado'),
        ),
      );

      await _recargar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar estado: $e'),
        ),
      );
    }
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 80),
        Icon(
          Icons.event_note_outlined,
          size: 64,
          color: Colors.grey,
        ),
        SizedBox(height: 14),
        Center(
          child: Text(
            'No hay inspecciones programadas.',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 6),
        Center(
          child: Text(
            'Programa inspecciones, visitas al lugar de hechos o revisiones técnicas.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _inspeccionCard(Map<String, dynamic> item) {
    final gold = Theme.of(context).primaryColor;

    final id = _obtenerId(item);

    final titulo = _texto(
      item,
      [
        'titulo',
        'nombre',
        'tipo_inspeccion',
      ],
      defecto: 'Inspección #$id',
    );

    final tipo = _texto(
      item,
      [
        'tipo_inspeccion',
        'tipo',
      ],
    );

    final lugar = _texto(
      item,
      [
        'lugar',
        'ubicacion',
        'direccion',
      ],
    );

    final fecha = _texto(
      item,
      [
        'fecha',
        'fecha_inspeccion',
        'created_at',
      ],
    );

    final hora = _texto(
      item,
      [
        'hora',
        'hora_inspeccion',
      ],
    );

    final estado = _texto(
      item,
      [
        'estado',
        'estatus',
      ],
      defecto: 'programada',
    );

    final observaciones = _texto(
      item,
      [
        'observaciones',
        'descripcion',
        'detalle',
      ],
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: gold.withOpacity(.15),
              child: Icon(
                Icons.event_note_outlined,
                color: gold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Tipo: ${_labelTipo(tipo)}'),
                  Text('Lugar: $lugar'),
                  Text('Fecha: $fecha'),
                  Text('Hora: $hora'),
                  const SizedBox(height: 6),
                  _chipEstado(estado),
                  const SizedBox(height: 6),
                  Text(
                    observaciones,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Cambiar estado',
              onSelected: (value) => _cambiarEstado(
                inspeccionId: id,
                estado: value,
              ),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'programada',
                  child: Text('Programada'),
                ),
                PopupMenuItem(
                  value: 'confirmada',
                  child: Text('Confirmada'),
                ),
                PopupMenuItem(
                  value: 'realizada',
                  child: Text('Realizada'),
                ),
                PopupMenuItem(
                  value: 'cancelada',
                  child: Text('Cancelada'),
                ),
                PopupMenuItem(
                  value: 'reprogramada',
                  child: Text('Reprogramada'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de inspecciones'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearInspeccion,
        icon: const Icon(Icons.add),
        label: const Text('Inspección'),
      ),
      body: RefreshIndicator(
        onRefresh: _recargar,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 52,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Error al cargar agenda:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            final agenda = snapshot.data ?? [];

            if (agenda.isEmpty) {
              return _emptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: agenda.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _inspeccionCard(agenda[index]);
              },
            );
          },
        ),
      ),
    );
  }
}