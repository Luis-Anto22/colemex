import 'package:flutter/material.dart';

import 'package:advocatus/services/api_services/api_client.dart';
import 'package:advocatus/services/api_services/common_api.dart';

class PantallaSeguimientoEmocional extends StatefulWidget {
  final int psicologoId;

  const PantallaSeguimientoEmocional({
    super.key,
    required this.psicologoId,
  });

  @override
  State<PantallaSeguimientoEmocional> createState() =>
      _PantallaSeguimientoEmocionalState();
}

class _PantallaSeguimientoEmocionalState
    extends State<PantallaSeguimientoEmocional> {
  final CommonApi api = CommonApi(ApiClient());

  bool cargando = true;
  String mensaje = '';

  List<dynamic> _seguimientos = [];
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
      final seguimientos = await api.getSeguimientosPsicologo(widget.psicologoId);
      final pacientes = await api.getPacientesPsicologo(widget.psicologoId);
      final expedientes = await api.getExpedientesPsicologo(widget.psicologoId);

      if (!mounted) return;

      setState(() {
        _seguimientos = seguimientos;
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
      case 'activo':
        return Colors.green;
      case 'seguimiento':
        return Colors.orange;
      case 'cerrado':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  Color _colorRiesgo(String riesgo) {
    switch (riesgo.toLowerCase()) {
      case 'bajo':
        return Colors.green;
      case 'medio':
        return Colors.orange;
      case 'alto':
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

  Map<String, dynamic> _clienteDeSeguimiento(Map<String, dynamic> item) {
    final cliente = item['cliente'];
    if (cliente is Map<String, dynamic>) return cliente;
    return <String, dynamic>{};
  }

  String _nombrePacienteRelacion(Map<String, dynamic> item) {
    final cliente = _clienteDeRelacion(item);
    return (cliente['nombre'] ?? 'Paciente').toString();
  }

  String _nombrePacienteSeguimiento(Map<String, dynamic> item) {
    final cliente = _clienteDeSeguimiento(item);
    return (cliente['nombre'] ?? 'Paciente').toString();
  }

  String _correoPacienteSeguimiento(Map<String, dynamic> item) {
    final cliente = _clienteDeSeguimiento(item);
    return (cliente['correo'] ?? '—').toString();
  }

  String _telefonoPacienteSeguimiento(Map<String, dynamic> item) {
    final cliente = _clienteDeSeguimiento(item);
    return (cliente['telefono'] ?? '—').toString();
  }

  String _fechaSeguimiento(Map<String, dynamic> item) {
    final value = (item['fecha_sesion'] ?? item['fecha'] ?? '').toString().trim();
    if (value.isEmpty) return 'Sin registro';
    return value;
  }

  String _estadoUiDesdeApi(String value) {
    switch (value.toLowerCase()) {
      case 'registrada':
        return 'Activo';
      case 'pendiente':
        return 'Seguimiento';
      case 'cancelada':
        return 'Cerrado';
      default:
        return value.isEmpty ? 'Sin estado' : value;
    }
  }

  String _estadoApiDesdeUi(String value) {
    switch (value) {
      case 'Activo':
        return 'registrada';
      case 'Seguimiento':
        return 'pendiente';
      case 'Cerrado':
        return 'cancelada';
      default:
        return 'registrada';
    }
  }

  List<Map<String, dynamic>> _expedientesDeCliente(int clienteId) {
    return _expedientes
        .map((e) => Map<String, dynamic>.from(e))
        .where((e) => _toInt(e['cliente_id']) == clienteId)
        .toList();
  }

  Future<void> _crearSeguimiento() async {
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
    final nivelAnimoCtrl = TextEditingController();
    final avanceCtrl = TextEditingController();
    final retrocesoCtrl = TextEditingController();
    final observacionesCtrl = TextEditingController();

    String riesgo = 'Bajo';
    String estado = 'Activo';
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
            title: const Text('Nuevo seguimiento emocional'),
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
                    controller: estadoEmocionalCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Estado emocional',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nivelAnimoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nivel de ánimo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: riesgo,
                    decoration: const InputDecoration(
                      labelText: 'Nivel de riesgo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Bajo',
                        child: Text('Bajo'),
                      ),
                      DropdownMenuItem(
                        value: 'Medio',
                        child: Text('Medio'),
                      ),
                      DropdownMenuItem(
                        value: 'Alto',
                        child: Text('Alto'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        riesgo = value ?? 'Bajo';
                      });
                    },
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
                        value: 'Activo',
                        child: Text('Activo'),
                      ),
                      DropdownMenuItem(
                        value: 'Seguimiento',
                        child: Text('Seguimiento'),
                      ),
                      DropdownMenuItem(
                        value: 'Cerrado',
                        child: Text('Cerrado'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        estado = value ?? 'Activo';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: avanceCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Avances',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: retrocesoCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Retrocesos / alertas',
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
      estadoEmocionalCtrl.dispose();
      nivelAnimoCtrl.dispose();
      avanceCtrl.dispose();
      retrocesoCtrl.dispose();
      observacionesCtrl.dispose();
      return;
    }

    if (clienteIdSeleccionado == null || expedienteIdSeleccionado == null) {
      estadoEmocionalCtrl.dispose();
      nivelAnimoCtrl.dispose();
      avanceCtrl.dispose();
      retrocesoCtrl.dispose();
      observacionesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona paciente y expediente')),
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
        tipoSesion: 'seguimiento',
        estadoEmocional: estadoEmocionalCtrl.text.trim().isEmpty
            ? null
            : estadoEmocionalCtrl.text.trim(),
        nivelAnimo: nivelAnimoCtrl.text.trim().isEmpty
            ? null
            : nivelAnimoCtrl.text.trim(),
        nivelRiesgo: riesgo.toLowerCase(),
        avances:
            avanceCtrl.text.trim().isEmpty ? null : avanceCtrl.text.trim(),
        retrocesos:
            retrocesoCtrl.text.trim().isEmpty ? null : retrocesoCtrl.text.trim(),
        observaciones: observacionesCtrl.text.trim().isEmpty
            ? null
            : observacionesCtrl.text.trim(),
        estado: _estadoApiDesdeUi(estado),
      );

      estadoEmocionalCtrl.dispose();
      nivelAnimoCtrl.dispose();
      avanceCtrl.dispose();
      retrocesoCtrl.dispose();
      observacionesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seguimiento emocional registrado')),
      );

      await _cargarTodo();
    } catch (e) {
      estadoEmocionalCtrl.dispose();
      nivelAnimoCtrl.dispose();
      avanceCtrl.dispose();
      retrocesoCtrl.dispose();
      observacionesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _mostrarDetalle(Map<String, dynamic> seguimiento) {
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
                    _nombrePacienteSeguimiento(seguimiento),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _datoDetalle(
                    'Correo',
                    _correoPacienteSeguimiento(seguimiento),
                  ),
                  _datoDetalle(
                    'Teléfono',
                    _telefonoPacienteSeguimiento(seguimiento),
                  ),
                  _datoDetalle(
                    'Fecha',
                    _fechaSeguimiento(seguimiento),
                  ),
                  _datoDetalle(
                    'Estado emocional',
                    _texto(seguimiento['estado_emocional'], fallback: '—'),
                  ),
                  _datoDetalle(
                    'Nivel de ánimo',
                    _texto(seguimiento['nivel_animo'], fallback: '—'),
                  ),
                  _datoDetalle(
                    'Riesgo',
                    _texto(seguimiento['nivel_riesgo'], fallback: '—'),
                  ),
                  _datoDetalle(
                    'Estado',
                    _estadoUiDesdeApi((seguimiento['estado'] ?? '').toString()),
                  ),
                  const SizedBox(height: 12),
                  _bloqueTexto(
                    titulo: 'Avances',
                    contenido: _texto(seguimiento['avances']),
                  ),
                  _bloqueTexto(
                    titulo: 'Retrocesos / alertas',
                    contenido: _texto(seguimiento['retrocesos']),
                  ),
                  _bloqueTexto(
                    titulo: 'Observaciones',
                    contenido: _texto(seguimiento['observaciones']),
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
    final activos = _seguimientos
        .where(
          (s) => _estadoUiDesdeApi((s['estado'] ?? '').toString()) == 'Activo',
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento emocional'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _cargarTodo,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Nuevo seguimiento',
            onPressed: _crearSeguimiento,
            icon: const Icon(Icons.monitor_heart_outlined),
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
                                  Icons.monitor_heart_outlined,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_saludoPorHora()}, seguimiento emocional',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Monitoreo del estado emocional, avances y alertas.',
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
                                icon: Icons.favorite_border,
                                titulo: 'Total',
                                valor: '${_seguimientos.length}',
                                accent: accent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _resumenCard(
                                icon: Icons.trending_up_outlined,
                                titulo: 'Activos',
                                valor: '$activos',
                                accent: accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: _crearSeguimiento,
                          icon: const Icon(Icons.add),
                          label: const Text('Registrar seguimiento'),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Seguimientos registrados',
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
                        else if (_seguimientos.isEmpty)
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
                                  ? 'No hay seguimientos emocionales registrados todavía.'
                                  : mensaje,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.80),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ..._seguimientos.map((item) {
                            final seguimiento = Map<String, dynamic>.from(item);
                            final estado = _estadoUiDesdeApi(
                              (seguimiento['estado'] ?? '').toString(),
                            );
                            final riesgo = _texto(
                              seguimiento['nivel_riesgo'],
                              fallback: 'Sin riesgo',
                            );
                            final colorEstado = _colorEstado(estado);
                            final colorRiesgo = _colorRiesgo(riesgo);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _mostrarDetalle(seguimiento),
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
                                          Icons.monitor_heart_outlined,
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
                                              _nombrePacienteSeguimiento(
                                                seguimiento,
                                              ),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_texto(seguimiento['estado_emocional'], fallback: 'Sin estado emocional')} • ${_fechaSeguimiento(seguimiento)}',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.72,
                                                ),
                                                fontSize: 12.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 6,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                    color: colorEstado
                                                        .withValues(alpha: 0.14),
                                                  ),
                                                  child: Text(
                                                    estado,
                                                    style: TextStyle(
                                                      color: colorEstado,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                    color: colorRiesgo
                                                        .withValues(alpha: 0.14),
                                                  ),
                                                  child: Text(
                                                    'Riesgo $riesgo',
                                                    style: TextStyle(
                                                      color: colorRiesgo,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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