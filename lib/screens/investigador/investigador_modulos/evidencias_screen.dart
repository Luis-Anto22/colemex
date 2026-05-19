import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
        (archivoSeleccionado.path == null ||
            archivoSeleccionado.path!.isEmpty)) {
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
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
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

  Future<void> _abrirEnNavegador(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL inválida')),
      );
      return;
    }

    final abierto = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!abierto && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la imagen')),
      );
    }
  }

  Future<void> _compartirEnlace({
    required String url,
    required String descripcion,
  }) async {
    final texto = descripcion.trim().isEmpty
        ? 'Evidencia fotográfica:\n$url'
        : '${descripcion.trim()}\n$url';

    try {
      await Share.share(texto);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al compartir enlace: $e')),
      );
    }
  }

  Future<void> _copiarEnlace(String url) async {
    await Clipboard.setData(ClipboardData(text: url));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enlace copiado al portapapeles')),
    );
  }

  Future<void> _compartirImagenComoArchivo({
    required String url,
    required String descripcion,
  }) async {
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay imagen para compartir')),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo descargar la imagen. Se compartirá el enlace.'),
          ),
        );

        await _compartirEnlace(url: url, descripcion: descripcion);
        return;
      }

      final Uint8List bytes = response.bodyBytes;
      final nombreArchivo = _obtenerNombreArchivoDesdeUrl(url);
      final mimeType = _obtenerMimeType(nombreArchivo);

      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            name: nombreArchivo,
            mimeType: mimeType,
          ),
        ],
        text: descripcion.trim().isEmpty
            ? 'Evidencia fotográfica'
            : descripcion.trim(),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo compartir como imagen. Se compartirá el enlace.'),
        ),
      );

      await _compartirEnlace(url: url, descripcion: descripcion);
    }
  }

  Future<void> _mostrarOpcionesCompartir({
    required String url,
    required String descripcion,
  }) async {
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay enlace disponible')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 8, 18, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Compartir evidencia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.image_rounded),
                  ),
                  title: const Text('Compartir imagen'),
                  subtitle: const Text(
                    'Enviar como archivo a WhatsApp, Facebook, Drive, etc.',
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _compartirImagenComoArchivo(
                      url: url,
                      descripcion: descripcion,
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.share_rounded),
                  ),
                  title: const Text('Compartir enlace'),
                  subtitle: const Text('Enviar solo el link público'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _compartirEnlace(
                      url: url,
                      descripcion: descripcion,
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.copy_rounded),
                  ),
                  title: const Text('Copiar enlace'),
                  subtitle: const Text('Guardar link en portapapeles'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _copiarEnlace(url);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.open_in_new_rounded),
                  ),
                  title: const Text('Abrir / descargar'),
                  subtitle: const Text('Abrir imagen en navegador'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _abrirEnNavegador(url);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _obtenerNombreArchivoDesdeUrl(String url) {
    try {
      final uri = Uri.parse(url);

      if (uri.pathSegments.isNotEmpty) {
        final nombre = uri.pathSegments.last;

        if (nombre.trim().isNotEmpty) {
          return nombre;
        }
      }
    } catch (_) {}

    return 'evidencia.jpg';
  }

  String _obtenerMimeType(String nombreArchivo) {
    final lower = nombreArchivo.toLowerCase();

    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.jpg')) return 'image/jpeg';

    return 'image/jpeg';
  }

  Future<void> _abrirVistaPrevia({
    required int id,
    required String url,
    required String descripcion,
    required String creadoEn,
  }) async {
    if (url.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return _VistaPreviaEvidenciaScreen(
            evidenciaId: id,
            url: url,
            descripcion: descripcion,
            creadoEn: creadoEn,
            onDescargar: () => _abrirEnNavegador(url),
            onCompartir: () async {
              await _mostrarOpcionesCompartir(
                url: url,
                descripcion: descripcion,
              );
            },
            onEliminar: () async {
              Navigator.pop(context);
              await _eliminarEvidencia(id);
            },
          );
        },
      ),
    );
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

          final rawId = map['id'] ?? map['caso_id'];
          final id = int.tryParse(rawId.toString()) ?? 0;

          final titulo = (map['titulo'] ??
                  map['servicio'] ??
                  map['tipo_servicio'] ??
                  'Sin título')
              .toString();

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
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (_, i) {
              final e = Map<String, dynamic>.from(items[i] as Map);

              final id = int.tryParse(e['id'].toString()) ?? 0;
              final descripcion = (e['descripcion'] ?? '').toString();

              final archivoUrl = (e['archivo_url'] ??
                      e['archivo'] ??
                      e['url'] ??
                      e['ruta'] ??
                      '')
                  .toString();

              final creadoEn = (e['creado_en'] ??
                      e['created_at'] ??
                      e['fecha'] ??
                      '')
                  .toString();

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  _abrirVistaPrevia(
                    id: id,
                    url: archivoUrl,
                    descripcion: descripcion,
                    creadoEn: creadoEn,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Expanded(
                        child: archivoUrl.isEmpty
                            ? Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                              )
                            : Image.network(
                                archivoUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;

                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(Icons.broken_image),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                descripcion.isEmpty
                                    ? 'Evidencia fotográfica'
                                    : descripcion,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.delete_outline),
                              onPressed:
                                  id <= 0 ? null : () => _eliminarEvidencia(id),
                            ),
                          ],
                        ),
                      ),
                    ],
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
      backgroundColor: const Color(0xFFF4F6FA),
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

class _VistaPreviaEvidenciaScreen extends StatefulWidget {
  final int evidenciaId;
  final String url;
  final String descripcion;
  final String creadoEn;
  final VoidCallback onDescargar;
  final Future<void> Function() onCompartir;
  final Future<void> Function() onEliminar;

  const _VistaPreviaEvidenciaScreen({
    required this.evidenciaId,
    required this.url,
    required this.descripcion,
    required this.creadoEn,
    required this.onDescargar,
    required this.onCompartir,
    required this.onEliminar,
  });

  @override
  State<_VistaPreviaEvidenciaScreen> createState() =>
      _VistaPreviaEvidenciaScreenState();
}

class _VistaPreviaEvidenciaScreenState
    extends State<_VistaPreviaEvidenciaScreen> {
  bool compartiendoLocal = false;

  Future<void> _compartir() async {
    setState(() {
      compartiendoLocal = true;
    });

    try {
      await widget.onCompartir();
    } finally {
      if (mounted) {
        setState(() {
          compartiendoLocal = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final descripcion = widget.descripcion.trim();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Vista previa'),
        actions: [
          IconButton(
            tooltip: 'Abrir / descargar',
            onPressed: widget.onDescargar,
            icon: const Icon(Icons.download_rounded),
          ),
          IconButton(
            tooltip: 'Compartir',
            onPressed: compartiendoLocal ? null : _compartir,
            icon: compartiendoLocal
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.share_rounded),
          ),
          IconButton(
            tooltip: 'Eliminar',
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text('Eliminar evidencia'),
                    content: const Text(
                      '¿Seguro que deseas eliminar esta imagen?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context, true),
                        icon: const Icon(Icons.delete),
                        label: const Text('Eliminar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              );

              if (confirmar == true) {
                await widget.onEliminar();
              }
            },
            icon: const Icon(Icons.delete_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 5,
              child: Center(
                child: Image.network(
                  widget.url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (_, __, ___) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 60,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No se pudo cargar la imagen',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.black.withValues(alpha: 0.78),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    descripcion.isEmpty
                        ? 'Evidencia fotográfica'
                        : descripcion,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  if (widget.creadoEn.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      widget.creadoEn,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'Puedes compartir la imagen, compartir el enlace o copiarlo.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}