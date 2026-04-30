import 'package:flutter/material.dart';

import 'package:advocatus/services/api_services/api_client.dart';
import 'package:advocatus/services/api_services/common_api.dart';

class PantallaEvaluaciones extends StatefulWidget {
  final int psicologoId;

  const PantallaEvaluaciones({
    super.key,
    required this.psicologoId,
  });

  @override
  State<PantallaEvaluaciones> createState() => _PantallaEvaluacionesState();
}

class _PantallaEvaluacionesState extends State<PantallaEvaluaciones> {
  final CommonApi api = CommonApi(ApiClient());

  bool cargando = true;
  String mensaje = '';

  List<dynamic> _evaluaciones = [];
  List<dynamic> _pacientesRelacionados = [];
  List<dynamic> _expedientes = [];

  final List<String> _tiposEvaluacion = const [
    'Ansiedad',
    'Depresión',
    'Estrés',
    'Autoestima',
    'Personalidad',
    'Riesgo psicosocial',
    'Evaluación general',
  ];

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
      final evaluaciones =
          await api.getEvaluacionesPsicologo(widget.psicologoId);
      final pacientes = await api.getPacientesPsicologo(widget.psicologoId);
      final expedientes = await api.getExpedientesPsicologo(widget.psicologoId);

      if (!mounted) return;

      setState(() {
        _evaluaciones = evaluaciones;
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
      case 'registrada':
      case 'completada':
        return Colors.green;
      case 'pendiente':
      case 'pendiente de revisión':
        return Colors.orange;
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

  Map<String, dynamic> _clienteDeRelacion(Map<String, dynamic> item) {
    final cliente = item['cliente'];
    if (cliente is Map<String, dynamic>) return cliente;
    return <String, dynamic>{};
  }

  Map<String, dynamic> _clienteDeEvaluacion(Map<String, dynamic> item) {
    final cliente = item['cliente'];
    if (cliente is Map<String, dynamic>) return cliente;
    return <String, dynamic>{};
  }

  String _nombrePacienteRelacion(Map<String, dynamic> item) {
    final cliente = _clienteDeRelacion(item);
    return (cliente['nombre'] ?? 'Paciente').toString();
  }

  String _nombrePacienteEvaluacion(Map<String, dynamic> item) {
    final cliente = _clienteDeEvaluacion(item);
    return (cliente['nombre'] ?? 'Paciente').toString();
  }

  String _correoPacienteEvaluacion(Map<String, dynamic> item) {
    final cliente = _clienteDeEvaluacion(item);
    return (cliente['correo'] ?? '—').toString();
  }

  String _telefonoPacienteEvaluacion(Map<String, dynamic> item) {
    final cliente = _clienteDeEvaluacion(item);
    return (cliente['telefono'] ?? '—').toString();
  }

  String _texto(dynamic value, {String fallback = 'Sin información.'}) {
    final txt = (value ?? '').toString().trim();
    return txt.isEmpty ? fallback : txt;
  }

  String _fechaSesion(Map<String, dynamic> item) {
    final value = (item['fecha_sesion'] ?? item['fecha'] ?? '').toString().trim();
    if (value.isEmpty) return 'Sin registro';
    return value;
  }

  String _estadoUiDesdeApi(String value) {
    switch (value.toLowerCase()) {
      case 'registrada':
        return 'Registrada';
      case 'pendiente':
        return 'Pendiente';
      case 'cancelada':
        return 'Cancelada';
      default:
        return value.isEmpty ? 'Sin estado' : value;
    }
  }

  List<Map<String, dynamic>> _expedientesDeCliente(int clienteId) {
    return _expedientes
        .map((e) => Map<String, dynamic>.from(e))
        .where((e) => _toInt(e['cliente_id']) == clienteId)
        .toList();
  }

  Future<void> _crearEvaluacion() async {
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

    final resultadoCtrl = TextEditingController();
    final observacionesCtrl = TextEditingController();

    String tipoSeleccionado = _tiposEvaluacion.first;
    String estadoSeleccionado = 'registrada';
    String modalidad = 'presencial';
    String nivelRiesgo = 'bajo';
    DateTime fechaSeleccionada = DateTime.now();

    List<Map<String, dynamic>> expedientesFiltrados = [];

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> seleccionarFecha() async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: fechaSeleccionada,
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
            );

            if (pickedDate == null) return;

            final pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(fechaSeleccionada),
            );

            if (pickedTime == null) return;

            setModalState(() {
              fechaSeleccionada = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
            });
          }

          return AlertDialog(
            title: const Text('Nueva evaluación'),
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
                  DropdownButtonFormField<String>(
                    initialValue: tipoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de evaluación',
                      border: OutlineInputBorder(),
                    ),
                    items: _tiposEvaluacion
                        .map(
                          (tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() {
                        tipoSeleccionado = value ?? _tiposEvaluacion.first;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: modalidad,
                    decoration: const InputDecoration(
                      labelText: 'Modalidad',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'presencial',
                        child: Text('Presencial'),
                      ),
                      DropdownMenuItem(
                        value: 'virtual',
                        child: Text('Virtual'),
                      ),
                      DropdownMenuItem(
                        value: 'telefonica',
                        child: Text('Telefónica'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        modalidad = value ?? 'presencial';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: nivelRiesgo,
                    decoration: const InputDecoration(
                      labelText: 'Nivel de riesgo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'bajo',
                        child: Text('Bajo'),
                      ),
                      DropdownMenuItem(
                        value: 'medio',
                        child: Text('Medio'),
                      ),
                      DropdownMenuItem(
                        value: 'alto',
                        child: Text('Alto'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        nivelRiesgo = value ?? 'bajo';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: estadoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'registrada',
                        child: Text('Registrada'),
                      ),
                      DropdownMenuItem(
                        value: 'pendiente',
                        child: Text('Pendiente'),
                      ),
                      DropdownMenuItem(
                        value: 'cancelada',
                        child: Text('Cancelada'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        estadoSeleccionado = value ?? 'registrada';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: seleccionarFecha,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      '${fechaSeleccionada.year}-${fechaSeleccionada.month.toString().padLeft(2, '0')}-${fechaSeleccionada.day.toString().padLeft(2, '0')} '
                      '${fechaSeleccionada.hour.toString().padLeft(2, '0')}:${fechaSeleccionada.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: resultadoCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Resultado',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: observacionesCtrl,
                    maxLines: 4,
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
      resultadoCtrl.dispose();
      observacionesCtrl.dispose();
      return;
    }

    if (clienteIdSeleccionado == null || expedienteIdSeleccionado == null) {
      resultadoCtrl.dispose();
      observacionesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona paciente y expediente'),
        ),
      );
      return;
    }

    try {
      await api.crearSesionPsicologo(
        psicologoId: widget.psicologoId,
        clienteId: clienteIdSeleccionado!,
        expedienteId: expedienteIdSeleccionado!,
        profesionalClienteId: relacionSeleccionadaId,
        fechaSesion:
            '${fechaSeleccionada.year}-${fechaSeleccionada.month.toString().padLeft(2, '0')}-${fechaSeleccionada.day.toString().padLeft(2, '0')} '
            '${fechaSeleccionada.hour.toString().padLeft(2, '0')}:${fechaSeleccionada.minute.toString().padLeft(2, '0')}:00',
        tipoSesion: 'evaluacion',
        modalidad: modalidad,
        nivelRiesgo: nivelRiesgo,
        evaluacionNombre: tipoSeleccionado,
        evaluacionResultado:
            resultadoCtrl.text.trim().isEmpty ? null : resultadoCtrl.text.trim(),
        observaciones: observacionesCtrl.text.trim().isEmpty
            ? null
            : observacionesCtrl.text.trim(),
        estado: estadoSeleccionado,
      );

      resultadoCtrl.dispose();
      observacionesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evaluación registrada')),
      );

      await _cargarTodo();
    } catch (e) {
      resultadoCtrl.dispose();
      observacionesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _mostrarDetalle(Map<String, dynamic> evaluacion) {
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
                    _texto(
                      evaluacion['evaluacion_nombre'],
                      fallback: 'Evaluación',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _datoDetalle(
                    'Paciente',
                    _nombrePacienteEvaluacion(evaluacion),
                  ),
                  _datoDetalle(
                    'Correo',
                    _correoPacienteEvaluacion(evaluacion),
                  ),
                  _datoDetalle(
                    'Teléfono',
                    _telefonoPacienteEvaluacion(evaluacion),
                  ),
                  _datoDetalle(
                    'Fecha',
                    _fechaSesion(evaluacion),
                  ),
                  _datoDetalle(
                    'Resultado',
                    _texto(
                      evaluacion['evaluacion_resultado'],
                      fallback: 'Sin resultado',
                    ),
                  ),
                  _datoDetalle(
                    'Estado',
                    _estadoUiDesdeApi((evaluacion['estado'] ?? '').toString()),
                  ),
                  _datoDetalle(
                    'Riesgo',
                    _texto(evaluacion['nivel_riesgo'], fallback: '—'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Observaciones',
                    style: TextStyle(
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
                      _texto(evaluacion['observaciones']),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _datoDetalle(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
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
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
        ),
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
    final completadas = _evaluaciones
        .where(
          (e) =>
              ((e['estado'] ?? '').toString().toLowerCase()) == 'registrada',
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluaciones'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _cargarTodo,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Nueva evaluación',
            onPressed: _crearEvaluacion,
            icon: const Icon(Icons.add_chart),
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
                                  Icons.quiz_outlined,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_saludoPorHora()}, módulo de evaluaciones',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tests, escalas y resultados terapéuticos.',
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
                                icon: Icons.fact_check_outlined,
                                titulo: 'Total',
                                valor: '${_evaluaciones.length}',
                                accent: accent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _resumenCard(
                                icon: Icons.check_circle_outline,
                                titulo: 'Registradas',
                                valor: '$completadas',
                                accent: accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: _crearEvaluacion,
                          icon: const Icon(Icons.add),
                          label: const Text('Registrar evaluación'),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Evaluaciones registradas',
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
                        else if (_evaluaciones.isEmpty)
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
                                  ? 'No hay evaluaciones registradas todavía.'
                                  : mensaje,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.80),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ..._evaluaciones.map((item) {
                            final evaluacion = Map<String, dynamic>.from(item);
                            final estado =
                                (evaluacion['estado'] ?? 'Sin estado').toString();
                            final colorEstado = _colorEstado(estado);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _mostrarDetalle(evaluacion),
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
                                          Icons.quiz_outlined,
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
                                              _nombrePacienteEvaluacion(evaluacion),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_texto(evaluacion['evaluacion_nombre'], fallback: 'Evaluación')} • ${_fechaSesion(evaluacion)}',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.72,
                                                ),
                                                fontSize: 12.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Resultado: ${_texto(evaluacion['evaluacion_resultado'], fallback: 'Sin resultado')}',
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
                                          _estadoUiDesdeApi(estado),
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