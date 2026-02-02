import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../services/api_client.dart';
import '../../../services/valuador_api.dart';
import 'dart:io';

class DictamenesReportesScreen extends StatefulWidget {
  const DictamenesReportesScreen({super.key});

  @override
  State<DictamenesReportesScreen> createState() =>
      _DictamenesReportesScreenState();
}

class _DictamenesReportesScreenState extends State<DictamenesReportesScreen> {
  final int valuadorId = 1; // TODO: real
  final int casoId = 1;     // TODO: real

  late final ValuadorApi api;
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    api = ValuadorApi(ApiClient());
    future = api.getReportes(casoId);
  }

  Future<void> _reload() async {
    setState(() {
      future = api.getReportes(casoId);
    });
  }

  Future<void> _subirReporte() async {
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
          decoration: const InputDecoration(labelText: 'Descripción'),
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
      await api.subirReporte(
        casoId: casoId,
        valuadorId: valuadorId,
        file: File(path),
        descripcion: descCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reporte subido')));
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
        title: const Text('Dictámenes / reportes'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _subirReporte,
        child: const Icon(Icons.upload_file),
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
                return Card(
                  child: ListTile(
                    title:
                        Text((r['descripcion'] ?? 'Reporte').toString()),
                    subtitle:
                        Text((r['archivo_url'] ?? '').toString()),
                    trailing: const Icon(Icons.link),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                (r['archivo_url'] ?? '').toString())),
                      );
                    },
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
