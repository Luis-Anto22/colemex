import 'package:flutter/material.dart';
import '../../../services/api_client.dart';
import '../../../services/investigador_api.dart';

class CasosAsignadosScreen extends StatefulWidget {
  const CasosAsignadosScreen({super.key});

  @override
  State<CasosAsignadosScreen> createState() => _CasosAsignadosScreenState();
}

class _CasosAsignadosScreenState extends State<CasosAsignadosScreen> {
  final int investigadorId = 1; // TODO: reemplazar por el ID real
  late final InvestigadorApi api;
  late Future<List<dynamic>> futureCasos;

  @override
  void initState() {
    super.initState();
    api = InvestigadorApi(ApiClient());
    futureCasos = api.getCasos(investigadorId);
  }

  Future<void> _reload() async {
    setState(() {
      futureCasos = api.getCasos(investigadorId);
    });
  }

  Future<void> _crearCaso() async {
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo caso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
        investigadorId: investigadorId,
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

                return Card(
                  child: ListTile(
                    title: Text((c['titulo'] ?? 'Sin título').toString()),
                    subtitle: Text((c['descripcion'] ?? '').toString()),
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
