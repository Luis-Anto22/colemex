import 'package:flutter/material.dart';

import '../api_service_perito.dart';

class DictamenesPericialesScreen extends StatefulWidget {
  final int peritoId;
  final int? casoId;

  const DictamenesPericialesScreen({
    super.key,
    required this.peritoId,
    this.casoId,
  });

  @override
  State<DictamenesPericialesScreen> createState() =>
      _DictamenesPericialesScreenState();
}

class _DictamenesPericialesScreenState
    extends State<DictamenesPericialesScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  final _tituloCtrl = TextEditingController();
  final _metodologiaCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();
  final _conclusionesCtrl = TextEditingController();
  final _archivoCtrl = TextEditingController();

  String _tipoDictamen = 'criminalistica_campo';
  String _estado = 'borrador';

  @override
  void initState() {
    super.initState();
    _cargarDictamenes();
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _metodologiaCtrl.dispose();
    _observacionesCtrl.dispose();
    _conclusionesCtrl.dispose();
    _archivoCtrl.dispose();
    super.dispose();
  }

  void _cargarDictamenes() {
    _future = ApiServicePerito.getDictamenes(
      peritoId: widget.peritoId,
      casoId: widget.casoId,
    );
  }

  Future<void> _recargar() async {
    setState(_cargarDictamenes);
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
    final value = item['id'] ?? item['dictamen_id'];
    return int.tryParse(value.toString()) ?? 0;
  }

  Color _colorEstado(String estado) {
    final e = estado.toLowerCase();

    if (e.contains('borrador')) return Colors.blueGrey;
    if (e.contains('revision') || e.contains('revisión')) return Colors.orange;
    if (e.contains('entregado')) return Colors.green;
    if (e.contains('observado')) return Colors.redAccent;
    if (e.contains('corregido')) return Colors.blue;

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

  String _labelTipo(String value) {
    switch (value) {
      case 'criminalistica_campo':
        return 'Criminalística de campo';
      case 'hechos_transito':
        return 'Hechos de tránsito';
      case 'balistica':
        return 'Balística';
      case 'dactiloscopia':
        return 'Dactiloscopía';
      case 'documentoscopia':
        return 'Documentoscopía';
      case 'grafoscopia':
        return 'Grafoscopía';
      case 'fotografia_forense':
        return 'Fotografía forense';
      case 'valuacion_danos':
        return 'Valuación de daños';
      case 'otro':
        return 'Otro';
      default:
        return value;
    }
  }

  Future<void> _crearDictamen() async {
    _tituloCtrl.clear();
    _metodologiaCtrl.clear();
    _observacionesCtrl.clear();
    _conclusionesCtrl.clear();
    _archivoCtrl.clear();

    _tipoDictamen = 'criminalistica_campo';
    _estado = 'borrador';

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Nuevo dictamen pericial'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _tipoDictamen,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de dictamen',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'criminalistica_campo',
                          child: Text('Criminalística de campo'),
                        ),
                        DropdownMenuItem(
                          value: 'hechos_transito',
                          child: Text('Hechos de tránsito'),
                        ),
                        DropdownMenuItem(
                          value: 'balistica',
                          child: Text('Balística'),
                        ),
                        DropdownMenuItem(
                          value: 'dactiloscopia',
                          child: Text('Dactiloscopía'),
                        ),
                        DropdownMenuItem(
                          value: 'documentoscopia',
                          child: Text('Documentoscopía'),
                        ),
                        DropdownMenuItem(
                          value: 'grafoscopia',
                          child: Text('Grafoscopía'),
                        ),
                        DropdownMenuItem(
                          value: 'fotografia_forense',
                          child: Text('Fotografía forense'),
                        ),
                        DropdownMenuItem(
                          value: 'valuacion_danos',
                          child: Text('Valuación de daños'),
                        ),
                        DropdownMenuItem(
                          value: 'otro',
                          child: Text('Otro'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => _tipoDictamen = value);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _estado,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'borrador',
                          child: Text('Borrador'),
                        ),
                        DropdownMenuItem(
                          value: 'en_revision',
                          child: Text('En revisión'),
                        ),
                        DropdownMenuItem(
                          value: 'entregado',
                          child: Text('Entregado'),
                        ),
                        DropdownMenuItem(
                          value: 'observado',
                          child: Text('Observado'),
                        ),
                        DropdownMenuItem(
                          value: 'corregido',
                          child: Text('Corregido'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => _estado = value);
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
                      controller: _metodologiaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Metodología',
                      ),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: _observacionesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Observaciones',
                      ),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: _conclusionesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Conclusiones',
                      ),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: _archivoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'URL del PDF / archivo',
                      ),
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
      await ApiServicePerito.crearDictamen(
        payload: {
          'perito_id': widget.peritoId,
          if (widget.casoId != null) 'caso_id': widget.casoId,
          'titulo': _tituloCtrl.text.trim(),
          'tipo_dictamen': _tipoDictamen,
          'metodologia': _metodologiaCtrl.text.trim(),
          'observaciones': _observacionesCtrl.text.trim(),
          'conclusiones': _conclusionesCtrl.text.trim(),
          'archivo_pdf': _archivoCtrl.text.trim(),
          'archivo_url': _archivoCtrl.text.trim(),
          'estado': _estado,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dictamen guardado correctamente'),
        ),
      );

      await _recargar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar dictamen: $e'),
        ),
      );
    }
  }

  Future<void> _cambiarEstado({
    required int dictamenId,
    required String estado,
  }) async {
    if (dictamenId <= 0) return;

    try {
      await ApiServicePerito.cambiarEstadoDictamen(
        dictamenId: dictamenId,
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
          Icons.description_outlined,
          size: 64,
          color: Colors.grey,
        ),
        SizedBox(height: 14),
        Center(
          child: Text(
            'No hay dictámenes registrados.',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 6),
        Center(
          child: Text(
            'Crea dictámenes técnicos, conclusiones y archivos PDF.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _dictamenCard(Map<String, dynamic> dictamen) {
    final gold = Theme.of(context).primaryColor;

    final id = _obtenerId(dictamen);

    final titulo = _texto(
      dictamen,
      [
        'titulo',
        'nombre',
        'tipo_dictamen',
      ],
      defecto: 'Dictamen #$id',
    );

    final tipo = _texto(
      dictamen,
      [
        'tipo_dictamen',
        'tipo',
      ],
    );

    final estado = _texto(
      dictamen,
      [
        'estado',
        'estatus',
      ],
      defecto: 'borrador',
    );

    final fecha = _texto(
      dictamen,
      [
        'fecha_creacion',
        'fecha_entrega',
        'created_at',
        'fecha',
      ],
    );

    final conclusiones = _texto(
      dictamen,
      [
        'conclusiones',
        'observaciones',
        'descripcion',
      ],
    );

    final archivo = _texto(
      dictamen,
      [
        'archivo_pdf',
        'archivo_url',
        'url',
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
                Icons.description_outlined,
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
                  Text('Fecha: $fecha'),
                  const SizedBox(height: 6),
                  _chipEstado(estado),
                  const SizedBox(height: 6),
                  Text(
                    conclusiones,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (archivo != '-') ...[
                    const SizedBox(height: 6),
                    Text(
                      'Archivo: $archivo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Cambiar estado',
              onSelected: (value) => _cambiarEstado(
                dictamenId: id,
                estado: value,
              ),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'borrador',
                  child: Text('Borrador'),
                ),
                PopupMenuItem(
                  value: 'en_revision',
                  child: Text('En revisión'),
                ),
                PopupMenuItem(
                  value: 'entregado',
                  child: Text('Entregado'),
                ),
                PopupMenuItem(
                  value: 'observado',
                  child: Text('Observado'),
                ),
                PopupMenuItem(
                  value: 'corregido',
                  child: Text('Corregido'),
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
        title: const Text('Dictámenes periciales'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearDictamen,
        icon: const Icon(Icons.add),
        label: const Text('Dictamen'),
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
                    'Error al cargar dictámenes:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            final dictamenes = snapshot.data ?? [];

            if (dictamenes.isEmpty) {
              return _emptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: dictamenes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _dictamenCard(dictamenes[index]);
              },
            );
          },
        ),
      ),
    );
  }
}