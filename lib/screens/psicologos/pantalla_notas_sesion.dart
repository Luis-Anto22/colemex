import 'package:flutter/material.dart';

import 'package:advocatus/services/api_services/api_client.dart';
import 'package:advocatus/services/api_services/common_api.dart';

class PantallaNotasSesion extends StatefulWidget {
  final int psicologoId;

  const PantallaNotasSesion({
    super.key,
    required this.psicologoId,
  });

  @override
  State<PantallaNotasSesion> createState() => _PantallaNotasSesionState();
}

class _PantallaNotasSesionState extends State<PantallaNotasSesion> {
  final CommonApi api = CommonApi(ApiClient());

  bool cargando = true;
  String mensaje = '';

  List<dynamic> _notas = [];
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
      final notas = await api.getSesionesPsicologo(
        psicologoId: widget.psicologoId,
      );
      final pacientes = await api.getPacientesPsicologo(widget.psicologoId);
      final expedientes = await api.getExpedientesPsicologo(widget.psicologoId);

      if (!mounted) return;

      setState(() {
        _notas = notas;
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
        return Colors.green;
      case 'pendiente':
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

  Map<String, dynamic> _clienteDeNota(Map<String, dynamic> item) {
    final cliente = item['cliente'];
    if (cliente is Map<String, dynamic>) return cliente;
    return <String, dynamic>{};
  }

  String _nombrePacienteRelacion(Map<String, dynamic> item) {
    final cliente = _clienteDeRelacion(item);
    return (cliente['nombre'] ?? 'Paciente').toString();
  }

  String _nombrePacienteNota(Map<String, dynamic> item) {
    final cliente = _clienteDeNota(item);
    return (cliente['nombre'] ?? 'Paciente').toString();
  }

  String _correoPacienteNota(Map<String, dynamic> item) {
    final cliente = _clienteDeNota(item);
    return (cliente['correo'] ?? '—').toString();
  }

  String _telefonoPacienteNota(Map<String, dynamic> item) {
    final cliente = _clienteDeNota(item);
    return (cliente['telefono'] ?? '—').toString();
  }

  String _texto(dynamic value, {String fallback = 'Sin información.'}) {
    final txt = (value ?? '').toString().trim();
    return txt.isEmpty ? fallback : txt;
  }

  String _tipoSesionBonito(String value) {
    switch (value) {
      case 'primera_consulta':
        return 'Primera consulta';
      case 'seguimiento':
        return 'Seguimiento';
      case 'cierre':
        return 'Cierre';
      case 'intervencion_crisis':
        return 'Intervención en crisis';
      case 'evaluacion':
        return 'Evaluación';
      default:
        return value;
    }
  }

  String _tipoSesionApiDesdeUi(String value) {
    switch (value) {
      case 'Primera consulta':
        return 'primera_consulta';
      case 'Seguimiento':
        return 'seguimiento';
      case 'Cierre':
        return 'cierre';
      case 'Intervención en crisis':
        return 'intervencion_crisis';
      case 'Evaluación':
        return 'evaluacion';
      default:
        return 'seguimiento';
    }
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
        return value;
    }
  }

  String _fechaSesion(Map<String, dynamic> item) {
    final value = (item['fecha_sesion'] ?? item['fecha'] ?? '').toString().trim();
    if (value.isEmpty) return 'Sin registro';
    return value;
  }

  List<Map<String, dynamic>> _expedientesDeCliente(int clienteId) {
    return _expedientes
        .map((e) => Map<String, dynamic>.from(e))
        .where((e) => _toInt(e['cliente_id']) == clienteId)
        .toList();
  }

  Future<void> _crearNota() async {
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

    final estadoEmocionalCtrl = TextEditingController();
    final avancesCtrl = TextEditingController();
    final tareasCtrl = TextEditingController();
    final observacionesCtrl = TextEditingController();
    final objetivoSesionCtrl = TextEditingController();
    final acuerdosSesionCtrl = TextEditingController();

    String tipoSesionUi = 'Seguimiento';
    String modalidad = 'presencial';
    String estado = 'registrada';
    String nivelAnimo = '';
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
            title: const Text('Nueva nota de sesión'),
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
                    initialValue: tipoSesionUi,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de sesión',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Primera consulta',
                        child: Text('Primera consulta'),
                      ),
                      DropdownMenuItem(
                        value: 'Seguimiento',
                        child: Text('Seguimiento'),
                      ),
                      DropdownMenuItem(
                        value: 'Cierre',
                        child: Text('Cierre'),
                      ),
                      DropdownMenuItem(
                        value: 'Intervención en crisis',
                        child: Text('Intervención en crisis'),
                      ),
                      DropdownMenuItem(
                        value: 'Evaluación',
                        child: Text('Evaluación'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        tipoSesionUi = value ?? 'Seguimiento';
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
                  TextField(
                    controller: estadoEmocionalCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Estado emocional',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) => nivelAnimo = value.trim(),
                    decoration: const InputDecoration(
                      labelText: 'Nivel de ánimo',
                      border: OutlineInputBorder(),
                    ),
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
                  TextField(
                    controller: avancesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Avances / hallazgos',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tareasCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Tareas terapéuticas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: objetivoSesionCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Objetivo de la sesión',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: acuerdosSesionCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Acuerdos de sesión',
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
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: estado,
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
                        estado = value ?? 'registrada';
                      });
                    },
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
      estadoEmocionalCtrl.dispose();
      avancesCtrl.dispose();
      tareasCtrl.dispose();
      observacionesCtrl.dispose();
      objetivoSesionCtrl.dispose();
      acuerdosSesionCtrl.dispose();
      return;
    }

    if (clienteIdSeleccionado == null || expedienteIdSeleccionado == null) {
      estadoEmocionalCtrl.dispose();
      avancesCtrl.dispose();
      tareasCtrl.dispose();
      observacionesCtrl.dispose();
      objetivoSesionCtrl.dispose();
      acuerdosSesionCtrl.dispose();

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
        tipoSesion: _tipoSesionApiDesdeUi(tipoSesionUi),
        modalidad: modalidad,
        estadoEmocional: estadoEmocionalCtrl.text.trim().isEmpty
            ? null
            : estadoEmocionalCtrl.text.trim(),
        nivelAnimo: nivelAnimo.isEmpty ? null : nivelAnimo,
        nivelRiesgo: nivelRiesgo,
        avances:
            avancesCtrl.text.trim().isEmpty ? null : avancesCtrl.text.trim(),
        observaciones: observacionesCtrl.text.trim().isEmpty
            ? null
            : observacionesCtrl.text.trim(),
        tareasTerapeuticas:
            tareasCtrl.text.trim().isEmpty ? null : tareasCtrl.text.trim(),
        objetivoSesion: objetivoSesionCtrl.text.trim().isEmpty
            ? null
            : objetivoSesionCtrl.text.trim(),
        acuerdosSesion: acuerdosSesionCtrl.text.trim().isEmpty
            ? null
            : acuerdosSesionCtrl.text.trim(),
        estado: estado,
      );

      estadoEmocionalCtrl.dispose();
      avancesCtrl.dispose();
      tareasCtrl.dispose();
      observacionesCtrl.dispose();
      objetivoSesionCtrl.dispose();
      acuerdosSesionCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota de sesión registrada')),
      );

      await _cargarTodo();
    } catch (e) {
      estadoEmocionalCtrl.dispose();
      avancesCtrl.dispose();
      tareasCtrl.dispose();
      observacionesCtrl.dispose();
      objetivoSesionCtrl.dispose();
      acuerdosSesionCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _mostrarDetalle(Map<String, dynamic> nota) {
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
                    _nombrePacienteNota(nota),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _datoDetalle('Correo', _correoPacienteNota(nota)),
                  _datoDetalle('Teléfono', _telefonoPacienteNota(nota)),
                  _datoDetalle('Fecha', _fechaSesion(nota)),
                  _datoDetalle(
                    'Tipo de sesión',
                    _tipoSesionBonito((nota['tipo_sesion'] ?? 'seguimiento').toString()),
                  ),
                  _datoDetalle(
                    'Modalidad',
                    _texto(nota['modalidad'], fallback: '—'),
                  ),
                  _datoDetalle(
                    'Estado',
                    _estadoUiDesdeApi((nota['estado'] ?? '').toString()),
                  ),
                  _datoDetalle(
                    'Estado emocional',
                    _texto(nota['estado_emocional'], fallback: '—'),
                  ),
                  _datoDetalle(
                    'Nivel de ánimo',
                    _texto(nota['nivel_animo'], fallback: '—'),
                  ),
                  _datoDetalle(
                    'Riesgo',
                    _texto(nota['nivel_riesgo'], fallback: '—'),
                  ),
                  const SizedBox(height: 12),
                  _bloqueTexto(
                    titulo: 'Avances / hallazgos',
                    contenido: _texto(nota['avances']),
                  ),
                  _bloqueTexto(
                    titulo: 'Tareas terapéuticas',
                    contenido: _texto(nota['tareas_terapeuticas']),
                  ),
                  _bloqueTexto(
                    titulo: 'Objetivo de la sesión',
                    contenido: _texto(nota['objetivo_sesion']),
                  ),
                  _bloqueTexto(
                    titulo: 'Acuerdos de sesión',
                    contenido: _texto(nota['acuerdos_sesion']),
                  ),
                  _bloqueTexto(
                    titulo: 'Observaciones',
                    contenido: _texto(nota['observaciones']),
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
            width: 120,
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
    final registradas = _notas
        .where(
          (n) =>
              ((n['estado'] ?? '').toString().toLowerCase()) == 'registrada',
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas de sesión'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _cargarTodo,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Nueva nota',
            onPressed: _crearNota,
            icon: const Icon(Icons.note_add_outlined),
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
                                  Icons.edit_note_outlined,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_saludoPorHora()}, notas de sesión',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Registro clínico, avances y tareas terapéuticas.',
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
                                icon: Icons.notes_outlined,
                                titulo: 'Total',
                                valor: '${_notas.length}',
                                accent: accent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _resumenCard(
                                icon: Icons.check_circle_outline,
                                titulo: 'Registradas',
                                valor: '$registradas',
                                accent: accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: _crearNota,
                          icon: const Icon(Icons.add),
                          label: const Text('Registrar nota de sesión'),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Notas registradas',
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
                        else if (_notas.isEmpty)
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
                                  ? 'No hay notas de sesión registradas todavía.'
                                  : mensaje,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.80),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ..._notas.map((item) {
                            final nota = Map<String, dynamic>.from(item);
                            final estado =
                                (nota['estado'] ?? 'Sin estado').toString();
                            final colorEstado = _colorEstado(estado);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _mostrarDetalle(nota),
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
                                          Icons.edit_note_outlined,
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
                                              _nombrePacienteNota(nota),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_tipoSesionBonito((nota['tipo_sesion'] ?? 'seguimiento').toString())} • ${_fechaSesion(nota)}',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.72,
                                                ),
                                                fontSize: 12.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Estado emocional: ${_texto(nota['estado_emocional'], fallback: 'Sin registro')}',
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