import 'package:flutter/material.dart';

import 'package:advocatus/services/api_services/api_client.dart';
import 'package:advocatus/services/api_services/common_api.dart';

class PantallaPlanTerapeutico extends StatefulWidget {
  final int psicologoId;

  const PantallaPlanTerapeutico({
    super.key,
    required this.psicologoId,
  });

  @override
  State<PantallaPlanTerapeutico> createState() =>
      _PantallaPlanTerapeuticoState();
}

class _PantallaPlanTerapeuticoState extends State<PantallaPlanTerapeutico> {
  final CommonApi api = CommonApi(ApiClient());

  bool cargando = true;
  String mensaje = '';

  List<dynamic> _planes = [];
  List<dynamic> _pacientesRelacionados = [];

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
      final expedientes = await api.getExpedientesPsicologo(widget.psicologoId);
      final pacientes = await api.getPacientesPsicologo(widget.psicologoId);

      if (!mounted) return;

      setState(() {
        _planes = expedientes;
        _pacientesRelacionados = pacientes;
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

  Color _colorProgreso(String progreso) {
    switch (progreso.toLowerCase()) {
      case 'inicial':
        return Colors.orange;
      case 'en curso':
        return Colors.blue;
      case 'avanzado':
        return Colors.green;
      case 'cerrado':
        return Colors.grey;
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

  Map<String, dynamic> _clienteDePlan(Map<String, dynamic> item) {
    final cliente = item['cliente'];
    if (cliente is Map<String, dynamic>) return cliente;
    return <String, dynamic>{};
  }

  String _nombrePacienteRelacion(Map<String, dynamic> item) {
    final cliente = _clienteDeRelacion(item);
    return (cliente['nombre'] ?? 'Paciente').toString();
  }

  String _nombrePacientePlan(Map<String, dynamic> item) {
    final cliente = _clienteDePlan(item);
    return (cliente['nombre'] ?? 'Paciente').toString();
  }

  String _correoPacientePlan(Map<String, dynamic> item) {
    final cliente = _clienteDePlan(item);
    return (cliente['correo'] ?? '—').toString();
  }

  String _telefonoPacientePlan(Map<String, dynamic> item) {
    final cliente = _clienteDePlan(item);
    return (cliente['telefono'] ?? '—').toString();
  }

  String _mapEstadoAProgreso(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo':
        return 'En curso';
      case 'seguimiento':
        return 'Avanzado';
      case 'cerrado':
        return 'Cerrado';
      default:
        return 'Inicial';
    }
  }

  String _mapProgresoAEstado(String progreso) {
    switch (progreso.toLowerCase()) {
      case 'inicial':
        return 'activo';
      case 'en curso':
        return 'activo';
      case 'avanzado':
        return 'seguimiento';
      case 'cerrado':
        return 'cerrado';
      default:
        return 'activo';
    }
  }

  String _fechaInicioPlan(Map<String, dynamic> item) {
    final value = (item['fecha_apertura'] ?? '').toString().trim();
    if (value.isEmpty) return 'Sin registro';
    return value;
  }

  Map<String, String> _parseNotasPlan(String? notas) {
    final texto = (notas ?? '').trim();
    if (texto.isEmpty) {
      return {
        'sesiones': '',
        'frecuencia': '',
        'metas': '',
        'pendientes': '',
      };
    }

    String extraer(String inicio, List<String> siguientes) {
      final start = texto.indexOf(inicio);
      if (start == -1) return '';
      final contentStart = start + inicio.length;

      int? nearestEnd;
      for (final s in siguientes) {
        final idx = texto.indexOf(s, contentStart);
        if (idx != -1) {
          if (nearestEnd == null || idx < nearestEnd) {
            nearestEnd = idx;
          }
        }
      }

      final raw = nearestEnd == null
          ? texto.substring(contentStart)
          : texto.substring(contentStart, nearestEnd);

      return raw.trim();
    }

    return {
      'sesiones': extraer(
        'Sesiones estimadas:',
        ['Frecuencia:', 'Metas logradas:', 'Pendientes:'],
      ),
      'frecuencia': extraer(
        'Frecuencia:',
        ['Metas logradas:', 'Pendientes:'],
      ),
      'metas': extraer(
        'Metas logradas:',
        ['Pendientes:'],
      ),
      'pendientes': extraer(
        'Pendientes:',
        [],
      ),
    };
  }

  String _buildNotasPlan({
    required String sesionesEstimadas,
    required String frecuencia,
    required String metasLogradas,
    required String pendientes,
  }) {
    final buffer = StringBuffer();

    if (sesionesEstimadas.trim().isNotEmpty) {
      buffer.writeln('Sesiones estimadas:');
      buffer.writeln(sesionesEstimadas.trim());
      buffer.writeln();
    }

    if (frecuencia.trim().isNotEmpty) {
      buffer.writeln('Frecuencia:');
      buffer.writeln(frecuencia.trim());
      buffer.writeln();
    }

    if (metasLogradas.trim().isNotEmpty) {
      buffer.writeln('Metas logradas:');
      buffer.writeln(metasLogradas.trim());
      buffer.writeln();
    }

    if (pendientes.trim().isNotEmpty) {
      buffer.writeln('Pendientes:');
      buffer.writeln(pendientes.trim());
    }

    return buffer.toString().trim();
  }

  Future<void> _crearPlan() async {
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

    final objetivoGeneralCtrl = TextEditingController();
    final objetivosEspecificosCtrl = TextEditingController();
    final enfoqueCtrl = TextEditingController();
    final sesionesCtrl = TextEditingController();
    final frecuenciaCtrl = TextEditingController();
    final planCtrl = TextEditingController();
    final metasLogradasCtrl = TextEditingController();
    final pendientesCtrl = TextEditingController();

    String progresoSeleccionado = 'Inicial';
    DateTime fechaInicio = DateTime.now();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> seleccionarFecha() async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: fechaInicio,
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
            );

            if (pickedDate == null) return;

            final pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(fechaInicio),
            );

            if (pickedTime == null) return;

            setModalState(() {
              fechaInicio = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
            });
          }

          return AlertDialog(
            title: const Text('Nuevo plan terapéutico'),
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
                        final item = _pacientesRelacionados.cast<dynamic>().firstWhere(
                              (e) => _toInt((e as Map<String, dynamic>)['id']) == value,
                              orElse: () => <String, dynamic>{},
                            );
                        if (item is Map<String, dynamic>) {
                          clienteIdSeleccionado = _toInt(item['cliente_id']);
                        } else {
                          clienteIdSeleccionado = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: objetivoGeneralCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Objetivo general',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: objetivosEspecificosCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Objetivos específicos',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: enfoqueCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Enfoque terapéutico',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: sesionesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sesiones estimadas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: frecuenciaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Frecuencia',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: planCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Plan de tratamiento',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: progresoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Progreso',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Inicial',
                        child: Text('Inicial'),
                      ),
                      DropdownMenuItem(
                        value: 'En curso',
                        child: Text('En curso'),
                      ),
                      DropdownMenuItem(
                        value: 'Avanzado',
                        child: Text('Avanzado'),
                      ),
                      DropdownMenuItem(
                        value: 'Cerrado',
                        child: Text('Cerrado'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        progresoSeleccionado = value ?? 'Inicial';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: seleccionarFecha,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      '${fechaInicio.year}-${fechaInicio.month.toString().padLeft(2, '0')}-${fechaInicio.day.toString().padLeft(2, '0')} '
                      '${fechaInicio.hour.toString().padLeft(2, '0')}:${fechaInicio.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: metasLogradasCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Metas logradas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pendientesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Pendientes',
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
      objetivoGeneralCtrl.dispose();
      objetivosEspecificosCtrl.dispose();
      enfoqueCtrl.dispose();
      sesionesCtrl.dispose();
      frecuenciaCtrl.dispose();
      planCtrl.dispose();
      metasLogradasCtrl.dispose();
      pendientesCtrl.dispose();
      return;
    }

    if (clienteIdSeleccionado == null || relacionSeleccionadaId == null) {
      objetivoGeneralCtrl.dispose();
      objetivosEspecificosCtrl.dispose();
      enfoqueCtrl.dispose();
      sesionesCtrl.dispose();
      frecuenciaCtrl.dispose();
      planCtrl.dispose();
      metasLogradasCtrl.dispose();
      pendientesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un paciente')),
      );
      return;
    }

    try {
      final notasGenerales = _buildNotasPlan(
        sesionesEstimadas: sesionesCtrl.text.trim(),
        frecuencia: frecuenciaCtrl.text.trim(),
        metasLogradas: metasLogradasCtrl.text.trim(),
        pendientes: pendientesCtrl.text.trim(),
      );

      await api.crearExpedientePsicologo(
        psicologoId: widget.psicologoId,
        clienteId: clienteIdSeleccionado!,
        profesionalClienteId: relacionSeleccionadaId,
        objetivoGeneral: objetivoGeneralCtrl.text.trim().isEmpty
            ? null
            : objetivoGeneralCtrl.text.trim(),
        objetivosEspecificos: objetivosEspecificosCtrl.text.trim().isEmpty
            ? null
            : objetivosEspecificosCtrl.text.trim(),
        enfoqueTerapeutico:
            enfoqueCtrl.text.trim().isEmpty ? null : enfoqueCtrl.text.trim(),
        planTratamiento:
            planCtrl.text.trim().isEmpty ? null : planCtrl.text.trim(),
        estado: _mapProgresoAEstado(progresoSeleccionado),
        fechaApertura:
            '${fechaInicio.year}-${fechaInicio.month.toString().padLeft(2, '0')}-${fechaInicio.day.toString().padLeft(2, '0')} '
            '${fechaInicio.hour.toString().padLeft(2, '0')}:${fechaInicio.minute.toString().padLeft(2, '0')}:00',
        notasGenerales: notasGenerales.isEmpty ? null : notasGenerales,
      );

      objetivoGeneralCtrl.dispose();
      objetivosEspecificosCtrl.dispose();
      enfoqueCtrl.dispose();
      sesionesCtrl.dispose();
      frecuenciaCtrl.dispose();
      planCtrl.dispose();
      metasLogradasCtrl.dispose();
      pendientesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan terapéutico registrado')),
      );

      await _cargarTodo();
    } catch (e) {
      objetivoGeneralCtrl.dispose();
      objetivosEspecificosCtrl.dispose();
      enfoqueCtrl.dispose();
      sesionesCtrl.dispose();
      frecuenciaCtrl.dispose();
      planCtrl.dispose();
      metasLogradasCtrl.dispose();
      pendientesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _mostrarDetalle(Map<String, dynamic> plan) {
    final notas = _parseNotasPlan((plan['notas_generales'] ?? '').toString());

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
                    _nombrePacientePlan(plan),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _datoDetalle('Correo', _correoPacientePlan(plan)),
                  _datoDetalle('Teléfono', _telefonoPacientePlan(plan)),
                  _datoDetalle(
                    'Enfoque',
                    _texto(plan['enfoque_terapeutico'], fallback: '—'),
                  ),
                  _datoDetalle(
                    'Sesiones',
                    _texto(notas['sesiones'], fallback: '—'),
                  ),
                  _datoDetalle(
                    'Frecuencia',
                    _texto(notas['frecuencia'], fallback: '—'),
                  ),
                  _datoDetalle(
                    'Progreso',
                    _mapEstadoAProgreso((plan['estado'] ?? '').toString()),
                  ),
                  _datoDetalle(
                    'Fecha inicio',
                    _fechaInicioPlan(plan),
                  ),
                  const SizedBox(height: 12),
                  _bloqueTexto(
                    titulo: 'Objetivo general',
                    contenido: _texto(plan['objetivo_general']),
                  ),
                  _bloqueTexto(
                    titulo: 'Objetivos específicos',
                    contenido: _texto(plan['objetivos_especificos']),
                  ),
                  _bloqueTexto(
                    titulo: 'Plan de tratamiento',
                    contenido: _texto(plan['plan_tratamiento']),
                  ),
                  _bloqueTexto(
                    titulo: 'Metas logradas',
                    contenido: _texto(notas['metas']),
                  ),
                  _bloqueTexto(
                    titulo: 'Pendientes',
                    contenido: _texto(notas['pendientes']),
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
    final enCurso = _planes
        .where(
          (p) =>
              _mapEstadoAProgreso((p['estado'] ?? '').toString()) == 'En curso',
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan terapéutico'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _cargarTodo,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Nuevo plan',
            onPressed: _crearPlan,
            icon: const Icon(Icons.add_task),
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
                                  Icons.flag_outlined,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_saludoPorHora()}, plan terapéutico',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Objetivos, enfoque y seguimiento del proceso terapéutico.',
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
                                valor: '${_planes.length}',
                                accent: accent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _resumenCard(
                                icon: Icons.track_changes_outlined,
                                titulo: 'En curso',
                                valor: '$enCurso',
                                accent: accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: _crearPlan,
                          icon: const Icon(Icons.add),
                          label: const Text('Crear plan terapéutico'),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Planes registrados',
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
                        else if (_planes.isEmpty)
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
                                  ? 'No hay planes terapéuticos registrados todavía.'
                                  : mensaje,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.80),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ..._planes.map((item) {
                            final plan = Map<String, dynamic>.from(item);
                            final progreso =
                                _mapEstadoAProgreso((plan['estado'] ?? '').toString());
                            final colorProgreso = _colorProgreso(progreso);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _mostrarDetalle(plan),
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
                                          Icons.flag_outlined,
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
                                              _nombrePacientePlan(plan),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Enfoque: ${_texto(plan['enfoque_terapeutico'], fallback: 'Sin enfoque')}',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.72,
                                                ),
                                                fontSize: 12.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Objetivo: ${_texto(plan['objetivo_general'], fallback: 'Sin objetivo')}',
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
                                          color: colorProgreso.withValues(alpha: 0.14),
                                        ),
                                        child: Text(
                                          progreso,
                                          style: TextStyle(
                                            color: colorProgreso,
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