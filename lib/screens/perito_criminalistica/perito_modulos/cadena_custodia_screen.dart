import 'package:flutter/material.dart';

import '../api_service_perito.dart';

class CadenaCustodiaScreen extends StatefulWidget {
  final int peritoId;
  final int? casoId;
  final int? evidenciaId;

  const CadenaCustodiaScreen({
    super.key,
    required this.peritoId,
    this.casoId,
    this.evidenciaId,
  });

  @override
  State<CadenaCustodiaScreen> createState() => _CadenaCustodiaScreenState();
}

class _CadenaCustodiaScreenState extends State<CadenaCustodiaScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  final _entregadoPorCtrl = TextEditingController();
  final _recibidoPorCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();
  final _evidenciaIdCtrl = TextEditingController();

  String _accion = 'recoleccion';

  @override
  void initState() {
    super.initState();
    _cargarCadena();
  }

  @override
  void dispose() {
    _entregadoPorCtrl.dispose();
    _recibidoPorCtrl.dispose();
    _ubicacionCtrl.dispose();
    _observacionesCtrl.dispose();
    _evidenciaIdCtrl.dispose();
    super.dispose();
  }

  void _cargarCadena() {
    _future = ApiServicePerito.getCadenaCustodia(
      peritoId: widget.peritoId,
      casoId: widget.casoId,
      evidenciaId: widget.evidenciaId,
    );
  }

  Future<void> _recargar() async {
    setState(_cargarCadena);
    await _future;
  }

  void _snack(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
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
    final value = item['id'] ?? item['movimiento_id'] ?? item['custodia_id'];

    if (value == null) return 0;

    return int.tryParse(value.toString()) ?? 0;
  }

  IconData _iconoAccion(String accion) {
    final a = accion.toLowerCase();

    if (a.contains('recoleccion') || a.contains('recolección')) {
      return Icons.add_location_alt_outlined;
    }

    if (a.contains('traslado')) {
      return Icons.local_shipping_outlined;
    }

    if (a.contains('recepcion') || a.contains('recepción')) {
      return Icons.archive_outlined;
    }

    if (a.contains('analisis') || a.contains('análisis')) {
      return Icons.science_outlined;
    }

    if (a.contains('almacenamiento')) {
      return Icons.inventory_2_outlined;
    }

    if (a.contains('entrega')) {
      return Icons.assignment_turned_in_outlined;
    }

    if (a.contains('devolucion') || a.contains('devolución')) {
      return Icons.keyboard_return_outlined;
    }

    if (a.contains('destruccion') || a.contains('destrucción')) {
      return Icons.delete_forever_outlined;
    }

    return Icons.account_tree_outlined;
  }

  Color _colorAccion(String accion) {
    final a = accion.toLowerCase();

    if (a.contains('recoleccion') || a.contains('recolección')) {
      return Colors.green;
    }

    if (a.contains('traslado')) {
      return Colors.orange;
    }

    if (a.contains('recepcion') || a.contains('recepción')) {
      return Colors.blueGrey;
    }

    if (a.contains('analisis') || a.contains('análisis')) {
      return Colors.blue;
    }

    if (a.contains('almacenamiento')) {
      return Colors.purple;
    }

    if (a.contains('entrega')) {
      return Colors.teal;
    }

    if (a.contains('devolucion') || a.contains('devolución')) {
      return Colors.indigo;
    }

    if (a.contains('destruccion') || a.contains('destrucción')) {
      return Colors.redAccent;
    }

    return Colors.blueGrey;
  }

  Widget _chipAccion(String accion) {
    return Chip(
      label: Text(
        accion,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
      backgroundColor: _colorAccion(accion),
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _crearMovimiento() async {
    if (widget.casoId == null || widget.casoId! <= 0) {
      _snack(
        'Primero abre un caso para registrar cadena de custodia.',
      );
      return;
    }

    _entregadoPorCtrl.clear();
    _recibidoPorCtrl.clear();
    _ubicacionCtrl.clear();
    _observacionesCtrl.clear();
    _evidenciaIdCtrl.clear();

    if (widget.evidenciaId != null && widget.evidenciaId! > 0) {
      _evidenciaIdCtrl.text = widget.evidenciaId.toString();
    }

    _accion = 'recoleccion';

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Movimiento de custodia'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _accion,
                      decoration: const InputDecoration(
                        labelText: 'Acción',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'recoleccion',
                          child: Text('Recolección'),
                        ),
                        DropdownMenuItem(
                          value: 'traslado',
                          child: Text('Traslado'),
                        ),
                        DropdownMenuItem(
                          value: 'recepcion',
                          child: Text('Recepción'),
                        ),
                        DropdownMenuItem(
                          value: 'analisis',
                          child: Text('Análisis'),
                        ),
                        DropdownMenuItem(
                          value: 'almacenamiento',
                          child: Text('Almacenamiento'),
                        ),
                        DropdownMenuItem(
                          value: 'entrega',
                          child: Text('Entrega'),
                        ),
                        DropdownMenuItem(
                          value: 'devolucion',
                          child: Text('Devolución'),
                        ),
                        DropdownMenuItem(
                          value: 'destruccion',
                          child: Text('Destrucción'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => _accion = value);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _evidenciaIdCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'ID de evidencia opcional',
                        hintText: 'Puedes dejarlo vacío',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _entregadoPorCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Entregado por',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _recibidoPorCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Recibido por',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ubicacionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación',
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

    final evidenciaText = _evidenciaIdCtrl.text.trim();
    final evidenciaId = evidenciaText.isEmpty
        ? null
        : int.tryParse(evidenciaText);

    if (evidenciaText.isNotEmpty && (evidenciaId == null || evidenciaId <= 0)) {
      _snack('El ID de evidencia no es válido');
      return;
    }

    final entregadoPor = _entregadoPorCtrl.text.trim();
    final recibidoPor = _recibidoPorCtrl.text.trim();
    final ubicacion = _ubicacionCtrl.text.trim();
    final observaciones = _observacionesCtrl.text.trim();

    if (entregadoPor.isEmpty && recibidoPor.isEmpty) {
      _snack('Ingresa al menos quién entrega o quién recibe');
      return;
    }

    try {
      await ApiServicePerito.crearMovimientoCustodia(
        payload: {
          'caso_id': widget.casoId,
          'perito_id': widget.peritoId,
          'profesional_id': widget.peritoId,

          if (evidenciaId != null) 'evidencia_id': evidenciaId,

          'accion': _accion,

          'entregado_por': entregadoPor,
          'origen': entregadoPor,

          'recibido_por': recibidoPor,
          'destino': recibidoPor,

          'ubicacion': ubicacion,
          'lugar': ubicacion,

          'observaciones': observaciones,
          'comentarios': observaciones,
          'detalle': observaciones,
        },
      );

      _snack('Movimiento registrado correctamente');

      await _recargar();
    } catch (e) {
      _snack('Error al registrar movimiento: $e');
    }
  }

  Future<void> _eliminarMovimiento(int movimientoId) async {
    if (movimientoId <= 0) {
      _snack('No se encontró el ID del movimiento');
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: const Text(
          '¿Seguro que deseas eliminar este movimiento de custodia?',
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
      await ApiServicePerito.eliminarMovimientoCustodia(
        movimientoId: movimientoId,
      );

      _snack('Movimiento eliminado');

      await _recargar();
    } catch (e) {
      _snack('Error al eliminar movimiento: $e');
    }
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 80),
        Icon(
          Icons.account_tree_outlined,
          size: 64,
          color: Colors.grey,
        ),
        SizedBox(height: 14),
        Center(
          child: Text(
            'No hay movimientos de custodia.',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 6),
        Center(
          child: Text(
            'Registra recolecciones, traslados, análisis o entregas de evidencia.',
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
          'Error al cargar cadena de custodia:\n$error',
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
        title: const Text('Cadena de custodia'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearMovimiento,
        icon: const Icon(Icons.add),
        label: const Text('Movimiento'),
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

            final movimientos = snapshot.data ?? [];

            if (movimientos.isEmpty) {
              return _emptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: movimientos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final mov = movimientos[index];

                final movimientoId = _obtenerId(mov);

                final accion = _texto(
                  mov,
                  [
                    'accion',
                    'tipo_movimiento',
                    'movimiento',
                  ],
                );

                final entregadoPor = _texto(
                  mov,
                  [
                    'entregado_por',
                    'origen',
                  ],
                );

                final recibidoPor = _texto(
                  mov,
                  [
                    'recibido_por',
                    'destino',
                  ],
                );

                final ubicacion = _texto(
                  mov,
                  [
                    'ubicacion',
                    'lugar',
                  ],
                );

                final fecha = _texto(
                  mov,
                  [
                    'fecha',
                    'fecha_movimiento',
                    'created_at',
                  ],
                );

                final observaciones = _texto(
                  mov,
                  [
                    'observaciones',
                    'comentarios',
                    'detalle',
                    'descripcion',
                  ],
                );

                final evidencia = _texto(
                  mov,
                  [
                    'evidencia_id',
                    'id_evidencia',
                  ],
                );

                final casoId = _texto(
                  mov,
                  [
                    'caso_id',
                    'id_caso',
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
                            _iconoAccion(accion),
                            color: gold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                accion.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _chipAccion(accion),
                              const SizedBox(height: 8),
                              Text('Caso ID: $casoId'),
                              Text('Evidencia ID: $evidencia'),
                              Text('Entregado por: $entregadoPor'),
                              Text('Recibido por: $recibidoPor'),
                              Text('Ubicación: $ubicacion'),
                              Text('Fecha: $fecha'),
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
                          tooltip: 'Opciones',
                          onSelected: (value) {
                            if (value == 'eliminar') {
                              _eliminarMovimiento(movimientoId);
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