import 'package:flutter/material.dart';

import 'package:advocatus/services/api_services/api_client.dart';
import 'package:advocatus/services/api_services/common_api.dart';

class PantallaReportesPsicologicos extends StatefulWidget {
  final int psicologoId;

  const PantallaReportesPsicologicos({
    super.key,
    required this.psicologoId,
  });

  @override
  State<PantallaReportesPsicologicos> createState() =>
      _PantallaReportesPsicologicosState();
}

class _PantallaReportesPsicologicosState
    extends State<PantallaReportesPsicologicos> {
  final CommonApi api = CommonApi(ApiClient());

  bool cargando = true;
  String mensaje = '';

  List<dynamic> _reportes = [];
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
      final reportes = await api.getReportesPsicologo(
        psicologoId: widget.psicologoId,
      );
      final pacientes = await api.getPacientesPsicologo(widget.psicologoId);
      final expedientes = await api.getExpedientesPsicologo(widget.psicologoId);

      if (!mounted) return;

      setState(() {
        _reportes = reportes;
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
      case 'emitido':
        return Colors.green;
      case 'borrador':
        return Colors.orange;
      case 'cancelado':
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

  Map<String, dynamic> _clienteDeReporte(Map<String, dynamic> item) {
    final cliente = item['cliente'];
    if (cliente is Map<String, dynamic>) return cliente;
    return <String, dynamic>{};
  }

  String _nombrePacienteRelacion(Map<String, dynamic> item) {
    final cliente = _clienteDeRelacion(item);
    return (cliente['nombre'] ?? 'Paciente').toString();
  }

  String _nombrePacienteReporte(Map<String, dynamic> item) {
    final cliente = _clienteDeReporte(item);
    return (cliente['nombre'] ?? 'Paciente').toString();
  }

  String _correoPacienteReporte(Map<String, dynamic> item) {
    final cliente = _clienteDeReporte(item);
    return (cliente['correo'] ?? '—').toString();
  }

  String _telefonoPacienteReporte(Map<String, dynamic> item) {
    final cliente = _clienteDeReporte(item);
    return (cliente['telefono'] ?? '—').toString();
  }

  String _fechaReporte(Map<String, dynamic> item) {
    final value = (item['fecha_reporte'] ?? item['fecha'] ?? '').toString().trim();
    if (value.isEmpty) return 'Sin registro';
    return value;
  }

  String _tipoReporteBonito(String value) {
    switch (value) {
      case 'reporte_evolucion':
        return 'Reporte de evolución';
      case 'constancia_atencion':
        return 'Constancia de atención';
      case 'informe_psicologico':
        return 'Informe psicológico';
      case 'canalizacion':
        return 'Canalización';
      default:
        return value;
    }
  }

  String _tipoReporteApiDesdeUi(String value) {
    switch (value) {
      case 'Reporte de evolución':
        return 'reporte_evolucion';
      case 'Constancia de atención':
        return 'constancia_atencion';
      case 'Informe psicológico':
        return 'informe_psicologico';
      case 'Canalización':
        return 'canalizacion';
      default:
        return 'reporte_evolucion';
    }
  }

  List<Map<String, dynamic>> _expedientesDeCliente(int clienteId) {
    return _expedientes
        .map((e) => Map<String, dynamic>.from(e))
        .where((e) => _toInt(e['cliente_id']) == clienteId)
        .toList();
  }

  Future<void> _crearReporte() async {
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

    final motivoCtrl = TextEditingController();
    final conclusionesCtrl = TextEditingController();
    final recomendacionesCtrl = TextEditingController();
    final observacionesCtrl = TextEditingController();

    String tipoReporte = 'Reporte de evolución';
    String estado = 'borrador';
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
            title: const Text('Nuevo reporte psicológico'),
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
                    initialValue: tipoReporte,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de reporte',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Reporte de evolución',
                        child: Text('Reporte de evolución'),
                      ),
                      DropdownMenuItem(
                        value: 'Constancia de atención',
                        child: Text('Constancia de atención'),
                      ),
                      DropdownMenuItem(
                        value: 'Informe psicológico',
                        child: Text('Informe psicológico'),
                      ),
                      DropdownMenuItem(
                        value: 'Canalización',
                        child: Text('Canalización'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        tipoReporte = value ?? 'Reporte de evolución';
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
                    initialValue: estado,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'borrador',
                        child: Text('Borrador'),
                      ),
                      DropdownMenuItem(
                        value: 'emitido',
                        child: Text('Emitido'),
                      ),
                      DropdownMenuItem(
                        value: 'cancelado',
                        child: Text('Cancelado'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        estado = value ?? 'borrador';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: motivoCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Motivo del reporte',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: conclusionesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Conclusiones',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: recomendacionesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Recomendaciones',
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
      motivoCtrl.dispose();
      conclusionesCtrl.dispose();
      recomendacionesCtrl.dispose();
      observacionesCtrl.dispose();
      return;
    }

    if (clienteIdSeleccionado == null || expedienteIdSeleccionado == null) {
      motivoCtrl.dispose();
      conclusionesCtrl.dispose();
      recomendacionesCtrl.dispose();
      observacionesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona paciente y expediente')),
      );
      return;
    }

    try {
      await api.crearReportePsicologo(
        psicologoId: widget.psicologoId,
        clienteId: clienteIdSeleccionado!,
        expedienteId: expedienteIdSeleccionado!,
        profesionalClienteId: relacionSeleccionadaId,
        tipoReporte: _tipoReporteApiDesdeUi(tipoReporte),
        fechaReporte:
            '${fechaSeleccionada.year}-${fechaSeleccionada.month.toString().padLeft(2, '0')}-${fechaSeleccionada.day.toString().padLeft(2, '0')} '
            '${fechaSeleccionada.hour.toString().padLeft(2, '0')}:${fechaSeleccionada.minute.toString().padLeft(2, '0')}:00',
        estado: estado,
        motivo: motivoCtrl.text.trim().isEmpty ? null : motivoCtrl.text.trim(),
        conclusiones: conclusionesCtrl.text.trim().isEmpty
            ? null
            : conclusionesCtrl.text.trim(),
        recomendaciones: recomendacionesCtrl.text.trim().isEmpty
            ? null
            : recomendacionesCtrl.text.trim(),
        observaciones: observacionesCtrl.text.trim().isEmpty
            ? null
            : observacionesCtrl.text.trim(),
      );

      motivoCtrl.dispose();
      conclusionesCtrl.dispose();
      recomendacionesCtrl.dispose();
      observacionesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte psicológico registrado')),
      );

      await _cargarTodo();
    } catch (e) {
      motivoCtrl.dispose();
      conclusionesCtrl.dispose();
      recomendacionesCtrl.dispose();
      observacionesCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _mostrarDetalle(Map<String, dynamic> reporte) {
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
                    _nombrePacienteReporte(reporte),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _datoDetalle(
                    'Tipo',
                    _tipoReporteBonito(
                      (reporte['tipo_reporte'] ?? '').toString(),
                    ),
                  ),
                  _datoDetalle('Correo', _correoPacienteReporte(reporte)),
                  _datoDetalle('Teléfono', _telefonoPacienteReporte(reporte)),
                  _datoDetalle('Fecha', _fechaReporte(reporte)),
                  _datoDetalle(
                    'Estado',
                    _texto(reporte['estado'], fallback: '—'),
                  ),
                  const SizedBox(height: 12),
                  _bloqueTexto(
                    titulo: 'Motivo del reporte',
                    contenido: _texto(reporte['motivo']),
                  ),
                  _bloqueTexto(
                    titulo: 'Conclusiones',
                    contenido: _texto(reporte['conclusiones']),
                  ),
                  _bloqueTexto(
                    titulo: 'Recomendaciones',
                    contenido: _texto(reporte['recomendaciones']),
                  ),
                  _bloqueTexto(
                    titulo: 'Observaciones',
                    contenido: _texto(reporte['observaciones']),
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
    final emitidos = _reportes
        .where(
          (r) => (r['estado'] ?? '').toString().toLowerCase() == 'emitido',
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes psicológicos'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _cargarTodo,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Nuevo reporte',
            onPressed: _crearReporte,
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
                                  Icons.description_outlined,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_saludoPorHora()}, reportes psicológicos',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Constancias, informes y reportes clínicos.',
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
                                icon: Icons.article_outlined,
                                titulo: 'Total',
                                valor: '${_reportes.length}',
                                accent: accent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _resumenCard(
                                icon: Icons.check_circle_outline,
                                titulo: 'Emitidos',
                                valor: '$emitidos',
                                accent: accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: _crearReporte,
                          icon: const Icon(Icons.add),
                          label: const Text('Crear reporte psicológico'),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Reportes registrados',
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
                        else if (_reportes.isEmpty)
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
                                  ? 'No hay reportes psicológicos registrados todavía.'
                                  : mensaje,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.80),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ..._reportes.map((item) {
                            final reporte = Map<String, dynamic>.from(item);
                            final estado =
                                (reporte['estado'] ?? 'Sin estado').toString();
                            final colorEstado = _colorEstado(estado);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _mostrarDetalle(reporte),
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
                                          Icons.description_outlined,
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
                                              _nombrePacienteReporte(reporte),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_tipoReporteBonito((reporte['tipo_reporte'] ?? '').toString())} • ${_fechaReporte(reporte)}',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.72,
                                                ),
                                                fontSize: 12.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Motivo: ${_texto(reporte['motivo'], fallback: 'Sin motivo')}',
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
                                          _texto(estado, fallback: '—'),
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