import 'package:flutter/material.dart';

import 'package:advocatus/services/api_services/api_client.dart';
import 'package:advocatus/services/api_services/common_api.dart';

class PantallaExpedienteClinico extends StatefulWidget {
  final int psicologoId;

  const PantallaExpedienteClinico({
    super.key,
    required this.psicologoId,
  });

  @override
  State<PantallaExpedienteClinico> createState() =>
      _PantallaExpedienteClinicoState();
}

class _PantallaExpedienteClinicoState extends State<PantallaExpedienteClinico> {
  final CommonApi api = CommonApi(ApiClient());

  bool cargando = true;
  String mensaje = '';

  List<dynamic> _expedientes = [];
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
        _expedientes = expedientes;
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

  Map<String, dynamic> _clienteDeRelacion(Map<String, dynamic> item) {
    final cliente = item['cliente'];
    if (cliente is Map<String, dynamic>) return cliente;
    return <String, dynamic>{};
  }

  Map<String, dynamic> _clienteDeExpediente(Map<String, dynamic> item) {
    final cliente = item['cliente'];
    if (cliente is Map<String, dynamic>) return cliente;
    return <String, dynamic>{};
  }

  String _nombrePacienteRelacion(Map<String, dynamic> item) {
    final cliente = _clienteDeRelacion(item);
    return (cliente['nombre'] ?? 'Paciente').toString();
  }

  String _nombrePacienteExpediente(Map<String, dynamic> item) {
    final cliente = _clienteDeExpediente(item);
    return (cliente['nombre'] ?? 'Paciente').toString();
  }

  String _correoPacienteExpediente(Map<String, dynamic> item) {
    final cliente = _clienteDeExpediente(item);
    return (cliente['correo'] ?? '—').toString();
  }

  String _telefonoPacienteExpediente(Map<String, dynamic> item) {
    final cliente = _clienteDeExpediente(item);
    return (cliente['telefono'] ?? '—').toString();
  }

  String _estadoExpediente(Map<String, dynamic> item) {
    return (item['estado'] ?? 'Sin estado').toString();
  }

  String _riesgoExpediente(Map<String, dynamic> item) {
    return (item['nivel_riesgo'] ?? 'Sin riesgo').toString();
  }

  String _fechaAperturaExpediente(Map<String, dynamic> item) {
    final value = (item['fecha_apertura'] ?? '').toString().trim();
    if (value.isEmpty) return 'Sin registro';
    return value;
  }

  String _texto(dynamic value, {String fallback = 'Sin información.'}) {
    final txt = (value ?? '').toString().trim();
    return txt.isEmpty ? fallback : txt;
  }

  Future<void> _crearExpediente() async {
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
    String estadoSeleccionado = 'activo';
    String riesgoSeleccionado = 'bajo';

    final motivoCtrl = TextEditingController();
    final antecedentesCtrl = TextEditingController();
    final diagnosticoCtrl = TextEditingController();
    final objetivoGeneralCtrl = TextEditingController();
    final objetivosEspecificosCtrl = TextEditingController();
    final enfoqueCtrl = TextEditingController();
    final planCtrl = TextEditingController();
    final notasCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Nuevo expediente clínico'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: relacionSeleccionadaId,
                    decoration: const InputDecoration(
                      labelText: 'Selecciona paciente',
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
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: motivoCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Motivo de consulta',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: antecedentesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Antecedentes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: diagnosticoCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Diagnóstico inicial',
                      border: OutlineInputBorder(),
                    ),
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
                    controller: planCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Plan de tratamiento',
                      border: OutlineInputBorder(),
                    ),
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
                        value: 'activo',
                        child: Text('Activo'),
                      ),
                      DropdownMenuItem(
                        value: 'seguimiento',
                        child: Text('Seguimiento'),
                      ),
                      DropdownMenuItem(
                        value: 'cerrado',
                        child: Text('Cerrado'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        estadoSeleccionado = value ?? 'activo';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: riesgoSeleccionado,
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
                        riesgoSeleccionado = value ?? 'bajo';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notasCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notas generales',
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
      antecedentesCtrl.dispose();
      diagnosticoCtrl.dispose();
      objetivoGeneralCtrl.dispose();
      objetivosEspecificosCtrl.dispose();
      enfoqueCtrl.dispose();
      planCtrl.dispose();
      notasCtrl.dispose();
      return;
    }

    if (relacionSeleccionadaId == null || clienteIdSeleccionado == null) {
      motivoCtrl.dispose();
      antecedentesCtrl.dispose();
      diagnosticoCtrl.dispose();
      objetivoGeneralCtrl.dispose();
      objetivosEspecificosCtrl.dispose();
      enfoqueCtrl.dispose();
      planCtrl.dispose();
      notasCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un paciente')),
      );
      return;
    }

    try {
      await api.crearExpedientePsicologo(
        psicologoId: widget.psicologoId,
        clienteId: clienteIdSeleccionado!,
        profesionalClienteId: relacionSeleccionadaId,
        motivoConsulta:
            motivoCtrl.text.trim().isEmpty ? null : motivoCtrl.text.trim(),
        antecedentes: antecedentesCtrl.text.trim().isEmpty
            ? null
            : antecedentesCtrl.text.trim(),
        diagnosticoInicial: diagnosticoCtrl.text.trim().isEmpty
            ? null
            : diagnosticoCtrl.text.trim(),
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
        nivelRiesgo: riesgoSeleccionado,
        estado: estadoSeleccionado,
        notasGenerales:
            notasCtrl.text.trim().isEmpty ? null : notasCtrl.text.trim(),
      );

      motivoCtrl.dispose();
      antecedentesCtrl.dispose();
      diagnosticoCtrl.dispose();
      objetivoGeneralCtrl.dispose();
      objetivosEspecificosCtrl.dispose();
      enfoqueCtrl.dispose();
      planCtrl.dispose();
      notasCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expediente registrado')),
      );

      await _cargarTodo();
    } catch (e) {
      motivoCtrl.dispose();
      antecedentesCtrl.dispose();
      diagnosticoCtrl.dispose();
      objetivoGeneralCtrl.dispose();
      objetivosEspecificosCtrl.dispose();
      enfoqueCtrl.dispose();
      planCtrl.dispose();
      notasCtrl.dispose();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _mostrarDetalle(Map<String, dynamic> expediente) {
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
                    _nombrePacienteExpediente(expediente),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _datoDetalle('Correo', _correoPacienteExpediente(expediente)),
                  _datoDetalle(
                    'Teléfono',
                    _telefonoPacienteExpediente(expediente),
                  ),
                  _datoDetalle(
                    'Estado',
                    _estadoExpediente(expediente),
                  ),
                  _datoDetalle(
                    'Riesgo',
                    _riesgoExpediente(expediente),
                  ),
                  _datoDetalle(
                    'Fecha apertura',
                    _fechaAperturaExpediente(expediente),
                  ),
                  const SizedBox(height: 12),
                  _bloqueTexto(
                    titulo: 'Motivo de consulta',
                    contenido: _texto(expediente['motivo_consulta']),
                  ),
                  _bloqueTexto(
                    titulo: 'Antecedentes',
                    contenido: _texto(expediente['antecedentes']),
                  ),
                  _bloqueTexto(
                    titulo: 'Diagnóstico inicial',
                    contenido: _texto(expediente['diagnostico_inicial']),
                  ),
                  _bloqueTexto(
                    titulo: 'Objetivo general',
                    contenido: _texto(expediente['objetivo_general']),
                  ),
                  _bloqueTexto(
                    titulo: 'Objetivos específicos',
                    contenido: _texto(expediente['objetivos_especificos']),
                  ),
                  _bloqueTexto(
                    titulo: 'Enfoque terapéutico',
                    contenido: _texto(expediente['enfoque_terapeutico']),
                  ),
                  _bloqueTexto(
                    titulo: 'Plan de tratamiento',
                    contenido: _texto(expediente['plan_tratamiento']),
                  ),
                  _bloqueTexto(
                    titulo: 'Notas generales',
                    contenido: _texto(expediente['notas_generales']),
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
    final activos = _expedientes
        .where(
          (e) =>
              _estadoExpediente(Map<String, dynamic>.from(e)).toLowerCase() ==
              'activo',
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expediente clínico'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _cargarTodo,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Nuevo expediente',
            onPressed: _crearExpediente,
            icon: const Icon(Icons.post_add),
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
                                  Icons.folder_shared_outlined,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_saludoPorHora()}, expediente clínico',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Antecedentes, diagnóstico, plan y evolución terapéutica.',
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
                                icon: Icons.folder_open_outlined,
                                titulo: 'Total',
                                valor: '${_expedientes.length}',
                                accent: accent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _resumenCard(
                                icon: Icons.health_and_safety_outlined,
                                titulo: 'Activos',
                                valor: '$activos',
                                accent: accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: _crearExpediente,
                          icon: const Icon(Icons.add),
                          label: const Text('Crear expediente'),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Expedientes registrados',
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
                        else if (_expedientes.isEmpty)
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
                                  ? 'No hay expedientes clínicos registrados todavía.'
                                  : mensaje,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.80),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ..._expedientes.map((item) {
                            final expediente = Map<String, dynamic>.from(item);
                            final estado = _estadoExpediente(expediente);
                            final riesgo = _riesgoExpediente(expediente);
                            final colorEstado = _colorEstado(estado);
                            final colorRiesgo = _colorRiesgo(riesgo);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _mostrarDetalle(expediente),
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
                                          Icons.folder_shared_outlined,
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
                                              _nombrePacienteExpediente(expediente),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Diagnóstico: ${_texto(expediente['diagnostico_inicial'], fallback: 'Sin diagnóstico')}',
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
                                                        BorderRadius.circular(999),
                                                    color: colorEstado.withValues(
                                                      alpha: 0.14,
                                                    ),
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
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(999),
                                                    color: colorRiesgo.withValues(
                                                      alpha: 0.14,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Riesgo $riesgo',
                                                    style: TextStyle(
                                                      color: colorRiesgo,
                                                      fontWeight: FontWeight.w800,
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