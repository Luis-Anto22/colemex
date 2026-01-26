import 'package:flutter/material.dart';
import '../../../services/api_client.dart';
import '../../../services/investigador_api.dart';

class BitacoraScreen extends StatefulWidget {
  const BitacoraScreen({super.key});

  @override
  State<BitacoraScreen> createState() => _BitacoraScreenState();
}

class _BitacoraScreenState extends State<BitacoraScreen> {
  final int investigadorId = 1; // TODO: real
  final int casoId = 1;         // TODO: real (por ahora fijo)

  late final InvestigadorApi api;
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    api = InvestigadorApi(ApiClient());
    future = api.getBitacora(casoId);
  }

  Future<void> _reload() async {
    setState(() {
      future = api.getBitacora(casoId);
    });
  }

  Future<void> _agregarNota() async {
    final notaCtrl = TextEditingController();
    String estado = 'en proceso';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agregar nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: notaCtrl,
              decoration: const InputDecoration(labelText: 'Nota'),
              maxLines: 4,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: estado,
              items: const [
                DropdownMenuItem(
                    value: 'en proceso', child: Text('En proceso')),
                DropdownMenuItem(
                    value: 'finalizado', child: Text('Finalizado')),
              ],
              onChanged: (v) => estado = v ?? 'en proceso',
              decoration: const InputDecoration(labelText: 'Estado del caso'),
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
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await api.agregarNota(
        casoId: casoId,
        profesionalId: investigadorId,
        nota: notaCtrl.text.trim(),
        estado: estado,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nota agregada')));
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarNota,
        child: const Icon(Icons.note_add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Sin notas todavía.'));
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final b = items[i] as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text((b['nota'] ?? '').toString()),
                    subtitle: Text(
                        'Estado: ${(b['estado'] ?? '').toString()} • ${(b['creado_en'] ?? '').toString()}'),
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
