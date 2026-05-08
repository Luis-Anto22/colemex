import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/investigador_api.dart';

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
  bool subiendo = false;

  @override
  void initState() {
    super.initState();

    api = InvestigadorApi(ApiClient());

    if (widget.casoId != null) {
      casoSeleccionado = widget.casoId;
      futureEvidencias = api.getEvidencias(
        casoId: casoSeleccionado!,
        profesionalId: widget.investigadorId,
      );
    } else {
      futureCasos = api.getCasos(widget.investigadorId);
    }
  }

  Future<void> _reload() async {
    setState(() {
      if (casoSeleccionado != null) {
        futureEvidencias = api.getEvidencias(
          casoId: casoSeleccionado!,
          profesionalId: widget.investigadorId,
        );
      } else {
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

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final archivoSeleccionado = result.files.single;

    if (archivoSeleccionado.bytes == null &&
        (archivoSeleccionado.path == null || archivoSeleccionado.path!.isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo leer el archivo seleccionado')),
      );
      return;
    }

    final descCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Subir evidencia fotográfica'),
          content: TextField(
            controller: descCtrl,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText: 'Ej. Foto del lugar de los hechos',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.upload),
              label: const Text('Subir'),
            ),
          ],
        );
      },
    );

    final descripcion = descCtrl.text.trim();
    descCtrl.dispose();

    if (ok != true) return;

    try {
      setState(() {
        subiendo = true;
      });

      await api.subirEvidencia(
        casoId: casoSeleccionado!,
        profesionalId: widget.investigadorId,
        file: archivoSeleccionado,
        descripcion: descripcion,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evidencia subida correctamente')),
      );

      await _reload();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          subiendo = false;
        });
      }
    }
  }

  Future<void> _eliminarEvidencia(int evidenciaId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Eliminar evidencia'),
          content: const Text('¿Seguro que deseas eliminar esta evidencia?'),
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
        );
      },
    );

    if (confirmar != true) return;

    try {
      await api.eliminarEvidencia(evidenciaId: evidenciaId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evidencia eliminada')),
      );

      await _reload();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
            child: Text('No hay casos para seleccionar.'),
          );
        }

        final items = casos.map<DropdownMenuItem<int>>((c) {
          final map = Map<String, dynamic>.from(c as Map);
          final id = int.tryParse(map['id'].toString()) ?? 0;
          final titulo = (map['titulo'] ?? 'Sin título').toString();

          return DropdownMenuItem<int>(
            value: id,
            child: Text(
              'Caso #$id - $titulo',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(12),
          child: DropdownButtonFormField<int>(
            initialValue: casoSeleccionado,
            items: items,
            isExpanded: true,
            onChanged: (v) {
              if (v == null) return;

              setState(() {
                casoSeleccionado = v;
                futureEvidencias = api.getEvidencias(
                  casoId: v,
                  profesionalId: widget.investigadorId,
                );
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
      return const Center(
        child: Text('Selecciona un caso.'),
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: futureEvidencias,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error: ${snap.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final items = snap.data ?? [];

        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No hay evidencias.')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final e = Map<String, dynamic>.from(items[i] as Map);

              final id = int.tryParse(e['id'].toString()) ?? 0;
              final tipo = (e['tipo'] ?? 'imagen').toString();
              final descripcion = (e['descripcion'] ?? '').toString();
              final archivoUrl = (e['archivo_url'] ?? '').toString();
              final creadoEn = (e['creado_en'] ?? '').toString();

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.photo),
                  title: Text(
                    descripcion.isEmpty ? 'Evidencia fotográfica' : descripcion,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Tipo: $tipo\n${creadoEn.isEmpty ? archivoUrl : creadoEn}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: id <= 0 ? null : () => _eliminarEvidencia(id),
                  ),
                  onTap: () {
                    if (archivoUrl.isEmpty) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(archivoUrl)),
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
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: subiendo ? null : _subirEvidencia,
        child: subiendo
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.upload),
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