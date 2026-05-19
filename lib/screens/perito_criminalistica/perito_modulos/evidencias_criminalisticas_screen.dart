import 'package:flutter/material.dart';

import '../api_service_perito.dart';

class EvidenciasCriminalisticasScreen extends StatefulWidget {
  final int peritoId;
  final int? casoId;

  const EvidenciasCriminalisticasScreen({
    super.key,
    required this.peritoId,
    this.casoId,
  });

  @override
  State<EvidenciasCriminalisticasScreen> createState() =>
      _EvidenciasCriminalisticasScreenState();
}

class _EvidenciasCriminalisticasScreenState
    extends State<EvidenciasCriminalisticasScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _archivoCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();

  String _tipo = 'fotografia';
  String _estado = 'registrada';

  @override
  void initState() {
    super.initState();
    _cargarEvidencias();
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _archivoCtrl.dispose();
    _ubicacionCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  void _cargarEvidencias() {
    _future = ApiServicePerito.getEvidencias(
      peritoId: widget.peritoId,
      casoId: widget.casoId,
    );
  }

  Future<void> _recargar() async {
    setState(_cargarEvidencias);
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
    final value = item['id'] ?? item['evidencia_id'];

    if (value == null) return 0;

    return int.tryParse(value.toString()) ?? 0;
  }

  IconData _iconoTipo(String tipo) {
    final t = tipo.toLowerCase();

    if (t.contains('foto') || t.contains('imagen')) {
      return Icons.camera_alt_outlined;
    }

    if (t.contains('video')) {
      return Icons.videocam_outlined;
    }

    if (t.contains('documento') || t.contains('pdf')) {
      return Icons.description_outlined;
    }

    if (t.contains('audio')) {
      return Icons.mic_none_outlined;
    }

    if (t.contains('huella')) {
      return Icons.fingerprint;
    }

    if (t.contains('arma')) {
      return Icons.warning_amber_outlined;
    }

    if (t.contains('vehiculo') || t.contains('vehículo')) {
      return Icons.directions_car_outlined;
    }

    if (t.contains('objeto')) {
      return Icons.inventory_2_outlined;
    }

    if (t.contains('sangre') || t.contains('biologica')) {
      return Icons.science_outlined;
    }

    return Icons.science_outlined;
  }

  Color _colorEstado(String estado) {
    final e = estado.toLowerCase();

    if (e.contains('registrada')) return Colors.blueGrey;
    if (e.contains('analisis') || e.contains('análisis')) return Colors.blue;
    if (e.contains('custodia')) return Colors.purple;
    if (e.contains('validada')) return Colors.green;
    if (e.contains('descartada')) return Colors.redAccent;

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

  void _snack(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  Future<void> _crearEvidencia() async {
    if (widget.casoId == null || widget.casoId! <= 0) {
      _snack(
        'Primero abre un caso para poder registrar evidencias.',
      );
      return;
    }

    _tituloCtrl.clear();
    _descripcionCtrl.clear();
    _archivoCtrl.clear();
    _ubicacionCtrl.clear();
    _observacionesCtrl.clear();

    _tipo = 'fotografia';
    _estado = 'registrada';

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Nueva evidencia'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _tipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de evidencia',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'fotografia',
                          child: Text('Fotografía'),
                        ),
                        DropdownMenuItem(
                          value: 'video',
                          child: Text('Video'),
                        ),
                        DropdownMenuItem(
                          value: 'documento',
                          child: Text('Documento'),
                        ),
                        DropdownMenuItem(
                          value: 'audio',
                          child: Text('Audio'),
                        ),
                        DropdownMenuItem(
                          value: 'huella',
                          child: Text('Huella'),
                        ),
                        DropdownMenuItem(
                          value: 'sangre',
                          child: Text('Muestra biológica'),
                        ),
                        DropdownMenuItem(
                          value: 'arma',
                          child: Text('Arma'),
                        ),
                        DropdownMenuItem(
                          value: 'vehiculo',
                          child: Text('Vehículo'),
                        ),
                        DropdownMenuItem(
                          value: 'objeto',
                          child: Text('Objeto'),
                        ),
                        DropdownMenuItem(
                          value: 'otro',
                          child: Text('Otro'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => _tipo = value);
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
                          value: 'registrada',
                          child: Text('Registrada'),
                        ),
                        DropdownMenuItem(
                          value: 'en_analisis',
                          child: Text('En análisis'),
                        ),
                        DropdownMenuItem(
                          value: 'en_custodia',
                          child: Text('En custodia'),
                        ),
                        DropdownMenuItem(
                          value: 'validada',
                          child: Text('Validada'),
                        ),
                        DropdownMenuItem(
                          value: 'descartada',
                          child: Text('Descartada'),
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
                        hintText: 'Ej. Fotografía del lugar de los hechos',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descripcionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _archivoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'URL del archivo / imagen',
                        hintText: 'https://...',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ubicacionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación de recolección',
                      ),
                    ),
                    const SizedBox(height: 8),
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

    final titulo = _tituloCtrl.text.trim();
    final descripcion = _descripcionCtrl.text.trim();
    final archivoUrl = _archivoCtrl.text.trim();
    final ubicacion = _ubicacionCtrl.text.trim();
    final observaciones = _observacionesCtrl.text.trim();

    if (titulo.isEmpty) {
      _snack('El título es obligatorio');
      return;
    }

    if (archivoUrl.isEmpty) {
      _snack('La URL del archivo / imagen es obligatoria');
      return;
    }

    try {
      await ApiServicePerito.crearEvidencia(
        payload: {
          'caso_id': widget.casoId,
          'perito_id': widget.peritoId,
          'profesional_id': widget.peritoId,

          'tipo': _tipo,
          'tipo_evidencia': _tipo,

          'titulo': titulo,
          'descripcion': descripcion.isNotEmpty ? descripcion : titulo,
          'observaciones': observaciones,
          'detalle': observaciones,

          'archivo_url': archivoUrl,
          'imagen_url': archivoUrl,
          'url': archivoUrl,

          'ubicacion': ubicacion,
          'ubicacion_recoleccion': ubicacion,
          'lugar': ubicacion,

          'estado': _estado,
          'estado_evidencia': _estado,
          'estatus': _estado,
        },
      );

      _snack('Evidencia registrada correctamente');

      await _recargar();
    } catch (e) {
      _snack('Error al guardar evidencia: $e');
    }
  }

  Future<void> _eliminarEvidencia(int evidenciaId) async {
    if (evidenciaId <= 0) {
      _snack('No se encontró el ID de la evidencia');
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar evidencia'),
        content: const Text(
          '¿Seguro que deseas eliminar esta evidencia?',
        ),
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
      await ApiServicePerito.eliminarEvidencia(
        evidenciaId: evidenciaId,
      );

      _snack('Evidencia eliminada');

      await _recargar();
    } catch (e) {
      _snack('Error al eliminar: $e');
    }
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 80),
        Icon(
          Icons.camera_alt_outlined,
          size: 64,
          color: Colors.grey,
        ),
        SizedBox(height: 14),
        Center(
          child: Text(
            'No hay evidencias registradas.',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 6),
        Center(
          child: Text(
            'Agrega fotos, documentos, videos o indicios del caso.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _errorState(Object? error) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 80),
        const Icon(
          Icons.error_outline,
          size: 52,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 12),
        Text(
          'Error al cargar evidencias:\n$error',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _recargar,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencias criminalísticas'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearEvidencia,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
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
              return _errorState(snapshot.error);
            }

            final evidencias = snapshot.data ?? [];

            if (evidencias.isEmpty) {
              return _emptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: evidencias.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final evidencia = evidencias[index];

                final evidenciaId = _obtenerId(evidencia);

                final titulo = _texto(
                  evidencia,
                  [
                    'titulo',
                    'nombre',
                    'tipo_evidencia',
                    'tipo',
                  ],
                  defecto: 'Evidencia #$evidenciaId',
                );

                final tipo = _texto(
                  evidencia,
                  [
                    'tipo_evidencia',
                    'tipo',
                  ],
                );

                final ubicacion = _texto(
                  evidencia,
                  [
                    'ubicacion_recoleccion',
                    'ubicacion',
                    'lugar',
                  ],
                );

                final estado = _texto(
                  evidencia,
                  [
                    'estado_evidencia',
                    'estado',
                    'estatus',
                  ],
                  defecto: 'registrada',
                );

                final descripcion = _texto(
                  evidencia,
                  [
                    'descripcion',
                    'observaciones',
                    'detalle',
                  ],
                );

                final fecha = _texto(
                  evidencia,
                  [
                    'fecha_recoleccion',
                    'fecha_registro',
                    'creado_en',
                    'created_at',
                    'fecha',
                  ],
                );

                final archivoUrl = _texto(
                  evidencia,
                  [
                    'archivo_url',
                    'imagen_url',
                    'url',
                  ],
                  defecto: '',
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
                            _iconoTipo(tipo),
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
                              Text('Tipo: $tipo'),
                              Text('Ubicación: $ubicacion'),
                              Text('Fecha: $fecha'),
                              if (archivoUrl.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Archivo: $archivoUrl',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              _chipEstado(estado),
                              const SizedBox(height: 6),
                              Text(
                                descripcion,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Opciones',
                          onSelected: (value) {
                            if (value == 'eliminar') {
                              _eliminarEvidencia(evidenciaId);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'eliminar',
                              child: Text('Eliminar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}