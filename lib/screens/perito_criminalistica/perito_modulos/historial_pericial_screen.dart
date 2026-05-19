import 'package:flutter/material.dart';

import '../api_service_perito.dart';

class HistorialPericialScreen extends StatefulWidget {
  final int peritoId;

  const HistorialPericialScreen({
    super.key,
    required this.peritoId,
  });

  @override
  State<HistorialPericialScreen> createState() =>
      _HistorialPericialScreenState();
}

class _HistorialPericialScreenState extends State<HistorialPericialScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  void _cargarHistorial() {
    _future = ApiServicePerito.getHistorialPericial(
      peritoId: widget.peritoId,
    );
  }

  Future<void> _recargar() async {
    setState(_cargarHistorial);
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

  IconData _iconoModulo(String modulo) {
    final m = modulo.toLowerCase();

    if (m.contains('caso')) return Icons.assignment_outlined;
    if (m.contains('evidencia')) return Icons.camera_alt_outlined;
    if (m.contains('custodia')) return Icons.account_tree_outlined;
    if (m.contains('dictamen')) return Icons.description_outlined;
    if (m.contains('foto')) return Icons.photo_library_outlined;
    if (m.contains('agenda') || m.contains('inspeccion')) {
      return Icons.event_note_outlined;
    }

    return Icons.manage_history_outlined;
  }

  Color _colorAccion(String accion) {
    final a = accion.toLowerCase();

    if (a.contains('crear') || a.contains('registr')) return Colors.green;
    if (a.contains('actualiz') || a.contains('editar')) return Colors.blue;
    if (a.contains('elimin')) return Colors.redAccent;
    if (a.contains('estado')) return Colors.orange;
    if (a.contains('cerr')) return Colors.purple;

    return Colors.blueGrey;
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 80),
        Icon(
          Icons.manage_history_outlined,
          size: 64,
          color: Colors.grey,
        ),
        SizedBox(height: 14),
        Center(
          child: Text(
            'No hay historial pericial.',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 6),
        Center(
          child: Text(
            'Las acciones del perito aparecerán aquí.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _historialCard(Map<String, dynamic> item) {
    final modulo = _texto(
      item,
      [
        'modulo',
        'tabla',
        'tipo',
        'seccion',
      ],
    );

    final accion = _texto(
      item,
      [
        'accion',
        'evento',
        'titulo',
        'actividad',
      ],
    );

    final descripcion = _texto(
      item,
      [
        'descripcion',
        'detalle',
        'observaciones',
        'comentarios',
      ],
    );

    final fecha = _texto(
      item,
      [
        'fecha',
        'fecha_registro',
        'created_at',
      ],
    );

    final caso = _texto(
      item,
      [
        'caso_id',
        'id_caso',
      ],
    );

    final referencia = _texto(
      item,
      [
        'referencia_id',
        'registro_id',
        'evidencia_id',
        'dictamen_id',
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
              backgroundColor: _colorAccion(accion).withOpacity(.16),
              child: Icon(
                _iconoModulo(modulo),
                color: _colorAccion(accion),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accion,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Módulo: $modulo'),
                  Text('Caso ID: $caso'),
                  Text('Referencia ID: $referencia'),
                  Text('Fecha: $fecha'),
                  const SizedBox(height: 6),
                  Text(
                    descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
        title: const Text('Historial pericial'),
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
                    'Error al cargar historial:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            final historial = snapshot.data ?? [];

            if (historial.isEmpty) {
              return _emptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: historial.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _historialCard(historial[index]);
              },
            );
          },
        ),
      ),
    );
  }
}