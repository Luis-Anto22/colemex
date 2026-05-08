import 'package:flutter/material.dart';

import '../../../../services/api_services/ajustador_api.dart';

class DatosPolizaScreen extends StatefulWidget {
  const DatosPolizaScreen({super.key});

  @override
  State<DatosPolizaScreen> createState() => _DatosPolizaScreenState();
}

class _DatosPolizaScreenState extends State<DatosPolizaScreen> {
  final AjustadorApi api = AjustadorApi();

  late Future<List<SiniestroParte>> futurePolizas;
  late Future<List<Siniestro>> futureSiniestros;

  @override
  void initState() {
    super.initState();
    futurePolizas = api.getPolizas();
    futureSiniestros = api.getSiniestros();
  }

  Future<void> _recargarPolizas() async {
    setState(() {
      futurePolizas = api.getPolizas();
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
      case 'vigente':
        return 'Vigente';
      case 'en_validacion':
      case 'en validación':
      case 'validacion':
      case 'validación':
        return 'En validación';
      case 'vencida':
        return 'Vencida';
      default:
        return estado?.trim().isNotEmpty == true ? estado!.trim() : 'Vigente';
    }
  }

  String _valorApiEstado(String estado) {
    final e = estado.trim().toLowerCase();

    if (e == 'en validación') return 'en_validacion';
    if (e == 'vigente') return 'vigente';
    if (e == 'vencida') return 'vencida';

    return e;
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'vigente':
        return Colors.green;
      case 'en validación':
      case 'en_validacion':
        return Colors.orange;
      case 'vencida':
        return Colors.red;
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

  Future<void> _crearPoliza() async {
    final numeroPolizaCtrl = TextEditingController();
    final aseguradoraCtrl = TextEditingController();
    final vigenciaCtrl = TextEditingController();
    final deducibleCtrl = TextEditingController();
    final observacionesCtrl = TextEditingController();

    String cobertura = 'Amplia';
    String estado = 'Vigente';
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
            title: const Text('Nueva póliza'),
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
                    controller: numeroPolizaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Número de póliza',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: aseguradoraCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Aseguradora',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: vigenciaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Vigencia',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: cobertura,
                    decoration: const InputDecoration(
                      labelText: 'Cobertura',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Amplia',
                        child: Text('Amplia'),
                      ),
                      DropdownMenuItem(
                        value: 'Limitada',
                        child: Text('Limitada'),
                      ),
                      DropdownMenuItem(
                        value: 'Responsabilidad civil',
                        child: Text('Responsabilidad civil'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        cobertura = value ?? 'Amplia';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: deducibleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Deducible',
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
                        value: 'Vigente',
                        child: Text('Vigente'),
                      ),
                      DropdownMenuItem(
                        value: 'En validación',
                        child: Text('En validación'),
                      ),
                      DropdownMenuItem(
                        value: 'Vencida',
                        child: Text('Vencida'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        estado = value ?? 'Vigente';
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
      numeroPolizaCtrl.dispose();
      aseguradoraCtrl.dispose();
      vigenciaCtrl.dispose();
      deducibleCtrl.dispose();
      observacionesCtrl.dispose();
      return;
    }

    final numeroPoliza = numeroPolizaCtrl.text.trim();
    final aseguradora = aseguradoraCtrl.text.trim();
    final vigencia = vigenciaCtrl.text.trim();
    final deducible = deducibleCtrl.text.trim();
    final observaciones = observacionesCtrl.text.trim();

    numeroPolizaCtrl.dispose();
    aseguradoraCtrl.dispose();
    vigenciaCtrl.dispose();
    deducibleCtrl.dispose();
    observacionesCtrl.dispose();

    if (siniestroSeleccionadoId == null || numeroPoliza.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un siniestro y escribe el número de póliza'),
        ),
      );
      return;
    }

    try {
      final ajustadorId = await api.obtenerAjustadorIdGuardado();

      await api.crearParte(
        siniestroId: siniestroSeleccionadoId!,
        tipo: 'poliza',
        titulo: numeroPoliza,
        estado: _valorApiEstado(estado),
        createdBy: ajustadorId,
        contenidoJson: {
          'numero_poliza': numeroPoliza,
          'aseguradora': aseguradora,
          'vigencia': vigencia,
          'cobertura': cobertura,
          'deducible': deducible,
          'estado': _valorApiEstado(estado),
          'observaciones': observaciones,
        },
      );

      await _recargarPolizas();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Póliza registrada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar póliza: $e')),
      );
    }
  }

  Future<void> _eliminarPoliza(SiniestroParte item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar póliza'),
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
      await _recargarPolizas();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Póliza eliminada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar póliza: $e')),
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
                    _textoContenido(
                      item,
                      'numero_poliza',
                      fallback: item.titulo,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _datoDetalle(
                    'ID póliza',
                    item.id.toString(),
                  ),
                  _datoDetalle(
                    'ID siniestro',
                    item.siniestroId?.toString() ?? '—',
                  ),
                  _datoDetalle(
                    'Aseguradora',
                    _textoContenido(item, 'aseguradora'),
                  ),
                  _datoDetalle(
                    'Vigencia',
                    _textoContenido(item, 'vigencia'),
                  ),
                  _datoDetalle(
                    'Cobertura',
                    _textoContenido(item, 'cobertura'),
                  ),
                  _datoDetalle(
                    'Deducible',
                    _textoContenido(item, 'deducible'),
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
                      _eliminarPoliza(item);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar póliza'),
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
            Icons.badge_outlined,
            color: accent,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            'No hay pólizas registradas todavía.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando registres datos de póliza aparecerán aquí.',
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
            'No se pudieron cargar las pólizas.',
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
            onPressed: _recargarPolizas,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _listaPolizas(List<SiniestroParte> polizas, Color accent) {
    if (polizas.isEmpty) {
      return _emptyState(accent);
    }

    return Column(
      children: polizas.map((item) {
        final estado = _normalizarEstado(
          item.contenidoJson['estado']?.toString() ?? item.estado,
        );

        final numeroPoliza = _textoContenido(
          item,
          'numero_poliza',
          fallback: item.titulo,
        );

        final aseguradora = _textoContenido(item, 'aseguradora');
        final cobertura = _textoContenido(item, 'cobertura');
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
                      Icons.badge_outlined,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          numeroPoliza,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          aseguradora,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cobertura: $cobertura',
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
        title: const Text('Datos de póliza'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _recargarPolizas,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Nueva póliza',
            onPressed: _crearPoliza,
            icon: const Icon(Icons.add_card_outlined),
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
              onRefresh: _recargarPolizas,
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
                        future: futurePolizas,
                        builder: (context, snapshot) {
                          final polizas = snapshot.data ?? [];

                          final vigentes = polizas.where((item) {
                            final estado = _normalizarEstado(
                              item.contenidoJson['estado']?.toString() ??
                                  item.estado,
                            );
                            return estado == 'Vigente';
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
                                        Icons.badge_outlined,
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
                                            '${_saludoPorHora()}, datos de póliza',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Cobertura, vigencia, deducible y validación de la póliza.',
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
                                      icon: Icons.policy_outlined,
                                      titulo: 'Total',
                                      valor: '${polizas.length}',
                                      accent: accent,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _resumenCard(
                                      icon: Icons.verified_outlined,
                                      titulo: 'Vigentes',
                                      valor: '$vigentes',
                                      accent: accent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: _crearPoliza,
                                icon: const Icon(Icons.add),
                                label: const Text('Registrar póliza'),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Pólizas registradas',
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
                                _listaPolizas(polizas, accent),
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