import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/valuador_api.dart';

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

  bool uploading = false;

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
      } else {
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

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final PlatformFile archivoSeleccionado = result.files.single;

    if (archivoSeleccionado.bytes == null &&
        (archivoSeleccionado.path == null ||
            archivoSeleccionado.path!.isEmpty)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo leer el archivo seleccionado'),
        ),
      );
      return;
    }

    final descCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Subir foto'),
          content: TextField(
            controller: descCtrl,
            maxLength: 200,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText: 'Ej. Fachada, interiores, daños, ubicación...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Subir'),
            ),
          ],
        );
      },
    );

    final descripcion = descCtrl.text.trim();
    descCtrl.dispose();

    if (ok != true) return;

    setState(() {
      uploading = true;
    });

    try {
      await api.subirFoto(
        casoId: casoSeleccionado!,
        valuadorId: widget.valuadorId,
        file: archivoSeleccionado,
        descripcion: descripcion,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto subida correctamente')),
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
          uploading = false;
        });
      }
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
          final map = Map<String, dynamic>.from(c as Map);

          final rawId = map['caso_id'] ?? map['id'];
          final id = int.tryParse(rawId.toString()) ?? 0;

          final titulo = (map['titulo'] ??
                  map['servicio'] ??
                  map['tipo_servicio'] ??
                  'Sin título')
              .toString();

          final cliente = _obtenerNombreCliente(map);

          return DropdownMenuItem<int>(
            value: id,
            child: Text(
              'Caso #$id - $cliente - $titulo',
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
      return const Center(
        child: Text('Selecciona un caso.'),
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: futureFotos,
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
                Center(child: Text('No hay fotos todavía.')),
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
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final f = Map<String, dynamic>.from(items[i] as Map);

              final url = (f['archivo_url'] ??
                      f['archivo'] ??
                      f['url'] ??
                      f['ruta'] ??
                      '')
                  .toString();

              final desc = (f['descripcion'] ?? 'Foto').toString();

              final fecha = (f['creado_en'] ??
                      f['created_at'] ??
                      f['fecha'] ??
                      '')
                  .toString();

              return Card(
                elevation: 3,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (url.isNotEmpty)
                      Image.network(
                        url,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 46,
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        height: 160,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 46,
                          ),
                        ),
                      ),
                    ListTile(
                      leading: const Icon(Icons.image),
                      title: Text(
                        desc.isEmpty ? 'Foto' : desc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        fecha.isEmpty ? url : fecha,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _obtenerNombreCliente(Map<String, dynamic> caso) {
    final cliente = caso['cliente'];

    if (cliente is Map) {
      return (cliente['nombre'] ??
              cliente['nombre_completo'] ??
              'Cliente sin nombre')
          .toString();
    }

    return (caso['cliente_nombre'] ??
            caso['nombre_cliente'] ??
            caso['nombre'] ??
            cliente ??
            'Cliente sin nombre')
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencia fotográfica'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: uploading ? null : _subirFoto,
        child: uploading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.add_a_photo),
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