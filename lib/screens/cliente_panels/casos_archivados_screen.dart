import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services/cliente_profesionales_api.dart';

class CasosArchivadosScreen extends StatefulWidget {
  const CasosArchivadosScreen({super.key});

  @override
  State<CasosArchivadosScreen> createState() => _CasosArchivadosScreenState();
}

class _CasosArchivadosScreenState extends State<CasosArchivadosScreen> {
  final ClienteProfesionalesApi _api = ClienteProfesionalesApi();

  bool _cargando = true;
  String _error = '';
  List<Map<String, dynamic>> _casos = [];

  final Set<int> _casosSeleccionados = {};
  bool _modoSeleccion = false;

  @override
  void initState() {
    super.initState();
    _cargarArchivados();
  }

  Future<int> _obtenerClienteId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id') ?? 0;
  }

  Future<void> _cargarArchivados() async {
    setState(() {
      _cargando = true;
      _error = '';
      _casosSeleccionados.clear();
      _modoSeleccion = false;
    });

    try {
      final clienteId = await _obtenerClienteId();

      final casos = await _api.getCasosArchivados(
        clienteId: clienteId,
        limit: 50,
      );

      if (!mounted) return;

      setState(() {
        _casos = casos;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'No se pudieron cargar los casos archivados.';
        _cargando = false;
      });
    }
  }

  void _toggleSeleccion(int index) {
    setState(() {
      if (_casosSeleccionados.contains(index)) {
        _casosSeleccionados.remove(index);
      } else {
        _casosSeleccionados.add(index);
      }

      if (_casosSeleccionados.isEmpty) {
        _modoSeleccion = false;
      }
    });
  }

  Future<void> _desarchivarCaso(int index) async {
    if (index < 0 || index >= _casos.length) return;

    final clienteId = await _obtenerClienteId();
    final casoId = int.tryParse('${_casos[index]['id']}');

    if (clienteId <= 0 || casoId == null) return;

    await _api.desarchivarCaso(
      casoId: casoId,
      clienteId: clienteId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Caso desarchivado')),
    );

    await _cargarArchivados();
  }

  Future<void> _desarchivarSeleccionados() async {
    final clienteId = await _obtenerClienteId();

    if (clienteId <= 0) return;

    final indices = _casosSeleccionados.toList()
      ..sort((a, b) => b.compareTo(a));

    for (final index in indices) {
      if (index < 0 || index >= _casos.length) continue;

      final casoId = int.tryParse('${_casos[index]['id']}');

      if (casoId == null) continue;

      await _api.desarchivarCaso(
        casoId: casoId,
        clienteId: clienteId,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Casos desarchivados')),
    );

    await _cargarArchivados();
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return const Color(0xFFEA580C);
      case 'en proceso':
        return const Color(0xFF2563EB);
      case 'finalizado':
        return const Color(0xFF15803D);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _fechaCorta(String fechaRaw) {
    if (fechaRaw.isEmpty) return '';
    final value = fechaRaw.replaceFirst('T', ' ');
    if (value.length >= 16) return value.substring(0, 16);
    if (value.length >= 10) return value.substring(0, 10);
    return value;
  }

  Widget _buildTarjetaCaso(int index) {
    final caso = _casos[index];
    final seleccionado = _casosSeleccionados.contains(index);

    final estado = caso['estado']?.toString() ?? 'pendiente';
    final colorEstado = _colorEstado(estado);

    final tituloRaw = caso['titulo']?.toString().trim() ?? '';
    final titulo = tituloRaw.isEmpty ? 'Caso #${caso['id'] ?? ''}' : tituloRaw;

    final servicio = caso['servicio']?.toString().trim() ?? '';

    final fecha = _fechaCorta(
      (caso['fecha_creacion']?.toString() ?? '').trim(),
    );

    return Dismissible(
      key: ValueKey('archivado_${caso['id'] ?? index}'),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        color: Colors.green,
        child: const Icon(
          Icons.unarchive_rounded,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _desarchivarCaso(index);
        }
        return false;
      },
      child: InkWell(
        onTap: () {
          if (_modoSeleccion) {
            _toggleSeleccion(index);
          }
        },
        onLongPress: () {
          setState(() {
            _modoSeleccion = true;
            _casosSeleccionados.add(index);
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: seleccionado
                ? Colors.green.withValues(alpha: 0.12)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: seleccionado
                  ? Colors.green
                  : const Color(0xFFDDE6F2),
            ),
          ),
          child: Row(
            children: [
              if (_modoSeleccion)
                Checkbox(
                  value: seleccionado,
                  onChanged: (_) => _toggleSeleccion(index),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.archive_rounded,
                          color: Color(0xFF0B2545),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0B2545),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colorEstado.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            estado,
                            style: TextStyle(
                              color: colorEstado,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (servicio.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Servicio: $servicio'),
                      ),
                    if (fecha.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          fecha,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _error,
            style: const TextStyle(color: Color(0xFFB91C1C)),
          ),
        ],
      );
    }

    if (_casos.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'No tienes casos archivados.',
            style: TextStyle(color: Color(0xFF475569)),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _casos.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _modoSeleccion = !_modoSeleccion;
                    _casosSeleccionados.clear();
                  });
                },
                icon: Icon(
                  _modoSeleccion
                      ? Icons.close_rounded
                      : Icons.check_box_outlined,
                ),
                label: Text(_modoSeleccion ? 'Cancelar' : 'Seleccionar'),
              ),
              if (_modoSeleccion && _casosSeleccionados.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: _desarchivarSeleccionados,
                  icon: const Icon(Icons.unarchive_rounded),
                  label: const Text('Desarchivar'),
                ),
            ],
          );
        }

        return _buildTarjetaCaso(index - 1);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Casos archivados'),
        backgroundColor: const Color(0xFF0B2545),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _cargarArchivados,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarArchivados,
        child: _buildContenido(),
      ),
    );
  }
}