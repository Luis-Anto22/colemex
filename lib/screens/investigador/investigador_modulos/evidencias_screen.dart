import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../services/api_client.dart';
import '../../../services/investigador_api.dart';
import 'dart:io';

class EvidenciasScreen extends StatefulWidget {
  final int investigadorId;
  final int? casoId;

  const EvidenciasScreen({
    super.key,
    required this.investigadorId,
    this.casoId,
  });

  @override
  State<EvidenciasScreen> createState() => _EvidenciasScreenState();
}

class _EvidenciasScreenState extends State<EvidenciasScreen> {
  late final InvestigadorApi api;
  Future<List<dynamic>>? futureEvidencias;
  Future<List<dynamic>>? futureCasos;
  int? casoSeleccionado;

  @override
  void initState() {
    super.initState();
    api = InvestigadorApi(ApiClient());
    if (widget.casoId != null) {
      casoSeleccionado = widget.casoId;
      futureEvidencias = api.getEvidencias(casoSeleccionado!);
    } else {
      futureCasos = api.getCasos(widget.investigadorId);
    }
  }

  Future<void> _reload() async {
    setState(() {
      if (casoSeleccionado != null) {
        futureEvidencias = api.getEvidencias(casoSeleccionado!);
      } else if (widget.casoId == null) {
        futureCasos = api.getCasos(widget.investigadorId);
      }
    });
  }

  Future<void> _subirEvidencia() async {
    if (casoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un caso primero')),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) return;

    final descCtrl = TextEditingController();
    String tipo = 'foto';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Subir evidencia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: tipo,
              items: const [
                DropdownMenuItem(value: 'foto', child: Text('Foto')),
                DropdownMenuItem(value: 'video', child: Text('Video')),
                DropdownMenuItem(value: 'audio', child: Text('Audio')),
                DropdownMenuItem(
                    value: 'documento', child: Text('Documento')),
              ],
              onChanged: (v) => tipo = v ?? 'foto',
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
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
            child: const Text('Subir'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await api.subirEvidencia(
        casoId: casoSeleccionado!,
        profesionalId: widget.investigadorId,
        file: File(path),
        tipo: tipo,
        descripcion: descCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Evidencia subida')));
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
            child: Text('Caso #$id Â· $titulo'),
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
                futureEvidencias = api.getEvidencias(v);
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

  Widget _buildEvidencias() {
    if (casoSeleccionado == null) {
      return const Center(child: Text('Selecciona un caso.'));
    }

    return FutureBuilder<List<dynamic>>(
      future: futureEvidencias,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('No hay evidencias.'));
        }

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final e = items[i] as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text((e['tipo'] ?? '').toString()),
                  subtitle: Text(
                      (e['descripcion'] ?? '').toString().isEmpty
                          ? (e['archivo_url'] ?? '').toString()
                          : (e['descripcion'] ?? '').toString()),
                  trailing: const Icon(Icons.link),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text((e['archivo_url'] ?? '').toString()),
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
        title: const Text('Evidencias'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _subirEvidencia,
        child: const Icon(Icons.upload),
      ),
      body: Column(
        children: [
          if (widget.casoId == null) _buildSelector(),
          Expanded(child: _buildEvidencias()),
        ],
      ),
    );
  }
}
