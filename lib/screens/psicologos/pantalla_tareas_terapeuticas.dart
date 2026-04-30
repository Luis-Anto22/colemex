import 'package:flutter/material.dart';

import 'package:advocatus/services/api_services/api_client.dart';
import 'package:advocatus/services/api_services/common_api.dart';

class PantallaTareasTerapeuticas extends StatefulWidget {
  final int psicologoId;

  const PantallaTareasTerapeuticas({
    super.key,
    required this.psicologoId,
  });

  @override
  State<PantallaTareasTerapeuticas> createState() =>
      _PantallaTareasTerapeuticasState();
}

class _PantallaTareasTerapeuticasState
    extends State<PantallaTareasTerapeuticas> {
  final CommonApi api = CommonApi(ApiClient());

  bool cargando = true;
  String mensaje = '';

  List<dynamic> _tareas = [];
  List<dynamic> _pacientesRelacionados = [];
  List<dynamic> _expedientes = [];

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    if (widget.psicologoId <= 0) {
      setState(() {
        cargando = false;
        mensaje = 'ID de psicólogo no válido';
      });
      return;
    }

    setState(() {
      cargando = true;
      mensaje = '';
    });

    try {
      final tareas = await api.getTareasPsicologo(widget.psicologoId);
      final pacientes = await api.getPacientesPsicologo(widget.psicologoId);
      final expedientes = await api.getExpedientesPsicologo(widget.psicologoId);

      if (!mounted) return;

      setState(() {
        _tareas = tareas;
        _pacientesRelacionados = pacientes;
        _expedientes = expedientes;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
        mensaje = 'Error: $e';
      });
    }
  }

  String _saludoPorHora() {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) return 'Buenos días';
    if (hora >= 12 && hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en progreso':
        return Colors.blue;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  String _texto(dynamic value, {String fallback = 'Sin información.'}) {
    final txt = (value ?? '').toString().trim();
    return txt.isEmpty ? fallback : txt;
  }

  Map<String, dynamic> _clienteDeRelacion(Map<String, dynamic> item) {
    final cliente = item['cliente'];
    if (cliente is Map<String, dynamic>) return cliente;
    return <String, dynamic>{};
  }

  Map<String, dynamic> _clienteDeTarea(Map<String, dynamic> item) {
    final cliente = item['cliente'];
    if (cliente is Map<String, dynamic>) return cliente;
    return <String, dynamic>{};
  }

  String _nombrePacienteRelacion(Map<String, dynamic> item) {
    final cliente = _clienteDeRelacion(item);
    return (cliente['nombre'] ?? 'Paciente').toString();
  }

  String _nombrePacienteTarea(Map<String, dynamic> item) {
    final cliente = _clienteDeTarea(item);
    return (cliente['nombre'] ?? 'Paciente').toString();
  }

  String _fechaAsignacion(Map<String, dynamic> item) {
    final value = (item['fecha_sesion'] ?? item['fechaAsignacion'] ?? '')
        .toString()
        .trim();
    if (value.isEmpty) return 'Sin registro';
    return value;
  }

  List<Map<String, dynamic>> _expedientesDeCliente(int clienteId) {
    return _expedientes
        .map((e) => Map<String, dynamic>.from(e))
        .where((e) => _toInt(e['cliente_id']) == clienteId)
        .toList();
  }

  Map<String, String> _parseObservacionesTarea(String? texto) {
    final source = (texto ?? '').trim();
    if (source.isEmpty) {
      return {
        'titulo': '',
        'categoria': '',
        'fechaEntrega': '',
        'descripcion': '',
        'observaciones': '',
      };
    }

    String extraer(String inicio, List<String> siguientes) {
      final start = source.indexOf(inicio);
      if (start == -1) return '';
      final contentStart = start + inicio.length;

      int? nearestEnd;
      for (final s in siguientes) {
        final idx = source.indexOf(s, contentStart);
        if (idx != -1) {
          if (nearestEnd == null || idx < nearestEnd) {
            nearestEnd = idx;
          }
        }
      }

      final raw = nearestEnd == null
          ? source.substring(contentStart)
          : source.substring(contentStart, nearestEnd);

      return raw.trim();
    }

    return {
      'titulo': extraer(
        'Título:',
        ['Categoría:', 'Fecha entrega:', 'Descripción:', 'Observaciones:'],
      ),
      'categoria': extraer(
        'Categoría:',
        ['Fecha entrega:', 'Descripción:', 'Observaciones:'],
      ),
      'fechaEntrega': extraer(
        'Fecha entrega:',
        ['Descripción:', 'Observaciones:'],
      ),
      'descripcion': extraer(
        'Descripción:',
        ['Observaciones:'],
      ),
      'observaciones': extraer(
        'Observaciones:',
        [],
      ),
    };
  }

  String _buildObservacionesTarea({
    required String titulo,
    required String categoria,
    required String fechaEntrega,
    required String descripcion,
    required String observaciones,
  }) {
    final buffer = StringBuffer();

    if (titulo.trim().isNotEmpty) {
      buffer.writeln('Título:');
      buffer.writeln(titulo.trim());
      buffer.writeln();
    }

    if (categoria.trim().isNotEmpty) {
      buffer.writeln('Categoría:');
      buffer.writeln(categoria.trim());
      buffer.writeln();
    }

    if (fechaEntrega.trim().isNotEmpty) {
      buffer.writeln('Fecha entrega:');
      buffer.writeln(fechaEntrega.trim());
      buffer.writeln();
    }

    if (descripcion.trim().isNotEmpty) {
      buffer.writeln('Descripción:');
      buffer.writeln(descripcion.trim());
      buffer.writeln();
    }

    if (observaciones.trim().isNotEmpty) {
      buffer.writeln('Observaciones:');
      buffer.writeln(observaciones.trim());
    }

    return buffer.toString().trim();
  }

  Future<void> _crearTarea() async {
    if (_pacientesRelacionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero debes tener al menos un paciente vinculado'),
        ),
      );
      return;
    }

    int? relacionSeleccionadaId;
    int? clienteIdSeleccionado;
    int? expedienteIdSeleccionado;

    final tituloCtrl = TextEditingController();
    final descripcionCtrl = TextEditingController();
    final objetivoCtrl = TextEditingController();
    final observacionesCtrl = TextEditingController();

    String categoria = 'Cognitiva';
    String estado = 'pendiente';
    DateTime fechaAsignacion = DateTime.now();
    DateTime fechaEntrega = DateTime.now().add(const Duration(days: 7));

    List<Map<String, dynamic>> expedientesFiltrados = [];

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> seleccionarFechaAsignacion() async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: fechaAsignacion,
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
            );

            if (pickedDate == null) return;

            final pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(fechaAsignacion),
            );

            if (pickedTime == null) return;

            setModalState(() {
              fechaAsignacion = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
            });
          }

          Future<void> seleccionarFechaEntrega() async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: fechaEntrega,
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
            );

            if (pickedDate == null) return;

            final pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(fechaEntrega),
            );

            if (pickedTime == null) return;

            setModalState(() {
              fechaEntrega = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
            });
          }

          return AlertDialog(
            title: const Text('Nueva tarea terapéutica'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: relacionSeleccionadaId,
                    decoration: const InputDecoration(
                      labelText: 'Paciente',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _pacientesRelacionados.map<DropdownMenuItem<int>>((p) {
                      final item = Map<String, dynamic>.from(p);
                      final relacionId = _toInt(item['id']) ?? 0;
                      final clienteId = _toInt(item['cliente_id']) ?? 0;
                      final nombre = _nombrePacienteRelacion(item);
                      final correo = _clienteDeRelacion(item)['correo'] ?? '';

                      return DropdownMenuItem<int>(
                        value: relacionId,
                        onTap: () {
                          clienteIdSeleccionado = clienteId;
                        },
                        child: Text(
                          correo.toString().trim().isEmpty
                              ? nombre
                              : '$nombre • $correo',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        relacionSeleccionadaId = value;
                        expedienteIdSeleccionado = null;

                        final item = _pacientesRelacionados.cast<dynamic>().firstWhere(
                              (e) => _toInt((e as Map<String, dynamic>)['id']) == value,
                              orElse: () => <String, dynamic>{},
                            );

                        if (item is Map<String, dynamic>) {
                          clienteIdSeleccionado = _toInt(item['cliente_id']);
                          expedientesFiltrados = clienteIdSeleccionado == null
                              ? []
                              : _expedientesDeCliente(clienteIdSeleccionado!);
                        } else {
                          clienteIdSeleccionado = null;
                          expedientesFiltrados = [];
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: expedienteIdSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Expediente clínico',
                      border: OutlineInputBorder(),
                    ),
                    items: expedientesFiltrados.map<DropdownMenuItem<int>>((e) {
                      final expedienteId = _toInt(e['id']) ?? 0;
                      final diagnostico = _texto(
                        e['diagnostico_inicial'],
                        fallback: 'Sin diagnóstico',
                      );

                      return DropdownMenuItem<int>(
                        value: expedienteId,
                        child: Text(
                          'Expediente #$expedienteId • $diagnostico',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        expedienteIdSeleccionado = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tituloCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Título de la tarea',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: categoria,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Cognitiva',
                        child: Text('Cognitiva'),
                      ),
                      DropdownMenuItem(
                        value: 'Conductual',
                        child: Text('Conductual'),
                      ),
                      DropdownMenuItem(
                        value: 'Emocional',
                        child: Text('Emocional'),
                      ),
                      DropdownMenuItem(
                        value: 'Relajación',
                        child: Text('Relajación'),
                      ),
                      DropdownMenuItem(
                        value: 'Mindfulness',
                        child: Text('Mindfulness'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        categoria = value ?? 'Cognitiva';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: seleccionarFechaAsignacion,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      'Asignación: '
                      '${fechaAsignacion.year}-${fechaAsignacion.month.toString().padLeft(2, '0')}-${fechaAsignacion.day.toString().padLeft(2, '0')} '
                      '${fechaAsignacion.hour.toString().padLeft(2, '0')}:${fechaAsignacion.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: seleccionarFechaEntrega,
                    icon: const Icon(Icons.event_available),
                    label: Text(
                      'Entrega: '
                      '${fechaEntrega.year}-${fechaEntrega.month.toString().padLeft(2, '0')}-${fechaEntrega.day.toString().padLeft(2, '0')} '
                      '${fechaEntrega.hour.toString().padLeft(2, '0')}:${fechaEntrega.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: estado,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'pendiente',
                        child: Text('Pendiente'),
                      ),
                      DropdownMenuItem(
                        value: 'en progreso',
                        child: Text('En progreso'),
                      ),
                      DropdownMenuItem(
                        value: 'completada',
                        child: Text('Completada'),
                      ),
                      DropdownMenuItem(
                        value: 'cancelada',
                        child: Text('Cancelada'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        estado = value ?? 'pendiente';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descripcionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: objetivoCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Objetivo terapéutico',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: observacionesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                      border: OutlineInputBorder(),
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
      ),
    );

    if (ok != true) {
      tituloCtrl.dispose();
      descripcionCtrl.dispose();
      objetivoCtrl.dispose();
      observacionesCtrl.dispose();
      return;
    }

    if (clienteIdSeleccionado == null ||
        expedienteIdSeleccionado == null ||
        tituloCtrl.text.trim().isEmpty) {
      tituloCtrl.dispose();
      descripcionCtrl.dispose();
      objetivoCtrl.dispose();
      observacionesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona paciente, expediente y título'),
        ),
      );
      return;
    }

    try {
      final fechaEntregaTxt =
          '${fechaEntrega.year}-${fechaEntrega.month.toString().padLeft(2, '0')}-${fechaEntrega.day.toString().padLeft(2, '0')} '
          '${fechaEntrega.hour.toString().padLeft(2, '0')}:${fechaEntrega.minute.toString().padLeft(2, '0')}:00';

      final observacionesFormateadas = _buildObservacionesTarea(
        titulo: tituloCtrl.text.trim(),
        categoria: categoria,
        fechaEntrega: fechaEntregaTxt,
        descripcion: descripcionCtrl.text.trim(),
        observaciones: observacionesCtrl.text.trim(),
      );

      await api.crearSesionPsicologo(
        psicologoId: widget.psicologoId,
        clienteId: clienteIdSeleccionado!,
        expedienteId: expedienteIdSeleccionado!,
        profesionalClienteId: relacionSeleccionadaId,
        fechaSesion:
            '${fechaAsignacion.year}-${fechaAsignacion.month.toString().padLeft(2, '0')}-${fechaAsignacion.day.toString().padLeft(2, '0')} '
            '${fechaAsignacion.hour.toString().padLeft(2, '0')}:${fechaAsignacion.minute.toString().padLeft(2, '0')}:00',
        tipoSesion: 'seguimiento',
        tareasTerapeuticas:
            objetivoCtrl.text.trim().isEmpty ? null : objetivoCtrl.text.trim(),
        observaciones:
            observacionesFormateadas.isEmpty ? null : observacionesFormateadas,
        estado: estado == 'en progreso' ? 'registrada' : estado,
      );

      tituloCtrl.dispose();
      descripcionCtrl.dispose();
      objetivoCtrl.dispose();
      observacionesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea terapéutica registrada')),
      );

      await _cargarTodo();
    } catch (e) {
      tituloCtrl.dispose();
      descripcionCtrl.dispose();
      objetivoCtrl.dispose();
      observacionesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _mostrarDetalle(Map<String, dynamic> tarea) {
    final extra = _parseObservacionesTarea(
      (tarea['observaciones'] ?? '').toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B222C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _texto(extra['titulo'], fallback: 'Tarea terapéutica'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _datoDetalle('Paciente', _nombrePacienteTarea(tarea)),
                  _datoDetalle(
                    'Categoría',
                    _texto(extra['categoria'], fallback: '—'),
                  ),
                  _datoDetalle(
                    'Estado',
                    _texto(tarea['estado'], fallback: '—'),
                  ),
                  _datoDetalle(
                    'Asignación',
                    _fechaAsignacion(tarea),
                  ),
                  _datoDetalle(
                    'Entrega',
                    _texto(extra['fechaEntrega'], fallback: '—'),
                  ),
                  const SizedBox(height: 12),
                  _bloqueTexto(
                    titulo: 'Descripción',
                    contenido: _texto(extra['descripcion']),
                  ),
                  _bloqueTexto(
                    titulo: 'Objetivo terapéutico',
                    contenido: _texto(tarea['tareas_terapeuticas']),
                  ),
                  _bloqueTexto(
                    titulo: 'Observaciones',
                    contenido: _texto(extra['observaciones']),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bloqueTexto({
    required String titulo,
    required String contenido,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: Text(
              contenido.isNotEmpty ? contenido : 'Sin información.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datoDetalle(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$titulo:',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.70),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumenCard({
    required IconData icon,
    required String titulo,
    required String valor,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.primaryColor;
    final pendientes = _tareas
        .where(
          (t) => (t['estado'] ?? '').toString().toLowerCase() == 'pendiente',
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas terapéuticas'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _cargarTodo,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Nueva tarea',
            onPressed: _crearTarea,
            icon: const Icon(Icons.playlist_add_check_circle_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/iconos/mazo-libro.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.62),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xFF12161C).withValues(alpha: 0.84),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withValues(alpha: 0.06),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: accent.withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: accent.withValues(alpha: 0.20),
                                  ),
                                ),
                                child: Icon(
                                  Icons.assignment_outlined,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_saludoPorHora()}, tareas terapéuticas',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ejercicios y actividades de apoyo para el proceso terapéutico.',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.72),
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _resumenCard(
                                icon: Icons.assignment_outlined,
                                titulo: 'Total',
                                valor: '${_tareas.length}',
                                accent: accent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _resumenCard(
                                icon: Icons.schedule_outlined,
                                titulo: 'Pendientes',
                                valor: '$pendientes',
                                accent: accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: _crearTarea,
                          icon: const Icon(Icons.add),
                          label: const Text('Crear tarea terapéutica'),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Tareas registradas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (cargando)
                          const Padding(
                            padding: EdgeInsets.all(18),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_tareas.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white.withValues(alpha: 0.05),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                            ),
                            child: Text(
                              mensaje.isEmpty
                                  ? 'No hay tareas terapéuticas registradas todavía.'
                                  : mensaje,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.80),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ..._tareas.map((item) {
                            final tarea = Map<String, dynamic>.from(item);
                            final extra = _parseObservacionesTarea(
                              (tarea['observaciones'] ?? '').toString(),
                            );
                            final estado =
                                (tarea['estado'] ?? 'Sin estado').toString();
                            final colorEstado = _colorEstado(estado);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _mostrarDetalle(tarea),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white.withValues(alpha: 0.05),
                                    border: Border.all(
                                      color: accent.withValues(alpha: 0.14),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: accent.withValues(alpha: 0.10),
                                          border: Border.all(
                                            color: accent.withValues(alpha: 0.18),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.assignment_outlined,
                                          color: accent,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _texto(
                                                extra['titulo'],
                                                fallback: 'Tarea terapéutica',
                                              ),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_nombrePacienteTarea(tarea)} • ${_texto(extra['categoria'], fallback: 'Categoría')}',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.72,
                                                ),
                                                fontSize: 12.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Entrega: ${_texto(extra['fechaEntrega'], fallback: 'Sin fecha')}',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.82,
                                                ),
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          color: colorEstado.withValues(alpha: 0.14),
                                        ),
                                        child: Text(
                                          estado,
                                          style: TextStyle(
                                            color: colorEstado,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}