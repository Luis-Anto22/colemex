import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/common_api.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final CommonApi api = CommonApi(ApiClient());

  bool cargando = true;
  String mensaje = '';

  int profesionalId = 0;

  List<dynamic> items = [];
  List<dynamic> clientes = [];

  int? clienteSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    profesionalId = prefs.getInt('id') ?? 0;

    if (profesionalId <= 0) {
      setState(() {
        cargando = false;
        mensaje = 'ID no válido';
      });
      return;
    }

    try {
      final agenda = await api.getAgenda(profesionalId);
      final listaClientes = await api.getClientes();

      if (!mounted) return;

      setState(() {
        items = agenda;
        clientes = listaClientes;
        cargando = false;
        mensaje = '';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
        mensaje = 'Error: $e';
      });
    }
  }

  Future<void> _cambiarEstadoCita(int citaId, String estado) async {
    try {
      await api.actualizarEstadoCita(
        citaId: citaId,
        estado: estado,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cita marcada como ${_labelEstado(estado)}'),
        ),
      );

      await _cargar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _fmt(DateTime dt) {
    return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} '
        '${_two(dt.hour)}:${_two(dt.minute)}:00';
  }

  String _fmtBonito(String? value) {
    if (value == null || value.trim().isEmpty) return 'Sin fecha';
    final raw = value.trim().replaceFirst('T', ' ');
    if (raw.length >= 16) return raw.substring(0, 16);
    return raw;
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  String _nombreCliente(int? id) {
    if (id == null) return 'Cliente';

    try {
      final c = clientes.firstWhere((c) => _toInt(c['id']) == id);
      return (c['nombre'] ?? 'Cliente').toString();
    } catch (_) {
      return 'Cliente #$id';
    }
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmada':
      case 'en proceso':
        return Colors.blue;
      case 'cancelada':
      case 'cancelado':
        return Colors.red;
      case 'completada':
      case 'finalizado':
        return Colors.green;
      case 'no_asistio':
        return Colors.grey;
      default:
        return Colors.black54;
    }
  }

  String _labelEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'confirmada':
        return 'Confirmada';
      case 'en proceso':
        return 'En proceso';
      case 'cancelada':
      case 'cancelado':
        return 'Cancelada';
      case 'completada':
        return 'Completada';
      case 'finalizado':
        return 'Finalizado';
      case 'no_asistio':
        return 'No asistió';
      default:
        return estado;
    }
  }

  String _labelTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'presencial':
        return 'Presencial';
      case 'virtual':
        return 'Virtual';
      case 'telefonica':
        return 'Telefónica';
      default:
        return tipo;
    }
  }

  Future<DateTime?> _pickDateTime({DateTime? initial}) async {
    final now = initial ?? DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _crearCita() async {
    if (profesionalId <= 0) return;

    int? clienteId = clienteSeleccionado;
    DateTime? inicio;
    DateTime? fin;

    final tituloCtrl = TextEditingController();
    final motivoCtrl = TextEditingController();
    final ubicacionCtrl = TextEditingController();
    final enlaceCtrl = TextEditingController();
    final notasCtrl = TextEditingController();

    String tipo = 'presencial';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setModalState) => AlertDialog(
          title: const Text('Nueva cita'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: clienteId,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar cliente',
                    border: OutlineInputBorder(),
                  ),
                  items: clientes.map<DropdownMenuItem<int>>((c) {
                    final id = _toInt(c['id']) ?? 0;
                    final nombre = (c['nombre'] ?? 'Cliente').toString();

                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(nombre),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setModalState(() {
                      clienteId = v;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tituloCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: motivoCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Motivo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: tipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de cita',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'presencial',
                      child: Text('Presencial'),
                    ),
                    DropdownMenuItem(
                      value: 'virtual',
                      child: Text('Virtual'),
                    ),
                    DropdownMenuItem(
                      value: 'telefonica',
                      child: Text('Telefónica'),
                    ),
                  ],
                  onChanged: (v) {
                    setModalState(() {
                      tipo = v ?? 'presencial';
                    });
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final dt = await _pickDateTime(initial: inicio);
                    if (dt == null) return;

                    setModalState(() {
                      inicio = dt;
                    });
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    inicio == null
                        ? 'Seleccionar inicio'
                        : 'Inicio: ${_fmt(inicio!)}',
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final dt = await _pickDateTime(
                      initial: fin ?? inicio ?? DateTime.now(),
                    );
                    if (dt == null) return;

                    setModalState(() {
                      fin = dt;
                    });
                  },
                  icon: const Icon(Icons.stop),
                  label: Text(
                    fin == null
                        ? 'Seleccionar fin (opcional)'
                        : 'Fin: ${_fmt(fin!)}',
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
                TextField(
                  controller: enlaceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Enlace de reunión',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notasCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || inicio == null || clienteId == null) {
      tituloCtrl.dispose();
      motivoCtrl.dispose();
      ubicacionCtrl.dispose();
      enlaceCtrl.dispose();
      notasCtrl.dispose();
      return;
    }

    final int clienteIdFinal = clienteId!;
    final DateTime inicioFinal = inicio!;
    final String tituloFinal = tituloCtrl.text.trim();
    final String motivoFinal = motivoCtrl.text.trim();
    final String ubicacionFinal = ubicacionCtrl.text.trim();
    final String enlaceFinal = enlaceCtrl.text.trim();
    final String notasFinal = notasCtrl.text.trim();
    final String tipoFinal = tipo;
    final String? finFinal = fin == null ? null : _fmt(fin!);

    tituloCtrl.dispose();
    motivoCtrl.dispose();
    ubicacionCtrl.dispose();
    enlaceCtrl.dispose();
    notasCtrl.dispose();

    try {
      await api.crearAgenda(
        profesionalId: profesionalId,
        clienteId: clienteIdFinal,
        inicio: _fmt(inicioFinal),
        titulo: tituloFinal.isEmpty ? null : tituloFinal,
        motivo: motivoFinal.isEmpty ? null : motivoFinal,
        fin: finFinal,
        tipo: tipoFinal,
        ubicacion: ubicacionFinal.isEmpty ? null : ubicacionFinal,
        enlaceReunion: enlaceFinal.isEmpty ? null : enlaceFinal,
        notas: notasFinal.isEmpty ? null : notasFinal,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita creada')),
      );

      await _cargar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _verDetalle(Map<String, dynamic> a) {
    final clienteId = _toInt(a['cliente_id']);
    final estado = (a['estado'] ?? '').toString();
    final tipo = (a['tipo'] ?? '').toString();
    final titulo = (a['titulo'] ?? '').toString();
    final motivo = (a['motivo'] ?? '').toString();
    final inicio = (a['inicio'] ?? '').toString();
    final fin = (a['fin'] ?? '').toString();
    final ubicacion = (a['ubicacion'] ?? '').toString();
    final enlace = (a['enlace_reunion'] ?? '').toString();
    final notas = (a['notas'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo.isEmpty ? 'Cita' : titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Cliente: ${_nombreCliente(clienteId)}'),
                const SizedBox(height: 6),
                Text('Estado: ${_labelEstado(estado)}'),
                const SizedBox(height: 6),
                Text('Tipo: ${_labelTipo(tipo)}'),
                const SizedBox(height: 6),
                Text('Inicio: ${_fmtBonito(inicio)}'),
                if (fin.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('Fin: ${_fmtBonito(fin)}'),
                ],
                if (motivo.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Motivo',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(motivo),
                ],
                if (ubicacion.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Ubicación',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(ubicacion),
                ],
                if (enlace.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Enlace de reunión',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(enlace),
                ],
                if (notas.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Notas',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(notas),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda / citas'),
        actions: [
          IconButton(
            onPressed: _cargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearCita,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.event_available_outlined, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text(
              'Agenda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Citas, disponibilidad y horarios.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (cargando)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    mensaje.isEmpty ? 'Sin citas registradas.' : mensaje,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final a = items[i] as Map<String, dynamic>;
                    final clienteId = _toInt(a['cliente_id']);
                    final estado = (a['estado'] ?? '').toString();
                    final titulo = (a['titulo'] ?? '').toString().trim();
                    final tipo = (a['tipo'] ?? '').toString().trim();

                    return ListTile(
                      leading: Icon(Icons.calendar_today, color: gold),
                      title: Text(
                        titulo.isEmpty ? _nombreCliente(clienteId) : titulo,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_nombreCliente(clienteId)),
                          Text(_fmtBonito((a['inicio'] ?? '').toString())),
                          if (tipo.isNotEmpty) Text(_labelTipo(tipo)),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (estadoNuevo) {
                          final citaId =
                              int.tryParse(a['id']?.toString() ?? '') ?? 0;

                          if (citaId <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ID de cita no válido'),
                              ),
                            );
                            return;
                          }

                          _cambiarEstadoCita(citaId, estadoNuevo);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'pendiente',
                            child: Text('Pendiente'),
                          ),
                          PopupMenuItem(
                            value: 'confirmada',
                            child: Text('Confirmada'),
                          ),
                          PopupMenuItem(
                            value: 'completada',
                            child: Text('Completada'),
                          ),
                          PopupMenuItem(
                            value: 'cancelado',
                            child: Text('Cancelado'),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _colorEstado(estado)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _labelEstado(estado),
                            style: TextStyle(
                              color: _colorEstado(estado),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      onTap: () => _verDetalle(a),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}