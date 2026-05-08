import 'package:flutter/material.dart';

import '../../../../services/api_services/ajustador_api.dart';

class DictamenPreliminarScreen extends StatefulWidget {
  const DictamenPreliminarScreen({super.key});

  @override
  State<DictamenPreliminarScreen> createState() =>
      _DictamenPreliminarScreenState();
}

class _DictamenPreliminarScreenState extends State<DictamenPreliminarScreen> {
  final AjustadorApi api = AjustadorApi();

  late Future<List<SiniestroParte>> futureDictamenes;
  late Future<List<Siniestro>> futureSiniestros;

  @override
  void initState() {
    super.initState();
    futureDictamenes = api.getDictamenes();
    futureSiniestros = api.getSiniestros();
  }

  Future<void> _recargarDictamenes() async {
    setState(() {
      futureDictamenes = api.getDictamenes();
      futureSiniestros = api.getSiniestros();
    });
  }

  String _saludoPorHora() {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) return 'Buenos días';
    if (hora >= 12 && hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')} '
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}:00';
  }

  String _normalizarEstado(String? estado) {
    final e = estado?.trim().toLowerCase();

    switch (e) {
      case 'emitido':
        return 'Emitido';
      case 'en_revision':
      case 'en revisión':
      case 'revision':
        return 'En revisión';
      case 'cerrado':
      case 'finalizado':
        return 'Cerrado';
      default:
        return estado?.trim().isNotEmpty == true
            ? estado!.trim()
            : 'En revisión';
    }
  }

  String _normalizarResultado(String? resultado) {
    final r = resultado?.trim().toLowerCase();

    switch (r) {
      case 'procedente':
        return 'Procedente';
      case 'improcedente':
        return 'Improcedente';
      case 'pendiente':
        return 'Pendiente';
      default:
        return resultado?.trim().isNotEmpty == true
            ? resultado!.trim()
            : 'Pendiente';
    }
  }

  String _valorApiEstado(String estado) {
    final e = estado.trim().toLowerCase();

    if (e == 'en revisión') return 'en_revision';
    if (e == 'emitido') return 'emitido';
    if (e == 'cerrado') return 'cerrado';

    return e;
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'emitido':
        return Colors.green;
      case 'en revisión':
      case 'en_revision':
        return Colors.orange;
      case 'cerrado':
      case 'finalizado':
        return Colors.blueGrey;
      default:
        return Colors.blueGrey;
    }
  }

  Color _colorResultado(String resultado) {
    switch (resultado.toLowerCase()) {
      case 'procedente':
        return Colors.green;
      case 'improcedente':
        return Colors.red;
      case 'pendiente':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  String _textoContenido(
    SiniestroParte item,
    String key, {
    String fallback = '—',
  }) {
    final value = item.contenidoJson[key];

    if (value == null) return fallback;

    final text = value.toString().trim();

    return text.isNotEmpty ? text : fallback;
  }

  Future<void> _crearDictamen() async {
    final observacionesCtrl = TextEditingController();
    final conclusionCtrl = TextEditingController();

    String resultado = 'Pendiente';
    String tipoResolucion = 'En análisis';
    String responsabilidad = 'Pendiente';
    String estado = 'En revisión';
    DateTime fechaSeleccionada = DateTime.now();
    int? siniestroSeleccionadoId;

    final siniestros = await futureSiniestros.catchError((_) {
      return <Siniestro>[];
    });

    if (!mounted) return;

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
            title: const Text('Nuevo dictamen preliminar'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: siniestroSeleccionadoId,
                    decoration: const InputDecoration(
                      labelText: 'Siniestro',
                      border: OutlineInputBorder(),
                    ),
                    items: siniestros.map((siniestro) {
                      return DropdownMenuItem<int>(
                        value: siniestro.id,
                        child: Text(
                          '${siniestro.folio} - ${siniestro.tipo}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        siniestroSeleccionadoId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: seleccionarFecha,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_formatearFecha(fechaSeleccionada)),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: resultado,
                    decoration: const InputDecoration(
                      labelText: 'Resultado',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Procedente',
                        child: Text('Procedente'),
                      ),
                      DropdownMenuItem(
                        value: 'Improcedente',
                        child: Text('Improcedente'),
                      ),
                      DropdownMenuItem(
                        value: 'Pendiente',
                        child: Text('Pendiente'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        resultado = value ?? 'Pendiente';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: tipoResolucion,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de resolución',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Parcial',
                        child: Text('Parcial'),
                      ),
                      DropdownMenuItem(
                        value: 'Total',
                        child: Text('Total'),
                      ),
                      DropdownMenuItem(
                        value: 'En análisis',
                        child: Text('En análisis'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        tipoResolucion = value ?? 'En análisis';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: responsabilidad,
                    decoration: const InputDecoration(
                      labelText: 'Responsabilidad probable',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Pendiente',
                        child: Text('Pendiente'),
                      ),
                      DropdownMenuItem(
                        value: 'A cargo del tercero',
                        child: Text('A cargo del tercero'),
                      ),
                      DropdownMenuItem(
                        value: 'A cargo del asegurado',
                        child: Text('A cargo del asegurado'),
                      ),
                      DropdownMenuItem(
                        value: 'Probable compartida',
                        child: Text('Probable compartida'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        responsabilidad = value ?? 'Pendiente';
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
                        value: 'Emitido',
                        child: Text('Emitido'),
                      ),
                      DropdownMenuItem(
                        value: 'En revisión',
                        child: Text('En revisión'),
                      ),
                      DropdownMenuItem(
                        value: 'Cerrado',
                        child: Text('Cerrado'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        estado = value ?? 'En revisión';
                      });
                    },
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
                  TextField(
                    controller: conclusionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Conclusión',
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
      observacionesCtrl.dispose();
      conclusionCtrl.dispose();
      return;
    }

    final observaciones = observacionesCtrl.text.trim();
    final conclusion = conclusionCtrl.text.trim();

    observacionesCtrl.dispose();
    conclusionCtrl.dispose();

    if (siniestroSeleccionadoId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un siniestro'),
        ),
      );
      return;
    }

    try {
      final ajustadorId = await api.obtenerAjustadorIdGuardado();

      await api.crearParte(
        siniestroId: siniestroSeleccionadoId!,
        tipo: 'dictamen',
        titulo: 'Dictamen preliminar',
        estado: _valorApiEstado(estado),
        fechaEvento: _formatearFecha(fechaSeleccionada),
        createdBy: ajustadorId,
        contenidoJson: {
          'resultado': resultado,
          'tipo_resolucion': tipoResolucion,
          'responsabilidad': responsabilidad,
          'observaciones': observaciones,
          'conclusion': conclusion,
          'estado': _valorApiEstado(estado),
        },
      );

      await _recargarDictamenes();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dictamen preliminar registrado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar dictamen: $e')),
      );
    }
  }

  Future<void> _eliminarDictamen(SiniestroParte item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar dictamen'),
        content: Text(
          '¿Seguro que deseas eliminar "${item.titulo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await api.eliminarParte(item.id);
      await _recargarDictamenes();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dictamen eliminado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar dictamen: $e')),
      );
    }
  }

  void _mostrarDetalle(SiniestroParte item) {
    final estado = _normalizarEstado(
      item.contenidoJson['estado']?.toString() ?? item.estado,
    );

    final resultado = _normalizarResultado(
      item.contenidoJson['resultado']?.toString(),
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
                    item.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _datoDetalle(
                    'ID dictamen',
                    item.id.toString(),
                  ),
                  _datoDetalle(
                    'ID siniestro',
                    item.siniestroId?.toString() ?? '—',
                  ),
                  _datoDetalle(
                    'Resultado',
                    resultado,
                  ),
                  _datoDetalle(
                    'Resolución',
                    _textoContenido(item, 'tipo_resolucion'),
                  ),
                  _datoDetalle(
                    'Fecha',
                    item.fechaEvento ?? '—',
                  ),
                  _datoDetalle(
                    'Responsabilidad',
                    _textoContenido(item, 'responsabilidad'),
                  ),
                  _datoDetalle(
                    'Estado',
                    estado,
                  ),
                  const SizedBox(height: 12),
                  _bloqueTexto(
                    titulo: 'Observaciones',
                    contenido: _textoContenido(
                      item,
                      'observaciones',
                      fallback: '',
                    ),
                  ),
                  _bloqueTexto(
                    titulo: 'Conclusión',
                    contenido: _textoContenido(
                      item,
                      'conclusion',
                      fallback: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _eliminarDictamen(item);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar dictamen'),
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
              contenido.trim().isNotEmpty ? contenido : 'Sin información.',
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

  Widget _emptyState(Color accent) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.gavel_outlined,
            color: accent,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            'No hay dictámenes registrados todavía.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando registres un dictamen preliminar aparecerá aquí.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 12.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _errorState(Object error, Color accent) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.red.withValues(alpha: 0.08),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: 36,
          ),
          const SizedBox(height: 10),
          const Text(
            'No se pudieron cargar los dictámenes.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _recargarDictamenes,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _listaDictamenes(List<SiniestroParte> dictamenes, Color accent) {
    if (dictamenes.isEmpty) {
      return _emptyState(accent);
    }

    return Column(
      children: dictamenes.map((item) {
        final estado = _normalizarEstado(
          item.contenidoJson['estado']?.toString() ?? item.estado,
        );

        final resultado = _normalizarResultado(
          item.contenidoJson['resultado']?.toString(),
        );

        final tipoResolucion = _textoContenido(item, 'tipo_resolucion');

        final colorEstado = _colorEstado(estado);
        final colorResultado = _colorResultado(resultado);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _mostrarDetalle(item),
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
                      Icons.gavel_outlined,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Resolución: $tipoResolucion',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 12.5,
                          ),
                        ),
                        if (item.siniestroId != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Siniestro ID: ${item.siniestroId}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.58),
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: colorResultado.withValues(alpha: 0.14),
                              ),
                              child: Text(
                                resultado,
                                style: TextStyle(
                                  color: colorResultado,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
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
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictamen preliminar'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _recargarDictamenes,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Nuevo dictamen',
            onPressed: _crearDictamen,
            icon: const Icon(Icons.gavel_outlined),
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
            child: RefreshIndicator(
              onRefresh: _recargarDictamenes,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                      child: FutureBuilder<List<SiniestroParte>>(
                        future: futureDictamenes,
                        builder: (context, snapshot) {
                          final dictamenes = snapshot.data ?? [];

                          final emitidos = dictamenes.where((item) {
                            final estado = _normalizarEstado(
                              item.contenidoJson['estado']?.toString() ??
                                  item.estado,
                            );
                            return estado == 'Emitido';
                          }).length;

                          return Column(
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
                                        Icons.gavel_outlined,
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
                                            '${_saludoPorHora()}, dictamen preliminar',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Resolución inicial, observaciones y conclusión técnica.',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.72,
                                              ),
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
                                      icon: Icons.assignment_turned_in_outlined,
                                      titulo: 'Total',
                                      valor: '${dictamenes.length}',
                                      accent: accent,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _resumenCard(
                                      icon: Icons.verified_outlined,
                                      titulo: 'Emitidos',
                                      valor: '$emitidos',
                                      accent: accent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: _crearDictamen,
                                icon: const Icon(Icons.add),
                                label: const Text('Registrar dictamen'),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Dictámenes registrados',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 22),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: accent,
                                    ),
                                  ),
                                )
                              else if (snapshot.hasError)
                                _errorState(snapshot.error!, accent)
                              else
                                _listaDictamenes(dictamenes, accent),
                            ],
                          );
                        },
                      ),
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