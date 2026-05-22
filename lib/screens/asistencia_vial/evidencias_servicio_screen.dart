import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services/api_client.dart';

class EvidenciasServicioScreen extends StatefulWidget {
  final int servicioId;

  const EvidenciasServicioScreen({
    super.key,
    required this.servicioId,
  });

  @override
  State<EvidenciasServicioScreen> createState() =>
      _EvidenciasServicioScreenState();
}

class _EvidenciasServicioScreenState extends State<EvidenciasServicioScreen> {
  final ApiClient client = ApiClient();

  bool cargando = true;
  bool subiendo = false;

  int profesionalId = 0;
  List<dynamic> evidencias = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    profesionalId = prefs.getInt('id') ?? 0;
    await _cargar();
  }

  Future<void> _cargar() async {
    try {
      final res = await client.get(
        '/asistencia-vial/evidencias',
        params: {
          'servicio_id': widget.servicioId,
        },
      );

      if (!mounted) return;

      setState(() {
        evidencias = res['data'] is List ? res['data'] as List<dynamic> : [];
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _txt(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  Color _tipoColor(String tipo) {
    switch (tipo) {
      case 'antes':
        return Colors.orange;
      case 'durante':
        return Colors.blue;
      case 'despues':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _subir(String tipo) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final PlatformFile file = result.files.first;

    setState(() {
      subiendo = true;
    });

    try {
      final res = await client.postMultipart(
        '/asistencia-vial/evidencias',
        fields: {
          'servicio_id': widget.servicioId.toString(),
          'profesional_id': profesionalId.toString(),
          'tipo': tipo,
        },
        file: file,
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al subir evidencia');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evidencia subida correctamente')),
      );

      await _cargar();
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

  Future<void> _eliminar(int id) async {
    if (id <= 0) return;

    try {
      final res = await client.delete('/asistencia-vial/evidencias/$id');

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al eliminar');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evidencia eliminada')),
      );

      await _cargar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _card(Map<String, dynamic> item) {
    final id = int.tryParse(item['id']?.toString() ?? '') ?? 0;
    final tipo = _txt(item['tipo'], 'antes');
    final url = _txt(item['archivo_url']);
    final descripcion = _txt(item['descripcion']);
    final color = _tipoColor(tipo);

    return Card(
      color: const Color(0xFF1B2028),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tipo.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _eliminar(id),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (url.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  url,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 180,
                      alignment: Alignment.center,
                      color: Colors.black26,
                      child: const Text(
                        'No se pudo cargar la imagen',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                ),
              ),
            if (descripcion.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                descripcion,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _boton({
    required String tipo,
    required String label,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: subiendo ? null : () => _subir(tipo),
      icon: Icon(icon),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencias del servicio'),
      ),
      backgroundColor: const Color(0xFF12161C),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Icon(Icons.photo_camera, size: 60, color: gold),
                  const SizedBox(height: 12),
                  const Text(
                    'Evidencias',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _boton(
                        tipo: 'antes',
                        label: 'Antes',
                        icon: Icons.camera_alt_outlined,
                      ),
                      _boton(
                        tipo: 'durante',
                        label: 'Durante',
                        icon: Icons.build,
                      ),
                      _boton(
                        tipo: 'despues',
                        label: 'Después',
                        icon: Icons.check_circle_outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  if (evidencias.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(
                        child: Text(
                          'No hay evidencias registradas.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  else
                    ...evidencias.map((e) {
                      final item = e is Map<String, dynamic>
                          ? e
                          : Map<String, dynamic>.from(e as Map);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _card(item),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}