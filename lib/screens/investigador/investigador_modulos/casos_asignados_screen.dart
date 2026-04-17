import 'package:flutter/material.dart';
import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/investigador_api.dart';
import '../../../services/api_services/common_api.dart';
import 'bitacora_screen.dart';
import 'evidencias_screen.dart';

class CasosAsignadosScreen extends StatefulWidget {
  final int investigadorId;

  const CasosAsignadosScreen({
    super.key,
    required this.investigadorId,
  });

  @override
  State<CasosAsignadosScreen> createState() => _CasosAsignadosScreenState();
}

class _CasosAsignadosScreenState extends State<CasosAsignadosScreen> {
  late final InvestigadorApi api;
  late final CommonApi commonApi;
  late Future<List<dynamic>> futureCasos;
  List<dynamic> clientes = [];

  @override
  void initState() {
    super.initState();
    api = InvestigadorApi(ApiClient());
    commonApi = CommonApi(ApiClient());
    futureCasos = api.getCasos(widget.investigadorId);
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    try {
      final data = await commonApi.getClientes();
      if (!mounted) return;
      setState(() => clientes = data);
    } catch (_) {}
  }

  Map<String, dynamic>? _findCliente(int id) {
    for (final c in clientes) {
      final m = c as Map<String, dynamic>;
      if (m['id'].toString() == id.toString()) return m;
    }
    return null;
  }

  Future<void> _reload() async {
    setState(() {
      futureCasos = api.getCasos(widget.investigadorId);
    });
  }

  Future<void> _crearCaso() async {
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    int? clienteIdSeleccionado;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo caso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: clienteIdSeleccionado,
              items: clientes.map<DropdownMenuItem<int>>((c) {
                final m = c as Map<String, dynamic>;
                final id = int.tryParse(m['id'].toString()) ?? 0;
                final nombre = (m['nombre'] ?? '').toString();
                final correo = (m['correo'] ?? '').toString();
                return DropdownMenuItem(
                  value: id,
                  child: Text('$nombre (${correo.isEmpty ? 'sin correo' : correo})'),
                );
              }).toList(),
              onChanged: (v) => clienteIdSeleccionado = v,
              decoration: const InputDecoration(labelText: 'Cliente'),
            ),
            TextField(
              controller: tituloCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await api.crearCaso(
        investigadorId: widget.investigadorId,
        clienteId: clienteIdSeleccionado,
        titulo: tituloCtrl.text.trim(),
        descripcion: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Caso creado')));
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _cambiarEstado(int id, String nuevo) async {
    try {
      await api.actualizarEstadoCaso(id: id, estado: nuevo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado actualizado correctamente')));
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      case 'finalizado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _abrirCaso(Map<String, dynamic> caso) {
    final id = int.tryParse(caso['id'].toString()) ?? 0;
    if (id <= 0) return;

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                (caso['titulo'] ?? 'Caso').toString(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text((caso['descripcion'] ?? '').toString()),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BitacoraScreen(
                        investigadorId: widget.investigadorId,
                        casoId: id,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.notes_outlined),
                label: const Text('Bitacora del caso'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EvidenciasScreen(
                        investigadorId: widget.investigadorId,
                        casoId: id,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Evidencias del caso'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _cambiarEstado(id, 'en proceso');
                },
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Marcar en proceso'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _cambiarEstado(id, 'finalizado');
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Marcar finalizado'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Casos asignados'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearCaso,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureCasos,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final casos = snap.data ?? [];
          if (casos.isEmpty) {
            return const Center(child: Text('No hay casos todavía.'));
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: casos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final c = casos[i] as Map<String, dynamic>;
                final id = int.parse(c['id'].toString());
                final estado = (c['estado'] ?? '').toString();
                final clienteId = int.tryParse(c['cliente_id']?.toString() ?? '') ?? 0;
                final cliente = clienteId > 0 ? _findCliente(clienteId) : null;
                final clienteLabel = cliente == null
                    ? (clienteId > 0 ? 'Cliente #$clienteId' : 'Cliente')
                    : (cliente['nombre'] ?? 'Cliente').toString();

                return Card(
                  child: ListTile(
                    title: Text((c['titulo'] ?? 'Sin título').toString()),
                    subtitle: Text(
                      '${(c['descripcion'] ?? '').toString()}\n$clienteLabel',
                    ),
                    onTap: () => _abrirCaso(c),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) => _cambiarEstado(id, v),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                            value: 'pendiente', child: Text('Pendiente')),
                        PopupMenuItem(
                            value: 'en proceso', child: Text('En proceso')),
                        PopupMenuItem(
                            value: 'finalizado', child: Text('Finalizado')),
                        PopupMenuItem(
                            value: 'cancelado', child: Text('Cancelado')),
                      ],
                      child: Chip(
                        label: Text(estado.isEmpty ? '—' : estado),
                        backgroundColor: _colorEstado(estado).withOpacity(.15),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
