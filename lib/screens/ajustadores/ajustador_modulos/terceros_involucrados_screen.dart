import 'package:flutter/material.dart';

import '../../../../services/api_services/ajustador_api.dart';

class TercerosInvolucradosScreen extends StatefulWidget {
  const TercerosInvolucradosScreen({super.key});

  @override
  State<TercerosInvolucradosScreen> createState() =>
      _TercerosInvolucradosScreenState();
}

class _TercerosInvolucradosScreenState
    extends State<TercerosInvolucradosScreen> {
  final AjustadorApi api = AjustadorApi();

  late Future<List<SiniestroTercero>> futureTerceros;
  late Future<List<Siniestro>> futureSiniestros;

  @override
  void initState() {
    super.initState();
    futureTerceros = api.getTerceros();
    futureSiniestros = api.getSiniestros();
  }

  Future<void> _recargarTerceros() async {
    setState(() {
      futureTerceros = api.getTerceros();
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

  Color _colorResponsabilidad(String responsabilidad) {
    switch (responsabilidad.toLowerCase()) {
      case 'a cargo del tercero':
        return Colors.red;
      case 'a cargo del asegurado':
        return Colors.orange;
      case 'probable compartida':
        return Colors.blue;
      case 'pendiente':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _crearTercero() async {
    final nombreCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final placasCtrl = TextEditingController();
    final aseguradoraCtrl = TextEditingController();
    final vehiculoCtrl = TextEditingController();
    final versionCtrl = TextEditingController();

    String responsabilidad = 'Pendiente';
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
            title: const Text('Nuevo tercero involucrado'),
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
                    controller: nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del tercero',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: placasCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Placas',
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
                    controller: vehiculoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Vehículo',
                      border: OutlineInputBorder(),
                    ),
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
                    controller: versionCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Versión de hechos',
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
      nombreCtrl.dispose();
      telefonoCtrl.dispose();
      placasCtrl.dispose();
      aseguradoraCtrl.dispose();
      vehiculoCtrl.dispose();
      versionCtrl.dispose();
      return;
    }

    final nombre = nombreCtrl.text.trim();
    final telefono = telefonoCtrl.text.trim();
    final placas = placasCtrl.text.trim();
    final aseguradora = aseguradoraCtrl.text.trim();
    final vehiculo = vehiculoCtrl.text.trim();
    final versionHechos = versionCtrl.text.trim();

    nombreCtrl.dispose();
    telefonoCtrl.dispose();
    placasCtrl.dispose();
    aseguradoraCtrl.dispose();
    vehiculoCtrl.dispose();
    versionCtrl.dispose();

    if (siniestroSeleccionadoId == null || nombre.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un siniestro y escribe el nombre del tercero'),
        ),
      );
      return;
    }

    try {
      await api.crearTercero(
        siniestroId: siniestroSeleccionadoId!,
        nombre: nombre,
        telefono: telefono,
        placas: placas,
        aseguradora: aseguradora,
        vehiculo: vehiculo,
        versionHechos: versionHechos,
        responsabilidad: responsabilidad,
        estado: _valorApiEstado(estado),
      );

      await _recargarTerceros();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tercero involucrado registrado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar tercero: $e')),
      );
    }
  }

  Future<void> _eliminarTercero(SiniestroTercero tercero) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar tercero'),
        content: Text(
          '¿Seguro que deseas eliminar a "${tercero.nombre}"?',
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
      await api.eliminarTercero(tercero.id);
      await _recargarTerceros();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tercero eliminado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar tercero: $e')),
      );
    }
  }

  void _mostrarDetalle(SiniestroTercero item) {
    final estado = _normalizarEstado(item.estado);

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
                    item.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _datoDetalle(
                    'ID tercero',
                    item.id.toString(),
                  ),
                  _datoDetalle(
                    'ID siniestro',
                    item.siniestroId?.toString() ?? '—',
                  ),
                  _datoDetalle(
                    'Teléfono',
                    item.telefono?.trim().isNotEmpty == true
                        ? item.telefono!
                        : '—',
                  ),
                  _datoDetalle(
                    'Placas',
                    item.placas?.trim().isNotEmpty == true ? item.placas! : '—',
                  ),
                  _datoDetalle(
                    'Aseguradora',
                    item.aseguradora?.trim().isNotEmpty == true
                        ? item.aseguradora!
                        : '—',
                  ),
                  _datoDetalle(
                    'Vehículo',
                    item.vehiculo?.trim().isNotEmpty == true
                        ? item.vehiculo!
                        : '—',
                  ),
                  _datoDetalle(
                    'Responsabilidad',
                    item.responsabilidad?.trim().isNotEmpty == true
                        ? item.responsabilidad!
                        : 'Pendiente',
                  ),
                  _datoDetalle(
                    'Estado',
                    estado,
                  ),
                  const SizedBox(height: 12),
                  _bloqueTexto(
                    titulo: 'Versión de hechos',
                    contenido: item.versionHechos ?? '',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _eliminarTercero(item);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar tercero'),
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
            Icons.groups_outlined,
            color: accent,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            'No hay terceros involucrados registrados todavía.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando registres terceros relacionados a un siniestro aparecerán aquí.',
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
            'No se pudieron cargar los terceros involucrados.',
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
            onPressed: _recargarTerceros,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _listaTerceros(List<SiniestroTercero> terceros, Color accent) {
    if (terceros.isEmpty) {
      return _emptyState(accent);
    }

    return Column(
      children: terceros.map((item) {
        final estado = _normalizarEstado(item.estado);
        final responsabilidad =
            item.responsabilidad?.trim().isNotEmpty == true
                ? item.responsabilidad!
                : 'Pendiente';

        final colorEstado = _colorEstado(estado);
        final colorResponsabilidad = _colorResponsabilidad(responsabilidad);

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
                      Icons.groups_outlined,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.vehiculo?.trim().isNotEmpty == true ? item.vehiculo : 'Vehículo'} • '
                          '${item.placas?.trim().isNotEmpty == true ? item.placas : 'Sin placas'}',
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: colorResponsabilidad.withValues(
                                  alpha: 0.14,
                                ),
                              ),
                              child: Text(
                                responsabilidad,
                                style: TextStyle(
                                  color: colorResponsabilidad,
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
        title: const Text('Terceros involucrados'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _recargarTerceros,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Nuevo tercero',
            onPressed: _crearTercero,
            icon: const Icon(Icons.person_add_alt_1_outlined),
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
              onRefresh: _recargarTerceros,
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
                      child: FutureBuilder<List<SiniestroTercero>>(
                        future: futureTerceros,
                        builder: (context, snapshot) {
                          final terceros = snapshot.data ?? [];
                          final revisiones = terceros
                              .where(
                                (t) =>
                                    _normalizarEstado(t.estado) ==
                                    'En revisión',
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
                                          color: accent.withValues(alpha: 0.20),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.groups_outlined,
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
                                            '${_saludoPorHora()}, terceros involucrados',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Registro de datos, versiones y responsabilidad probable.',
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
                                      icon: Icons.groups_outlined,
                                      titulo: 'Total',
                                      valor: '${terceros.length}',
                                      accent: accent,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _resumenCard(
                                      icon: Icons.rule_folder_outlined,
                                      titulo: 'En revisión',
                                      valor: '$revisiones',
                                      accent: accent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: _crearTercero,
                                icon: const Icon(Icons.add),
                                label: const Text('Registrar tercero'),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Terceros registrados',
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
                                _listaTerceros(terceros, accent),
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