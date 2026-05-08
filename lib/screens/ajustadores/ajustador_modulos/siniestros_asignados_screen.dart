import 'package:flutter/material.dart';

import '../../../../services/api_services/ajustador_api.dart';

class SiniestrosAsignadosScreen extends StatefulWidget {
  const SiniestrosAsignadosScreen({super.key});

  @override
  State<SiniestrosAsignadosScreen> createState() =>
      _SiniestrosAsignadosScreenState();
}

class _SiniestrosAsignadosScreenState extends State<SiniestrosAsignadosScreen> {
  final AjustadorApi api = AjustadorApi();

  late Future<List<Siniestro>> futureSiniestros;

  @override
  void initState() {
    super.initState();
    futureSiniestros = api.getSiniestros();
  }

  Future<void> _recargarSiniestros() async {
    setState(() {
      futureSiniestros = api.getSiniestros();
    });
  }

  String _saludoPorHora() {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) return 'Buenos días';
    if (hora >= 12 && hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _normalizarPrioridad(String? prioridad) {
    final p = prioridad?.trim().toLowerCase();

    switch (p) {
      case 'alta':
        return 'Alta';
      case 'media':
        return 'Media';
      case 'baja':
        return 'Baja';
      default:
        return 'Media';
    }
  }

  String _normalizarEstado(String? estado) {
    final e = estado?.trim().toLowerCase();

    switch (e) {
      case 'asignado':
        return 'Asignado';
      case 'en_revision':
      case 'en revisión':
      case 'revision':
        return 'En revisión';
      case 'cerrado':
      case 'finalizado':
        return 'Cerrado';
      default:
        return estado?.trim().isNotEmpty == true ? estado!.trim() : 'Asignado';
    }
  }

  String _valorApiPrioridad(String prioridad) {
    return prioridad.trim().toLowerCase();
  }

  String _valorApiEstado(String estado) {
    final e = estado.trim().toLowerCase();

    if (e == 'en revisión') {
      return 'en_revision';
    }

    return e;
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')} '
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}:00';
  }

  Color _colorPrioridad(String prioridad) {
    switch (prioridad.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'asignado':
        return Colors.blue;
      case 'en revisión':
      case 'en_revision':
        return Colors.orange;
      case 'cerrado':
      case 'finalizado':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _crearSiniestro() async {
    final folioCtrl = TextEditingController();
    final aseguradoCtrl = TextEditingController();
    final tipoCtrl = TextEditingController();
    final ubicacionCtrl = TextEditingController();
    final descripcionCtrl = TextEditingController();

    String prioridad = 'Media';
    String estado = 'Asignado';
    DateTime fechaSeleccionada = DateTime.now();

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
            title: const Text('Nuevo siniestro'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: folioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Folio',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: aseguradoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Asegurado / referencia',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tipoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de siniestro',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ubicacionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: seleccionarFecha,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_formatearFecha(fechaSeleccionada)),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: prioridad,
                    decoration: const InputDecoration(
                      labelText: 'Prioridad',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                      DropdownMenuItem(value: 'Media', child: Text('Media')),
                      DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        prioridad = value ?? 'Media';
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
                        value: 'Asignado',
                        child: Text('Asignado'),
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
                        estado = value ?? 'Asignado';
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
      folioCtrl.dispose();
      aseguradoCtrl.dispose();
      tipoCtrl.dispose();
      ubicacionCtrl.dispose();
      descripcionCtrl.dispose();
      return;
    }

    final folio = folioCtrl.text.trim();
    final asegurado = aseguradoCtrl.text.trim();
    final tipo = tipoCtrl.text.trim();
    final ubicacion = ubicacionCtrl.text.trim();
    final descripcion = descripcionCtrl.text.trim();

    folioCtrl.dispose();
    aseguradoCtrl.dispose();
    tipoCtrl.dispose();
    ubicacionCtrl.dispose();
    descripcionCtrl.dispose();

    if (folio.isEmpty || asegurado.isEmpty || tipo.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe mínimo folio, asegurado y tipo de siniestro'),
        ),
      );
      return;
    }

    try {
      final ajustadorId = await api.obtenerAjustadorIdGuardado();

      if (ajustadorId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró el ID del ajustador en la sesión'),
          ),
        );
        return;
      }

      await api.crearSiniestro(
        ajustadorId: ajustadorId,
        folio: folio,
        tipo: tipo,
        ubicacion: ubicacion,
        fechaSiniestro: _formatearFecha(fechaSeleccionada),
        prioridad: _valorApiPrioridad(prioridad),
        estado: _valorApiEstado(estado),
        descripcion: descripcion,
        referenciaExterna: asegurado,
      );

      await _recargarSiniestros();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Siniestro registrado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar siniestro: $e')),
      );
    }
  }

  void _mostrarDetalle(Siniestro siniestro) {
    final prioridad = _normalizarPrioridad(siniestro.prioridad);
    final estado = _normalizarEstado(siniestro.estado);

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
                    siniestro.folio,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _datoDetalle(
                    'Asegurado',
                    siniestro.referenciaExterna ?? '—',
                  ),
                  _datoDetalle(
                    'Tipo',
                    siniestro.tipo,
                  ),
                  _datoDetalle(
                    'Ubicación',
                    siniestro.ubicacion ?? '—',
                  ),
                  _datoDetalle(
                    'Fecha',
                    siniestro.fechaSiniestro ?? '—',
                  ),
                  _datoDetalle(
                    'Prioridad',
                    prioridad,
                  ),
                  _datoDetalle(
                    'Estado',
                    estado,
                  ),
                  const SizedBox(height: 12),
                  _bloqueTexto(
                    titulo: 'Descripción',
                    contenido: siniestro.descripcion ?? '',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _cambiarEstado(siniestro, 'en_revision');
                          },
                          icon: const Icon(Icons.fact_check_outlined),
                          label: const Text('En revisión'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _cambiarEstado(siniestro, 'cerrado');
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Cerrar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _cambiarEstado(Siniestro siniestro, String nuevoEstado) async {
    try {
      await api.cambiarEstadoSiniestro(
        id: siniestro.id,
        estado: nuevoEstado,
      );

      await _recargarSiniestros();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado actualizado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar estado: $e')),
      );
    }
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
            Icons.assignment_late_outlined,
            color: accent,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            'No hay siniestros registrados todavía.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando registres o te asignen siniestros aparecerán aquí.',
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
            'No se pudieron cargar los siniestros.',
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
            onPressed: _recargarSiniestros,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _listaSiniestros(List<Siniestro> siniestros, Color accent) {
    if (siniestros.isEmpty) {
      return _emptyState(accent);
    }

    return Column(
      children: siniestros.map((siniestro) {
        final prioridad = _normalizarPrioridad(siniestro.prioridad);
        final estado = _normalizarEstado(siniestro.estado);
        final colorPrioridad = _colorPrioridad(prioridad);
        final colorEstado = _colorEstado(estado);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _mostrarDetalle(siniestro),
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
                      Icons.assignment_late_outlined,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          siniestro.folio,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${siniestro.referenciaExterna ?? 'Asegurado'} • ${siniestro.tipo}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 12.5,
                          ),
                        ),
                        if (siniestro.ubicacion != null &&
                            siniestro.ubicacion!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            siniestro.ubicacion!,
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
                                color: colorPrioridad.withValues(alpha: 0.14),
                              ),
                              child: Text(
                                prioridad,
                                style: TextStyle(
                                  color: colorPrioridad,
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
        title: const Text('Siniestros asignados'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _recargarSiniestros,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Nuevo siniestro',
            onPressed: _crearSiniestro,
            icon: const Icon(Icons.add_alert_outlined),
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
              onRefresh: _recargarSiniestros,
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
                      child: FutureBuilder<List<Siniestro>>(
                        future: futureSiniestros,
                        builder: (context, snapshot) {
                          final siniestros = snapshot.data ?? [];
                          final altos = siniestros
                              .where(
                                (s) =>
                                    _normalizarPrioridad(s.prioridad) == 'Alta',
                              )
                              .length;

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
                                          color:
                                              accent.withValues(alpha: 0.20),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.assignment_late_outlined,
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
                                            '${_saludoPorHora()}, siniestros asignados',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Control inicial de reportes, prioridad y estado.',
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
                                      icon: Icons.list_alt_outlined,
                                      titulo: 'Total',
                                      valor: '${siniestros.length}',
                                      accent: accent,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _resumenCard(
                                      icon: Icons.priority_high_outlined,
                                      titulo: 'Alta prioridad',
                                      valor: '$altos',
                                      accent: accent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: _crearSiniestro,
                                icon: const Icon(Icons.add),
                                label: const Text('Registrar siniestro'),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Siniestros registrados',
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
                                _listaSiniestros(siniestros, accent),
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