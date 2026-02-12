import 'package:flutter/material.dart';
import '../../../services/api_client.dart';
import '../../../services/investigador_api.dart';

class BitacoraScreen extends StatefulWidget {
  final int investigadorId;
  final int? casoId;

  const BitacoraScreen({
    super.key,
    required this.investigadorId,
    this.casoId,
  });

  @override
  State<BitacoraScreen> createState() => _BitacoraScreenState();
}

class _BitacoraScreenState extends State<BitacoraScreen> {
  late final InvestigadorApi api;
  Future<List<dynamic>>? futureBitacora;
  Future<List<dynamic>>? futureCasos;
  int? casoSeleccionado;

  @override
  void initState() {
    super.initState();
    api = InvestigadorApi(ApiClient());
    if (widget.casoId != null) {
      casoSeleccionado = widget.casoId;
      futureBitacora = api.getBitacora(casoSeleccionado!);
    } else {
      futureCasos = api.getCasos(widget.investigadorId);
    }
  }

  Future<void> _reload() async {
    setState(() {
      if (casoSeleccionado != null) {
        futureBitacora = api.getBitacora(casoSeleccionado!);
      } else if (widget.casoId == null) {
        futureCasos = api.getCasos(widget.investigadorId);
      }
    });
  }

  Future<void> _agregarNota() async {
    if (casoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un caso primero')),
      );
      return;
    }

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
              initialValue: estado,
              items: const [
                DropdownMenuItem(value: 'en proceso', child: Text('En proceso')),
                DropdownMenuItem(value: 'finalizado', child: Text('Finalizado')),
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
        casoId: casoSeleccionado!,
        profesionalId: widget.investigadorId,
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

  Widget _buildSelector() {
    return FutureBuilder<List<dynamic>>(
      future: futureCasos,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: LinearProgressIndicator(),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Error: ${snap.error}'),
          );
        }

        final casos = snap.data ?? [];
        if (casos.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Text('No hay casos para seleccionar.'),
          );
        }

        final items = casos.map<DropdownMenuItem<int>>((c) {
          final id = int.tryParse(c['id'].toString()) ?? 0;
          final titulo = (c['titulo'] ?? 'Sin titulo').toString();
          return DropdownMenuItem(
            value: id,
            child: Text('Caso #$id · $titulo'),
          );
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(12),
          child: DropdownButtonFormField<int>(
            initialValue: casoSeleccionado,
            items: items,
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                casoSeleccionado = v;
                futureBitacora = api.getBitacora(v);
              });
            },
            decoration: const InputDecoration(
              labelText: 'Selecciona un caso',
              border: OutlineInputBorder(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBitacora() {
    if (casoSeleccionado == null) {
      return const Center(child: Text('Selecciona un caso.'));
    }

    return FutureBuilder<List<dynamic>>(
      future: futureBitacora,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Sin notas todavia.'));
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
                    'Estado: ${(b['estado'] ?? '').toString()} · ${(b['creado_en'] ?? '').toString()}',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitacora'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarNota,
        child: const Icon(Icons.note_add),
      ),
      body: Column(
        children: [
          if (widget.casoId == null) _buildSelector(),
          Expanded(child: _buildBitacora()),
        ],
      ),
    );
  }
}
