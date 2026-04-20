import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/valuador_api.dart';

class DictamenesReportesScreen extends StatefulWidget {
  final int valuadorId;
  final int? casoId;

  const DictamenesReportesScreen({
    super.key,
    required this.valuadorId,
    this.casoId,
  });

  @override
  State<DictamenesReportesScreen> createState() =>
      _DictamenesReportesScreenState();
}

class _DictamenesReportesScreenState extends State<DictamenesReportesScreen> {
  late final ValuadorApi api;

  Future<List<dynamic>>? futureReportes;
  Future<List<dynamic>>? futureCasos;

  int? casoSeleccionado;

  @override
  void initState() {
    super.initState();

    api = ValuadorApi(ApiClient());

    if (widget.casoId != null) {
      casoSeleccionado = widget.casoId;
      futureReportes = api.getReportes(casoSeleccionado!);
    } else {
      futureCasos = api.getAvaluos(widget.valuadorId);
    }
  }

  Future<void> _reload() async {
    setState(() {
      if (casoSeleccionado != null) {
        futureReportes = api.getReportes(casoSeleccionado!);
      } else {
        futureCasos = api.getAvaluos(widget.valuadorId);
      }
    });
  }

  Future<void> _subirReporte() async {
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

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Subir dictamen / reporte'),
        content: TextField(
          controller: descCtrl,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            border: OutlineInputBorder(),
          ),
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

    if (ok != true) {
      descCtrl.dispose();
      return;
    }

    try {
      await api.subirReporte(
        casoId: casoSeleccionado!,
        valuadorId: widget.valuadorId,
        file: File(path),
        descripcion: descCtrl.text.trim(),
      );

      descCtrl.dispose();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte subido correctamente')),
      );

      await _reload();
    } catch (e) {
      descCtrl.dispose();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir: $e')),
      );
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
            child: Text('No hay casos disponibles.'),
          );
        }

        final items = casos.map<DropdownMenuItem<int>>((c) {
          final id = int.tryParse((c['caso_id'] ?? '').toString()) ?? 0;
          final titulo = (c['titulo'] ?? 'Sin título').toString();

          return DropdownMenuItem<int>(
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
                futureReportes = api.getReportes(v);
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

  Widget _buildReportes() {
    if (casoSeleccionado == null) {
      return const Center(
        child: Text('Selecciona un caso para ver los reportes.'),
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: futureReportes,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final items = snap.data ?? [];

        if (items.isEmpty) {
          return const Center(child: Text('No hay reportes todavía.'));
        }

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final r = items[i] as Map<String, dynamic>;
              final descripcion = (r['descripcion'] ?? 'Reporte').toString();
              final archivo = (r['archivo_url'] ?? '').toString();

              return Card(
                child: ListTile(
                  title: Text(descripcion),
                  subtitle: Text(
                    archivo,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.insert_drive_file),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(archivo)),
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
        title: const Text('Dictámenes / reportes'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _subirReporte,
        child: const Icon(Icons.upload_file),
      ),
      body: Column(
        children: [
          if (widget.casoId == null) _buildSelector(),
          Expanded(child: _buildReportes()),
        ],
      ),
    );
  }
}