import 'package:flutter/material.dart';

import '../api_service_perito.dart';
import 'detalle_caso_perito_screen.dart';

class CasosAsignadosPeritoScreen extends StatefulWidget {
  final int peritoId;

  const CasosAsignadosPeritoScreen({
    super.key,
    required this.peritoId,
  });

  @override
  State<CasosAsignadosPeritoScreen> createState() =>
      _CasosAsignadosPeritoScreenState();
}

class _CasosAsignadosPeritoScreenState
    extends State<CasosAsignadosPeritoScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _cargarCasos();
  }

  void _cargarCasos() {
    _future = ApiServicePerito.getCasosAsignados(
      peritoId: widget.peritoId,
    );
  }

  Future<void> _recargar() async {
    setState(_cargarCasos);
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
    final value = item['id'] ?? item['caso_id'];
    return int.tryParse(value.toString()) ?? 0;
  }

  Color _colorEstado(String estado) {
    final e = estado.toLowerCase();

    if (e.contains('pendiente')) return Colors.orange;
    if (e.contains('revision')) return Colors.blue;
    if (e.contains('revisión')) return Colors.blue;
    if (e.contains('inspeccion')) return Colors.purple;
    if (e.contains('inspección')) return Colors.purple;
    if (e.contains('dictamen')) return Colors.teal;
    if (e.contains('cerrado')) return Colors.green;

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

  Future<void> _cambiarEstado({
    required int casoId,
    required String estado,
  }) async {
    if (casoId <= 0) return;

    try {
      await ApiServicePerito.cambiarEstadoCaso(
        casoId: casoId,
        estado: estado,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estado actualizado correctamente'),
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

  void _abrirDetalle(int casoId) {
    if (casoId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el ID del caso'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleCasoPeritoScreen(
          peritoId: widget.peritoId,
          casoId: casoId,
        ),
      ),
    ).then((_) => _recargar());
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 80),
        Icon(
          Icons.assignment_outlined,
          size: 64,
          color: Colors.grey,
        ),
        SizedBox(height: 14),
        Center(
          child: Text(
            'No hay casos asignados.',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 6),
        Center(
          child: Text(
            'Cuando se te asigne un caso pericial aparecerá aquí.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Casos asignados'),
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
                    'Error al cargar casos:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            final casos = snapshot.data ?? [];

            if (casos.isEmpty) {
              return _emptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: casos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final caso = casos[index];
                final casoId = _obtenerId(caso);

                final titulo = _texto(
                  caso,
                  [
                    'titulo',
                    'nombre_caso',
                    'tipo_caso',
                    'tipo_peritaje',
                    'asunto',
                  ],
                  defecto: 'Caso pericial #$casoId',
                );

                final cliente = _texto(
                  caso,
                  [
                    'cliente_nombre',
                    'nombre_cliente',
                    'cliente',
                    'nombre',
                  ],
                );

                final ubicacion = _texto(
                  caso,
                  [
                    'ubicacion',
                    'direccion',
                    'lugar_hechos',
                    'lugar',
                  ],
                );

                final fecha = _texto(
                  caso,
                  [
                    'fecha_asignacion',
                    'fecha_registro',
                    'created_at',
                    'fecha',
                  ],
                );

                final estado = _texto(
                  caso,
                  [
                    'estado',
                    'estado_caso',
                    'estatus',
                  ],
                  defecto: 'pendiente',
                );

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _abrirDetalle(casoId),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: gold.withOpacity(.15),
                            child: Icon(
                              Icons.science_outlined,
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
                                const SizedBox(height: 8),
                                Text('Cliente: $cliente'),
                                Text('Ubicación: $ubicacion'),
                                Text('Fecha: $fecha'),
                                const SizedBox(height: 8),
                                _chipEstado(estado),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Cambiar estado',
                            onSelected: (value) => _cambiarEstado(
                              casoId: casoId,
                              estado: value,
                            ),
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'pendiente',
                                child: Text('Pendiente'),
                              ),
                              PopupMenuItem(
                                value: 'en_revision',
                                child: Text('En revisión'),
                              ),
                              PopupMenuItem(
                                value: 'en_inspeccion',
                                child: Text('En inspección'),
                              ),
                              PopupMenuItem(
                                value: 'dictamen_en_proceso',
                                child: Text('Dictamen en proceso'),
                              ),
                              PopupMenuItem(
                                value: 'cerrado',
                                child: Text('Cerrado'),
                              ),
                            ],
                          ),
                        ],
                      ),
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