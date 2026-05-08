import 'package:flutter/material.dart';

import '../../../../services/api_services/ajustador_api.dart';

class SeguimientoSiniestroScreen extends StatefulWidget {
  const SeguimientoSiniestroScreen({super.key});

  @override
  State<SeguimientoSiniestroScreen> createState() =>
      _SeguimientoSiniestroScreenState();
}

class _SeguimientoSiniestroScreenState
    extends State<SeguimientoSiniestroScreen> {
  final AjustadorApi api = AjustadorApi();

  late Future<List<SiniestroParte>> futureSeguimientos;
  late Future<List<Siniestro>> futureSiniestros;

  @override
  void initState() {
    super.initState();
    futureSeguimientos = api.getSeguimientos();
    futureSiniestros = api.getSiniestros();
  }

  Future<void> _recargarSeguimientos() async {
    setState(() {
      futureSeguimientos = api.getSeguimientos();
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

  String _normalizarEstatus(String? estatus) {
    final e = estatus?.trim().toLowerCase();

    switch (e) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_proceso':
      case 'en proceso':
      case 'proceso':
        return 'En proceso';
      case 'cerrado':
      case 'finalizado':
        return 'Cerrado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estatus?.trim().isNotEmpty == true ? estatus!.trim() : 'Pendiente';
    }
  }

  String _valorApiEstatus(String estatus) {
    final e = estatus.trim().toLowerCase();

    if (e == 'en proceso') return 'en_proceso';

    return e;
  }

  Color _colorEstatus(String estatus) {
    switch (estatus.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
      case 'en_proceso':
        return Colors.blue;
      case 'cerrado':
      case 'finalizado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  String _textoContenido(SiniestroParte item, String key, {String fallback = '—'}) {
    final value = item.contenidoJson[key];

    if (value == null) return fallback;

    final text = value.toString().trim();

    return text.isNotEmpty ? text : fallback;
  }

  Future<void> _crearSeguimiento() async {
    final etapaCtrl = TextEditingController();
    final responsableCtrl = TextEditingController();
    final proximoPasoCtrl = TextEditingController();
    final comentariosCtrl = TextEditingController();

    String estatus = 'Pendiente';
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
            title: const Text('Nuevo seguimiento'),
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
                  TextField(
                    controller: etapaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Etapa actual',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: estatus,
                    decoration: const InputDecoration(
                      labelText: 'Estatus',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Pendiente',
                        child: Text('Pendiente'),
                      ),
                      DropdownMenuItem(
                        value: 'En proceso',
                        child: Text('En proceso'),
                      ),
                      DropdownMenuItem(
                        value: 'Cerrado',
                        child: Text('Cerrado'),
                      ),
                      DropdownMenuItem(
                        value: 'Cancelado',
                        child: Text('Cancelado'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        estatus = value ?? 'Pendiente';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: responsableCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Responsable',
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
                  TextField(
                    controller: proximoPasoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Próximo paso',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: comentariosCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Comentarios',
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
      etapaCtrl.dispose();
      responsableCtrl.dispose();
      proximoPasoCtrl.dispose();
      comentariosCtrl.dispose();
      return;
    }

    final etapa = etapaCtrl.text.trim();
    final responsable = responsableCtrl.text.trim();
    final proximoPaso = proximoPasoCtrl.text.trim();
    final comentarios = comentariosCtrl.text.trim();

    etapaCtrl.dispose();
    responsableCtrl.dispose();
    proximoPasoCtrl.dispose();
    comentariosCtrl.dispose();

    if (siniestroSeleccionadoId == null || etapa.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un siniestro y escribe la etapa actual'),
        ),
      );
      return;
    }

    try {
      final ajustadorId = await api.obtenerAjustadorIdGuardado();

      await api.crearParte(
        siniestroId: siniestroSeleccionadoId!,
        tipo: 'seguimiento',
        titulo: etapa,
        estado: _valorApiEstatus(estatus),
        fechaEvento: _formatearFecha(fechaSeleccionada),
        createdBy: ajustadorId,
        contenidoJson: {
          'etapa': etapa,
          'estatus': _valorApiEstatus(estatus),
          'responsable': responsable,
          'proximo_paso': proximoPaso,
          'comentarios': comentarios,
        },
      );

      await _recargarSeguimientos();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seguimiento registrado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar seguimiento: $e')),
      );
    }
  }

  Future<void> _eliminarSeguimiento(SiniestroParte item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar seguimiento'),
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
      await _recargarSeguimientos();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seguimiento eliminado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar seguimiento: $e')),
      );
    }
  }

  void _mostrarDetalle(SiniestroParte item) {
    final estatus = _normalizarEstatus(
      item.contenidoJson['estatus']?.toString() ?? item.estado,
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
                    'ID seguimiento',
                    item.id.toString(),
                  ),
                  _datoDetalle(
                    'ID siniestro',
                    item.siniestroId?.toString() ?? '—',
                  ),
                  _datoDetalle(
                    'Etapa',
                    _textoContenido(item, 'etapa', fallback: item.titulo),
                  ),
                  _datoDetalle(
                    'Estatus',
                    estatus,
                  ),
                  _datoDetalle(
                    'Responsable',
                    _textoContenido(item, 'responsable'),
                  ),
                  _datoDetalle(
                    'Fecha',
                    item.fechaEvento ?? '—',
                  ),
                  _datoDetalle(
                    'Próximo paso',
                    _textoContenido(item, 'proximo_paso'),
                  ),
                  const SizedBox(height: 12),
                  _bloqueTexto(
                    titulo: 'Comentarios',
                    contenido: _textoContenido(
                      item,
                      'comentarios',
                      fallback: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _eliminarSeguimiento(item);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar seguimiento'),
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
            Icons.track_changes_outlined,
            color: accent,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            'No hay seguimientos registrados todavía.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando agregues avances del siniestro aparecerán aquí.',
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
            'No se pudieron cargar los seguimientos.',
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
            onPressed: _recargarSeguimientos,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _listaSeguimientos(List<SiniestroParte> seguimientos, Color accent) {
    if (seguimientos.isEmpty) {
      return _emptyState(accent);
    }

    return Column(
      children: seguimientos.map((item) {
        final estatus = _normalizarEstatus(
          item.contenidoJson['estatus']?.toString() ?? item.estado,
        );
        final colorEstatus = _colorEstatus(estatus);
        final etapa = _textoContenido(item, 'etapa', fallback: item.titulo);
        final responsable = _textoContenido(item, 'responsable');
        final proximoPaso = _textoContenido(item, 'proximo_paso');

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
                      Icons.track_changes_outlined,
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
                          '$responsable • $etapa',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Próximo paso: $proximoPaso',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: colorEstatus.withValues(alpha: 0.14),
                    ),
                    child: Text(
                      estatus,
                      style: TextStyle(
                        color: colorEstatus,
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
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _recargarSeguimientos,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Nuevo seguimiento',
            onPressed: _crearSeguimiento,
            icon: const Icon(Icons.track_changes_outlined),
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
              onRefresh: _recargarSeguimientos,
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
                        future: futureSeguimientos,
                        builder: (context, snapshot) {
                          final seguimientos = snapshot.data ?? [];
                          final enProceso = seguimientos.where((item) {
                            final estatus = _normalizarEstatus(
                              item.contenidoJson['estatus']?.toString() ??
                                  item.estado,
                            );
                            return estatus == 'En proceso';
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
                                        Icons.track_changes_outlined,
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
                                            '${_saludoPorHora()}, seguimiento del siniestro',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Control de etapas, responsable y próximo paso.',
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
                                      icon: Icons.timeline_outlined,
                                      titulo: 'Total',
                                      valor: '${seguimientos.length}',
                                      accent: accent,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _resumenCard(
                                      icon: Icons.autorenew_outlined,
                                      titulo: 'En proceso',
                                      valor: '$enProceso',
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
                                _listaSeguimientos(seguimientos, accent),
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