import 'package:flutter/material.dart';

import '../../../../services/api_services/ajustador_api.dart';

class DanosReportadosScreen extends StatefulWidget {
  const DanosReportadosScreen({super.key});

  @override
  State<DanosReportadosScreen> createState() => _DanosReportadosScreenState();
}

class _DanosReportadosScreenState extends State<DanosReportadosScreen> {
  final AjustadorApi api = AjustadorApi();

  late Future<List<SiniestroParte>> futureDanos;
  late Future<List<Siniestro>> futureSiniestros;

  @override
  void initState() {
    super.initState();
    futureDanos = api.getDanos();
    futureSiniestros = api.getSiniestros();
  }

  Future<void> _recargarDanos() async {
    setState(() {
      futureDanos = api.getDanos();
      futureSiniestros = api.getSiniestros();
    });
  }

  String _saludoPorHora() {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) return 'Buenos días';
    if (hora >= 12 && hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _normalizarEstado(String? estado) {
    final e = estado?.trim().toLowerCase();

    switch (e) {
      case 'activo':
      case 'registrado':
        return 'Registrado';
      case 'en_revision':
      case 'en revisión':
      case 'revision':
        return 'En revisión';
      case 'cerrado':
      case 'finalizado':
        return 'Cerrado';
      default:
        return estado?.trim().isNotEmpty == true ? estado!.trim() : 'Registrado';
    }
  }

  String _normalizarSeveridad(String? severidad) {
    final s = severidad?.trim().toLowerCase();

    switch (s) {
      case 'alta':
        return 'Alta';
      case 'media':
        return 'Media';
      case 'baja':
        return 'Baja';
      default:
        return severidad?.trim().isNotEmpty == true ? severidad!.trim() : 'Media';
    }
  }

  String _valorApiEstado(String estado) {
    final e = estado.trim().toLowerCase();

    if (e == 'registrado') return 'activo';
    if (e == 'en revisión') return 'en_revision';
    if (e == 'cerrado') return 'cerrado';

    return e;
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'registrado':
      case 'activo':
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

  Color _colorSeveridad(String severidad) {
    switch (severidad.toLowerCase()) {
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

  Future<void> _crearDano() async {
    final zonaCtrl = TextEditingController();
    final tipoDanoCtrl = TextEditingController();
    final piezasCtrl = TextEditingController();
    final costoCtrl = TextEditingController();
    final observacionesCtrl = TextEditingController();

    String severidad = 'Media';
    String estado = 'Registrado';
    int? siniestroSeleccionadoId;

    final siniestros = await futureSiniestros.catchError((_) {
      return <Siniestro>[];
    });

    if (!mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Nuevo daño reportado'),
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
                    controller: zonaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Zona afectada',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tipoDanoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de daño',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: severidad,
                    decoration: const InputDecoration(
                      labelText: 'Severidad',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                      DropdownMenuItem(value: 'Media', child: Text('Media')),
                      DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        severidad = value ?? 'Media';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: piezasCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Piezas / áreas afectadas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: costoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Costo estimado',
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
                        estado = value ?? 'Registrado';
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
      zonaCtrl.dispose();
      tipoDanoCtrl.dispose();
      piezasCtrl.dispose();
      costoCtrl.dispose();
      observacionesCtrl.dispose();
      return;
    }

    final zona = zonaCtrl.text.trim();
    final tipoDano = tipoDanoCtrl.text.trim();
    final piezas = piezasCtrl.text.trim();
    final costo = costoCtrl.text.trim();
    final observaciones = observacionesCtrl.text.trim();

    zonaCtrl.dispose();
    tipoDanoCtrl.dispose();
    piezasCtrl.dispose();
    costoCtrl.dispose();
    observacionesCtrl.dispose();

    if (siniestroSeleccionadoId == null || zona.isEmpty || tipoDano.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un siniestro, escribe zona y tipo de daño'),
        ),
      );
      return;
    }

    try {
      final ajustadorId = await api.obtenerAjustadorIdGuardado();

      await api.crearParte(
        siniestroId: siniestroSeleccionadoId!,
        tipo: 'danos',
        titulo: zona,
        estado: _valorApiEstado(estado),
        createdBy: ajustadorId,
        contenidoJson: {
          'zona': zona,
          'tipo_dano': tipoDano,
          'severidad': severidad.toLowerCase(),
          'piezas': piezas,
          'costo_estimado': costo,
          'estado': _valorApiEstado(estado),
          'observaciones': observaciones,
        },
      );

      await _recargarDanos();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daño reportado registrado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar daño: $e')),
      );
    }
  }

  Future<void> _eliminarDano(SiniestroParte item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar daño reportado'),
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
      await _recargarDanos();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daño eliminado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar daño: $e')),
      );
    }
  }

  void _mostrarDetalle(SiniestroParte item) {
    final estado = _normalizarEstado(
      item.contenidoJson['estado']?.toString() ?? item.estado,
    );

    final severidad = _normalizarSeveridad(
      item.contenidoJson['severidad']?.toString(),
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
                    'ID daño',
                    item.id.toString(),
                  ),
                  _datoDetalle(
                    'ID siniestro',
                    item.siniestroId?.toString() ?? '—',
                  ),
                  _datoDetalle(
                    'Zona',
                    _textoContenido(item, 'zona', fallback: item.titulo),
                  ),
                  _datoDetalle(
                    'Tipo de daño',
                    _textoContenido(item, 'tipo_dano'),
                  ),
                  _datoDetalle(
                    'Severidad',
                    severidad,
                  ),
                  _datoDetalle(
                    'Piezas',
                    _textoContenido(item, 'piezas'),
                  ),
                  _datoDetalle(
                    'Costo estimado',
                    _textoContenido(item, 'costo_estimado'),
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
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _eliminarDano(item);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar daño'),
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
            width: 115,
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
            Icons.car_crash_outlined,
            color: accent,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            'No hay daños registrados todavía.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando registres daños reportados aparecerán aquí.',
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
            'No se pudieron cargar los daños.',
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
            onPressed: _recargarDanos,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _listaDanos(List<SiniestroParte> danos, Color accent) {
    if (danos.isEmpty) {
      return _emptyState(accent);
    }

    return Column(
      children: danos.map((item) {
        final estado = _normalizarEstado(
          item.contenidoJson['estado']?.toString() ?? item.estado,
        );

        final severidad = _normalizarSeveridad(
          item.contenidoJson['severidad']?.toString(),
        );

        final zona = _textoContenido(item, 'zona', fallback: item.titulo);
        final tipoDano = _textoContenido(item, 'tipo_dano');

        final colorEstado = _colorEstado(estado);
        final colorSeveridad = _colorSeveridad(severidad);

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
                      Icons.car_crash_outlined,
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
                          '$zona • $tipoDano',
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
                                color: colorSeveridad.withValues(alpha: 0.14),
                              ),
                              child: Text(
                                severidad,
                                style: TextStyle(
                                  color: colorSeveridad,
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
        title: const Text('Daños reportados'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _recargarDanos,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Nuevo daño',
            onPressed: _crearDano,
            icon: const Icon(Icons.car_crash_outlined),
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
              onRefresh: _recargarDanos,
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
                        future: futureDanos,
                        builder: (context, snapshot) {
                          final danos = snapshot.data ?? [];

                          final altos = danos.where((item) {
                            final severidad = _normalizarSeveridad(
                              item.contenidoJson['severidad']?.toString(),
                            );
                            return severidad == 'Alta';
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
                                        Icons.car_crash_outlined,
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
                                            '${_saludoPorHora()}, daños reportados',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Registro de afectaciones, severidad y costo estimado.',
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
                                      icon: Icons.report_gmailerrorred_outlined,
                                      titulo: 'Total',
                                      valor: '${danos.length}',
                                      accent: accent,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _resumenCard(
                                      icon: Icons.warning_amber_outlined,
                                      titulo: 'Alta severidad',
                                      valor: '$altos',
                                      accent: accent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: _crearDano,
                                icon: const Icon(Icons.add),
                                label: const Text('Registrar daño'),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Daños registrados',
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
                                _listaDanos(danos, accent),
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