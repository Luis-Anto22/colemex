import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../services/api_client.dart';
import '../../../services/valuador_api.dart';
import 'dart:io';

class EvidenciaFotograficaScreen extends StatefulWidget {
  final int valuadorId;
  final int? casoId;

  const EvidenciaFotograficaScreen({
    super.key,
    required this.valuadorId,
    this.casoId,
  });

  @override
  State<EvidenciaFotograficaScreen> createState() =>
      _EvidenciaFotograficaScreenState();
}

class _EvidenciaFotograficaScreenState
    extends State<EvidenciaFotograficaScreen> {
  late final ValuadorApi api;
  Future<List<dynamic>>? futureFotos;
  Future<List<dynamic>>? futureCasos;
  int? casoSeleccionado;

  @override
  void initState() {
    super.initState();
    api = ValuadorApi(ApiClient());
    if (widget.casoId != null) {
      casoSeleccionado = widget.casoId;
      futureFotos = api.getFotos(casoSeleccionado!);
    } else {
      futureCasos = api.getAvaluos(widget.valuadorId);
    }
  }

  Future<void> _reload() async {
    setState(() {
      if (casoSeleccionado != null) {
        futureFotos = api.getFotos(casoSeleccionado!);
      } else if (widget.casoId == null) {
        futureCasos = api.getAvaluos(widget.valuadorId);
      }
    });
  }

  Future<void> _subirFoto() async {
    if (casoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un caso primero')),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) return;

    final descCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Subir foto'),
        content: TextField(
          controller: descCtrl,
          decoration: const InputDecoration(labelText: 'Descripcion'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Subir'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await api.subirFoto(
        casoId: casoSeleccionado!,
        valuadorId: widget.valuadorId,
        file: File(path),
        descripcion: descCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Foto subida')));
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
          final id = int.tryParse(c['caso_id'].toString()) ?? 0;
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
                futureFotos = api.getFotos(v);
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

  Widget _buildFotos() {
    if (casoSeleccionado == null) {
      return const Center(child: Text('Selecciona un caso.'));
    }

    return FutureBuilder<List<dynamic>>(
      future: futureFotos,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('No hay fotos todavia.'));
        }

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final f = items[i] as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text((f['descripcion'] ?? 'Foto').toString()),
                  subtitle: Text((f['archivo_url'] ?? '').toString()),
                  trailing: const Icon(Icons.link),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text((f['archivo_url'] ?? '').toString()),
                      ),
                    );
                  },
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
        title: const Text('Evidencia fotografica'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _subirFoto,
        child: const Icon(Icons.add_a_photo),
      ),
      body: Column(
        children: [
          if (widget.casoId == null) _buildSelector(),
          Expanded(child: _buildFotos()),
        ],
      ),
    );
  }
}
