import 'package:flutter/material.dart';

import '../api_service_perito.dart';

class ReporteFotograficoScreen extends StatefulWidget {
  final int peritoId;
  final int? casoId;

  const ReporteFotograficoScreen({
    super.key,
    required this.peritoId,
    this.casoId,
  });

  @override
  State<ReporteFotograficoScreen> createState() =>
      _ReporteFotograficoScreenState();
}

class _ReporteFotograficoScreenState extends State<ReporteFotograficoScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();

  String _clasificacion = 'lugar_de_hechos';

  @override
  void initState() {
    super.initState();
    _cargarReporte();
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _urlCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  void _cargarReporte() {
    _future = ApiServicePerito.getReporteFotografico(
      peritoId: widget.peritoId,
      casoId: widget.casoId,
    );
  }

  Future<void> _recargar() async {
    setState(_cargarReporte);
    await _future;
  }

  String _texto(
    Map<String, dynamic> item,
    List<String> keys, {
    String defecto = '-',
  }) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return defecto;
  }

  String _labelClasificacion(String value) {
    switch (value) {
      case 'lugar_de_hechos':
        return 'Lugar de hechos';
      case 'indicio':
        return 'Indicio';
      case 'lesion':
        return 'Lesión';
      case 'vehiculo':
        return 'Vehículo';
      case 'documento':
        return 'Documento';
      case 'objeto':
        return 'Objeto';
      case 'panoramica':
        return 'Panorámica';
      case 'acercamiento':
        return 'Acercamiento';
      case 'detalle':
        return 'Detalle';
      default:
        return value;
    }
  }

  Future<void> _crearFoto() async {
    _tituloCtrl.clear();
    _descripcionCtrl.clear();
    _urlCtrl.clear();
    _ubicacionCtrl.clear();

    _clasificacion = 'lugar_de_hechos';

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Agregar fotografía'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _clasificacion,
                      decoration: const InputDecoration(
                        labelText: 'Clasificación',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'lugar_de_hechos',
                          child: Text('Lugar de hechos'),
                        ),
                        DropdownMenuItem(
                          value: 'indicio',
                          child: Text('Indicio'),
                        ),
                        DropdownMenuItem(
                          value: 'lesion',
                          child: Text('Lesión'),
                        ),
                        DropdownMenuItem(
                          value: 'vehiculo',
                          child: Text('Vehículo'),
                        ),
                        DropdownMenuItem(
                          value: 'documento',
                          child: Text('Documento'),
                        ),
                        DropdownMenuItem(
                          value: 'objeto',
                          child: Text('Objeto'),
                        ),
                        DropdownMenuItem(
                          value: 'panoramica',
                          child: Text('Panorámica'),
                        ),
                        DropdownMenuItem(
                          value: 'acercamiento',
                          child: Text('Acercamiento'),
                        ),
                        DropdownMenuItem(
                          value: 'detalle',
                          child: Text('Detalle'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => _clasificacion = value);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tituloCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                      ),
                    ),
                    TextField(
                      controller: _descripcionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: _urlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'URL imagen',
                      ),
                    ),
                    TextField(
                      controller: _ubicacionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación',
                      ),
                    ),
                  ],
                ),
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
            );
          },
        );
      },
    );

    if (guardar != true) return;

    if (_tituloCtrl.text.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El título es obligatorio'),
        ),
      );
      return;
    }

    try {
      await ApiServicePerito.crearFotoReporte(
        payload: {
          'perito_id': widget.peritoId,
          if (widget.casoId != null) 'caso_id': widget.casoId,
          'titulo': _tituloCtrl.text.trim(),
          'descripcion': _descripcionCtrl.text.trim(),
          'imagen_url': _urlCtrl.text.trim(),
          'archivo_url': _urlCtrl.text.trim(),
          'ubicacion': _ubicacionCtrl.text.trim(),
          'clasificacion': _clasificacion,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fotografía registrada correctamente'),
        ),
      );

      await _recargar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar fotografía: $e'),
        ),
      );
    }
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 80),
        Icon(
          Icons.photo_library_outlined,
          size: 64,
          color: Colors.grey,
        ),
        SizedBox(height: 14),
        Center(
          child: Text(
            'No hay fotografías registradas.',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 6),
        Center(
          child: Text(
            'Agrega fotografías del lugar de hechos, indicios o detalles.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _imageBox(String url, Color gold) {
    if (url.isEmpty || url == '-') {
      return Container(
        color: gold.withOpacity(.10),
        child: Center(
          child: Icon(
            Icons.photo_outlined,
            size: 54,
            color: gold,
          ),
        ),
      );
    }

    return Image.network(
      url,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: gold.withOpacity(.10),
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 54,
              color: gold,
            ),
          ),
        );
      },
    );
  }

  Widget _fotoCard(Map<String, dynamic> foto) {
    final gold = Theme.of(context).primaryColor;

    final titulo = _texto(
      foto,
      [
        'titulo',
        'nombre',
        'clasificacion',
      ],
      defecto: 'Fotografía',
    );

    final clasificacion = _texto(
      foto,
      [
        'clasificacion',
        'tipo',
      ],
      defecto: 'detalle',
    );

    final descripcion = _texto(
      foto,
      [
        'descripcion',
        'observaciones',
        'detalle',
      ],
    );

    final ubicacion = _texto(
      foto,
      [
        'ubicacion',
        'lugar',
      ],
    );

    final fecha = _texto(
      foto,
      [
        'fecha',
        'fecha_registro',
        'created_at',
      ],
    );

    final url = _texto(
      foto,
      [
        'imagen_url',
        'archivo_url',
        'url',
      ],
      defecto: '',
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _imageBox(url, gold),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _labelClasificacion(clasificacion),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Ubicación: $ubicacion',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Fecha: $fecha',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte fotográfico'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearFoto,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Foto'),
      ),
      body: RefreshIndicator(
        onRefresh: _recargar,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 52,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Error al cargar reporte fotográfico:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            final fotos = snapshot.data ?? [];

            if (fotos.isEmpty) {
              return _emptyState();
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: fotos.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 330,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .72,
              ),
              itemBuilder: (context, index) {
                return _fotoCard(fotos[index]);
              },
            );
          },
        ),
      ),
    );
  }
}