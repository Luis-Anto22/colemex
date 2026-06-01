import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services/cliente_profesionales_api.dart';
import '../../services/api_services/api_client.dart';

class PanelInicio extends StatefulWidget {
  static const Color _primary = Color(0xFF0B2545);
  static const Color _secondary = Color(0xFF134074);

  final String nombreUsuario;
  final String? servicioSeleccionado;
  final List<String> serviciosDisponibles;
  final String especialidadBusqueda;
  final VoidCallback onAbrirServicios;
  final ValueChanged<String> onSeleccionarServicio;
  final ValueChanged<String> onBuscarEspecialidad;

  const PanelInicio({
    super.key,
    required this.nombreUsuario,
    required this.servicioSeleccionado,
    required this.serviciosDisponibles,
    required this.especialidadBusqueda,
    required this.onAbrirServicios,
    required this.onSeleccionarServicio,
    required this.onBuscarEspecialidad,
  });

  @override
  State<PanelInicio> createState() => _PanelInicioState();
}

class _PanelInicioState extends State<PanelInicio> {
  final ClienteProfesionalesApi _api = ClienteProfesionalesApi();
  final ApiClient _apiClient = ApiClient();

  final Set<int> _casosSeleccionados = {};
  bool _modoSeleccionCasos = false;

  late final TextEditingController _busquedaController;

  bool _cargandoEspecialidades = false;
  List<String> _especialidades = [];
  List<Map<String, String>> _sugerenciasBusqueda = [];

  bool _cargandoCasos = true;
  String _errorCasos = '';
  List<Map<String, dynamic>> _casos = [];

  @override
  void initState() {
    super.initState();
    _busquedaController =
        TextEditingController(text: widget.especialidadBusqueda);
    _busquedaController.addListener(_onBusquedaChanged);
    _cargarEspecialidades();
    _cargarMisCasos();
  }

  @override
  void didUpdateWidget(covariant PanelInicio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.especialidadBusqueda != oldWidget.especialidadBusqueda &&
        _busquedaController.text != widget.especialidadBusqueda) {
      _busquedaController.text = widget.especialidadBusqueda;
    }
  }

  @override
  void dispose() {
    _busquedaController.removeListener(_onBusquedaChanged);
    _busquedaController.dispose();
    super.dispose();
  }

  Future<int> _obtenerClienteId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id') ?? 0;
  }

  void _onBusquedaChanged() {
    final q = _busquedaController.text.trim().toLowerCase();

    if (q.isEmpty) {
      if (mounted && _sugerenciasBusqueda.isNotEmpty) {
        setState(() {
          _sugerenciasBusqueda = [];
        });
      }
      return;
    }

    final sugerencias = <Map<String, String>>[];
    final seen = <String>{};

    void addSugerencia({
      required String tipo,
      required String valor,
      required String icono,
    }) {
      final key = '${tipo.toLowerCase()}::${valor.toLowerCase()}';
      if (!seen.add(key)) return;

      sugerencias.add({
        'tipo': tipo,
        'valor': valor,
        'icono': icono,
      });
    }

    final serviciosMatch = widget.serviciosDisponibles
        .where((s) => s.toLowerCase().contains(q))
        .take(5);

    for (final servicio in serviciosMatch) {
      addSugerencia(
        tipo: 'servicio',
        valor: servicio,
        icono: 'miscellaneous_services_rounded',
      );
    }

    final especialidadesMatch =
        _especialidades.where((e) => e.toLowerCase().contains(q)).take(7);

    for (final especialidad in especialidadesMatch) {
      addSugerencia(
        tipo: 'especialidad',
        valor: especialidad,
        icono: 'balance_rounded',
      );
    }

    if (!mounted) return;

    setState(() {
      _sugerenciasBusqueda = sugerencias.take(8).toList();
    });
  }

  Future<void> _cargarEspecialidades() async {
    if (mounted) {
      setState(() {
        _cargandoEspecialidades = true;
      });
    }

    try {
      final items = await _api.getEspecialidades(limit: 150);

      if (!mounted) return;

      setState(() {
        _especialidades = items.toSet().toList()..sort();
        _cargandoEspecialidades = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargandoEspecialidades = false;
      });
    }
  }

  Future<void> _cargarMisCasos() async {
    if (mounted) {
      setState(() {
        _cargandoCasos = true;
        _errorCasos = '';
        _casosSeleccionados.clear();
        _modoSeleccionCasos = false;
      });
    }

    try {
      final clienteId = await _obtenerClienteId();

      if (clienteId <= 0) {
        if (!mounted) return;
        setState(() {
          _cargandoCasos = false;
          _errorCasos = 'No se pudo identificar al cliente.';
          _casos = [];
        });
        return;
      }

      final casos = await _api.getMisCasos(clienteId: clienteId, limit: 6);

      if (!mounted) return;

      setState(() {
        _casos = casos;
        _cargandoCasos = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargandoCasos = false;
        _errorCasos = 'No se pudo cargar el historial de casos.';
      });
    }
  }

  String? _servicioExacto(String q) {
    final objetivo = q.trim().toLowerCase();
    if (objetivo.isEmpty) return null;

    for (final servicio in widget.serviciosDisponibles) {
      if (servicio.trim().toLowerCase() == objetivo) {
        return servicio;
      }
    }
    return null;
  }

  void _buscar() {
    final valor = _busquedaController.text.trim();

    if (valor.isEmpty) {
      widget.onBuscarEspecialidad('');
      return;
    }

    final servicio = _servicioExacto(valor);
    if (servicio != null) {
      widget.onSeleccionarServicio(servicio);
      widget.onBuscarEspecialidad('');
      widget.onAbrirServicios();
      return;
    }

    widget.onBuscarEspecialidad(valor);
    widget.onAbrirServicios();
  }

  void _seleccionarSugerencia(Map<String, String> sugerencia) {
    final valor = sugerencia['valor']?.trim() ?? '';
    final tipo = sugerencia['tipo']?.toLowerCase().trim() ?? '';

    if (valor.isEmpty) return;

    _busquedaController.text = valor;
    _busquedaController.selection = TextSelection.fromPosition(
      TextPosition(offset: _busquedaController.text.length),
    );

    setState(() {
      _sugerenciasBusqueda = [];
    });

    if (tipo == 'servicio') {
      widget.onSeleccionarServicio(valor);
      widget.onBuscarEspecialidad('');
      widget.onAbrirServicios();
      return;
    }

    widget.onBuscarEspecialidad(valor);
    widget.onAbrirServicios();
  }

  IconData _iconoSugerencia(String icono) {
    switch (icono) {
      case 'balance_rounded':
        return Icons.balance_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
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

  Widget _buildBuscador() {
    final compact = MediaQuery.of(context).size.width < 380;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE6F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search_rounded, color: PanelInicio._primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Buscar servicios o especialidades',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: PanelInicio._primary,
                    fontSize: compact ? 14 : 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _busquedaController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _buscar(),
            decoration: InputDecoration(
              hintText: 'Ej. Abogados, Contadores, Derecho Penal...',
              prefixIcon: const Icon(Icons.manage_search_rounded),
              isDense: compact,
              suffixIcon: IconButton(
                tooltip: 'Buscar',
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: _buscar,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_cargandoEspecialidades)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Cargando especialidades...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          if (_sugerenciasBusqueda.isNotEmpty &&
              _busquedaController.text.trim().isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDE6F2)),
              ),
              child: Column(
                children: _sugerenciasBusqueda.map((sugerencia) {
                  final tipo = sugerencia['tipo']?.toLowerCase().trim() ?? '';
                  final valor = sugerencia['valor'] ?? '';
                  final icono = sugerencia['icono'] ?? '';

                  return ListTile(
                    dense: true,
                    leading: Icon(
                      _iconoSugerencia(icono),
                      color: PanelInicio._primary,
                      size: 18,
                    ),
                    title: Text(valor, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      tipo == 'servicio' ? 'Servicio' : 'Especialidad',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () => _seleccionarSugerencia(sugerencia),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _archivarCaso(int index) async {
    final caso = _casos[index];
    final casoId = int.tryParse('${caso['id']}');
    final clienteId = await _obtenerClienteId();

    if (casoId == null || clienteId <= 0) return;

    final res = await _apiClient.archivarCasoCliente(
      casoId: casoId,
      clienteId: clienteId,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _casos.removeAt(index);
        _casosSeleccionados.clear();
        _modoSeleccionCasos = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caso archivado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'No se pudo archivar')),
      );
    }
  }

  Future<void> _eliminarCaso(int index) async {
    final caso = _casos[index];
    final casoId = int.tryParse('${caso['id']}');
    final clienteId = await _obtenerClienteId();

    if (casoId == null || clienteId <= 0) return;

    final res = await _apiClient.eliminarCasoCliente(
      casoId: casoId,
      clienteId: clienteId,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _casos.removeAt(index);
        _casosSeleccionados.clear();
        _modoSeleccionCasos = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caso eliminado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'No se pudo eliminar')),
      );
    }
  }

  Future<void> _archivarSeleccionados() async {
    final clienteId = await _obtenerClienteId();
    if (clienteId <= 0) return;

    final indices = _casosSeleccionados.toList()
      ..sort((a, b) => b.compareTo(a));

    for (final index in indices) {
      if (index < 0 || index >= _casos.length) continue;

      final casoId = int.tryParse('${_casos[index]['id']}');
      if (casoId == null) continue;

      await _apiClient.archivarCasoCliente(
        casoId: casoId,
        clienteId: clienteId,
      );
    }

    if (!mounted) return;

    setState(() {
      for (final index in indices) {
        if (index >= 0 && index < _casos.length) {
          _casos.removeAt(index);
        }
      }
      _casosSeleccionados.clear();
      _modoSeleccionCasos = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Casos archivados')),
    );
  }

  Future<void> _eliminarSeleccionados() async {
    final clienteId = await _obtenerClienteId();
    if (clienteId <= 0) return;

    final indices = _casosSeleccionados.toList()
      ..sort((a, b) => b.compareTo(a));

    for (final index in indices) {
      if (index < 0 || index >= _casos.length) continue;

      final casoId = int.tryParse('${_casos[index]['id']}');
      if (casoId == null) continue;

      await _apiClient.eliminarCasoCliente(
        casoId: casoId,
        clienteId: clienteId,
      );
    }

    if (!mounted) return;

    setState(() {
      for (final index in indices) {
        if (index >= 0 && index < _casos.length) {
          _casos.removeAt(index);
        }
      }
      _casosSeleccionados.clear();
      _modoSeleccionCasos = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Casos eliminados')),
    );
  }

  void _toggleSeleccionCaso(int index) {
    setState(() {
      if (_casosSeleccionados.contains(index)) {
        _casosSeleccionados.remove(index);
      } else {
        _casosSeleccionados.add(index);
      }

      if (_casosSeleccionados.isEmpty) {
        _modoSeleccionCasos = false;
      }
    });
  }

  Widget _buildMisCasos() {
    final compact = MediaQuery.of(context).size.width < 380;

    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE6F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_copy_rounded, color: PanelInicio._primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mis casos',
                  style: TextStyle(
                    fontSize: compact ? 16 : 17,
                    fontWeight: FontWeight.w700,
                    color: PanelInicio._primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: _cargandoCasos ? null : _cargarMisCasos,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Actualizar',
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Historial de tus casos recientes.',
            style: TextStyle(color: Color(0xFF475569)),
          ),
          const SizedBox(height: 12),
          if (_casos.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _modoSeleccionCasos = !_modoSeleccionCasos;
                      _casosSeleccionados.clear();
                    });
                  },
                  icon: Icon(
                    _modoSeleccionCasos
                        ? Icons.close_rounded
                        : Icons.check_box_outlined,
                  ),
                  label: Text(
                    _modoSeleccionCasos ? 'Cancelar' : 'Seleccionar',
                  ),
                ),
                if (_modoSeleccionCasos && _casosSeleccionados.isNotEmpty) ...[
                  ElevatedButton.icon(
                    onPressed: _archivarSeleccionados,
                    icon: const Icon(Icons.archive_rounded),
                    label: const Text('Archivar'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _eliminarSeleccionados,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete_rounded),
                    label: const Text('Eliminar'),
                  ),
                ],
              ],
            ),
          if (_casos.isNotEmpty) const SizedBox(height: 12),
          if (_cargandoCasos)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorCasos.isNotEmpty)
            Text(
              _errorCasos,
              style: const TextStyle(color: Color(0xFFB91C1C)),
            )
          else if (_casos.isEmpty)
            const Text(
              'No tienes casos registrados.',
              style: TextStyle(color: Color(0xFF475569)),
            )
          else
            ListView.separated(
              itemCount: _casos.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final caso = _casos[index];
                final estado = caso['estado']?.toString() ?? 'pendiente';
                final colorEstado = _colorEstado(estado);
                final tituloRaw = caso['titulo']?.toString().trim() ?? '';
                final titulo = tituloRaw.isEmpty
                    ? 'Caso #${caso['id'] ?? ''}'
                    : tituloRaw;
                final servicio = caso['servicio']?.toString().trim() ?? '';
                final profesional =
                    caso['profesional_nombre']?.toString().trim() ?? '';
                final fechaRaw =
                    caso['fecha']?.toString() ??
                    caso['fecha_creacion']?.toString() ??
                    '';
                final fecha = _fechaCorta(fechaRaw.trim());
                final seleccionado = _casosSeleccionados.contains(index);

                return Dismissible(
                  key: ValueKey(caso['id'] ?? index),
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 24),
                    color: Colors.blue,
                    child: const Icon(Icons.archive, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      await _archivarCaso(index);
                    } else if (direction == DismissDirection.endToStart) {
                      await _eliminarCaso(index);
                    }
                    return false;
                  },
                  child: InkWell(
                    onTap: () {
                      if (_modoSeleccionCasos) {
                        _toggleSeleccionCaso(index);
                      }
                    },
                    onLongPress: () {
                      setState(() {
                        _modoSeleccionCasos = true;
                        _casosSeleccionados.add(index);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: seleccionado
                            ? Colors.blue.withValues(alpha: 0.12)
                            : const Color(0xFFF8FBFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDCE6F4)),
                      ),
                      child: Row(
                        children: [
                          if (_modoSeleccionCasos)
                            Checkbox(
                              value: seleccionado,
                              onChanged: (_) => _toggleSeleccionCaso(index),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        titulo,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: PanelInicio._primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            colorEstado.withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(999),
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
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      'Servicio: $servicio',
                                      style: const TextStyle(
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                if (profesional.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      'Profesional: $profesional',
                                      style: const TextStyle(
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                if (fecha.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.schedule_rounded,
                                          size: 16,
                                          color: Color(0xFF64748B),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          fecha,
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
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
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 380;
    final outerPadding = compact ? 12.0 : 16.0;

    return ListView(
      padding: EdgeInsets.all(outerPadding),
      children: [
        Container(
          padding: EdgeInsets.all(compact ? 14 : 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [PanelInicio._primary, PanelInicio._secondary],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: PanelInicio._primary.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bienvenido ${widget.nombreUsuario}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 19 : 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 8 : 10),
              const Text(
                'Bienvenido, elige alguno de los servicios ofrecidos por la aplicación.',
                style: TextStyle(
                  color: Color(0xFFE7EEF7),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 12 : 16),
        _buildBuscador(),
        SizedBox(height: compact ? 12 : 16),
        _buildMisCasos(),
      ],
    );
  }
}