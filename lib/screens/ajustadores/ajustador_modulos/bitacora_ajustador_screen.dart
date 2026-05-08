import 'package:flutter/material.dart';

import '../../../../services/api_services/ajustador_api.dart';

class BitacoraAjustadorScreen extends StatefulWidget {
  const BitacoraAjustadorScreen({super.key});

  @override
  State<BitacoraAjustadorScreen> createState() =>
      _BitacoraAjustadorScreenState();
}

class _BitacoraAjustadorScreenState extends State<BitacoraAjustadorScreen> {
  final AjustadorApi api = AjustadorApi();

  late Future<List<SiniestroParte>> futureBitacora;
  late Future<List<Siniestro>> futureSiniestros;

  @override
  void initState() {
    super.initState();
    futureBitacora = api.getBitacora();
    futureSiniestros = api.getSiniestros();
  }

  Future<void> _recargarBitacora() async {
    setState(() {
      futureBitacora = api.getBitacora();
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
      case 'activo':
      case 'registrado':
        return 'Registrado';
      case 'pendiente':
        return 'Pendiente';
      case 'cerrado':
      case 'finalizado':
        return 'Cerrado';
      default:
        return estado?.trim().isNotEmpty == true ? estado!.trim() : 'Registrado';
    }
  }

  String _valorApiEstado(String estado) {
    final e = estado.trim().toLowerCase();

    if (e == 'registrado') return 'activo';
    if (e == 'pendiente') return 'pendiente';
    if (e == 'cerrado') return 'cerrado';

    return e;
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'registrado':
      case 'activo':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'cerrado':
      case 'finalizado':
        return Colors.blueGrey;
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

  Future<void> _crearMovimiento() async {
    final accionCtrl = TextEditingController();
    final usuarioCtrl = TextEditingController();
    final detalleCtrl = TextEditingController();

    String estado = 'Registrado';
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
            title: const Text('Nuevo movimiento de bitácora'),
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
                  TextField(
                    controller: accionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Acción realizada',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: usuarioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Usuario / responsable',
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
                        value: 'Registrado',
                        child: Text('Registrado'),
                      ),
                      DropdownMenuItem(
                        value: 'Pendiente',
                        child: Text('Pendiente'),
                      ),
                      DropdownMenuItem(
                        value: 'Cerrado',
                        child: Text('Cerrado'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        estado = value ?? 'Registrado';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: detalleCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Detalle / comentario',
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
      accionCtrl.dispose();
      usuarioCtrl.dispose();
      detalleCtrl.dispose();
      return;
    }

    final accion = accionCtrl.text.trim();
    final usuario = usuarioCtrl.text.trim();
    final detalle = detalleCtrl.text.trim();

    accionCtrl.dispose();
    usuarioCtrl.dispose();
    detalleCtrl.dispose();

    if (siniestroSeleccionadoId == null || accion.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un siniestro y escribe la acción realizada'),
        ),
      );
      return;
    }

    try {
      final ajustadorId = await api.obtenerAjustadorIdGuardado();

      await api.crearParte(
        siniestroId: siniestroSeleccionadoId!,
        tipo: 'bitacora',
        titulo: accion,
        estado: _valorApiEstado(estado),
        fechaEvento: _formatearFecha(fechaSeleccionada),
        createdBy: ajustadorId,
        contenidoJson: {
          'accion': accion,
          'usuario': usuario,
          'detalle': detalle,
          'estado': _valorApiEstado(estado),
        },
      );

      await _recargarBitacora();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movimiento registrado en bitácora')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar movimiento: $e')),
      );
    }
  }

  Future<void> _eliminarMovimiento(SiniestroParte item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar movimiento'),
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
      await _recargarBitacora();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movimiento eliminado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar movimiento: $e')),
      );
    }
  }

  void _mostrarDetalle(SiniestroParte item) {
    final estado = _normalizarEstado(
      item.contenidoJson['estado']?.toString() ?? item.estado,
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
                    'ID bitácora',
                    item.id.toString(),
                  ),
                  _datoDetalle(
                    'ID siniestro',
                    item.siniestroId?.toString() ?? '—',
                  ),
                  _datoDetalle(
                    'Fecha',
                    item.fechaEvento ?? '—',
                  ),
                  _datoDetalle(
                    'Acción',
                    _textoContenido(item, 'accion', fallback: item.titulo),
                  ),
                  _datoDetalle(
                    'Usuario',
                    _textoContenido(item, 'usuario'),
                  ),
                  _datoDetalle(
                    'Estado',
                    estado,
                  ),
                  const SizedBox(height: 12),
                  _bloqueTexto(
                    titulo: 'Detalle',
                    contenido: _textoContenido(
                      item,
                      'detalle',
                      fallback: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _eliminarMovimiento(item);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar movimiento'),
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
            width: 105,
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
            Icons.edit_note_outlined,
            color: accent,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            'No hay movimientos registrados todavía.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando registres acciones de bitácora aparecerán aquí.',
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
            'No se pudo cargar la bitácora.',
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
            onPressed: _recargarBitacora,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _listaBitacora(List<SiniestroParte> bitacora, Color accent) {
    if (bitacora.isEmpty) {
      return _emptyState(accent);
    }

    return Column(
      children: bitacora.map((item) {
        final estado = _normalizarEstado(
          item.contenidoJson['estado']?.toString() ?? item.estado,
        );

        final accion = _textoContenido(
          item,
          'accion',
          fallback: item.titulo,
        );

        final usuario = _textoContenido(item, 'usuario');
        final colorEstado = _colorEstado(estado);

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
                          accion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fecha: ${item.fechaEvento ?? 'Sin fecha'}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Usuario: $usuario',
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
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _recargarBitacora,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Nuevo movimiento',
            onPressed: _crearMovimiento,
            icon: const Icon(Icons.edit_note_outlined),
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
              onRefresh: _recargarBitacora,
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
                        future: futureBitacora,
                        builder: (context, snapshot) {
                          final bitacora = snapshot.data ?? [];

                          final pendientes = bitacora.where((item) {
                            final estado = _normalizarEstado(
                              item.contenidoJson['estado']?.toString() ??
                                  item.estado,
                            );
                            return estado == 'Pendiente';
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
                                            '${_saludoPorHora()}, bitácora del ajustador',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Registro cronológico de acciones, notas y movimientos.',
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
                                      valor: '${bitacora.length}',
                                      accent: accent,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _resumenCard(
                                      icon: Icons.pending_actions_outlined,
                                      titulo: 'Pendientes',
                                      valor: '$pendientes',
                                      accent: accent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: _crearMovimiento,
                                icon: const Icon(Icons.add),
                                label: const Text('Registrar movimiento'),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Movimientos registrados',
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
                                _listaBitacora(bitacora, accent),
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