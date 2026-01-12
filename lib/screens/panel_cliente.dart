import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

class PanelCliente extends StatefulWidget {
  const PanelCliente({super.key});

  @override
  State<PanelCliente> createState() => _PanelClienteState();
}

class _PanelClienteState extends State<PanelCliente> {
  String nombreUsuario = '';
  String perfilUsuario = '';
  int idUsuario = 0;
  bool cargando = true;
  List<Map<String, dynamic>> listaCasos = [];

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    nombreUsuario = prefs.getString('nombre') ?? 'Usuario';
    perfilUsuario = prefs.getString('perfil') ?? 'cliente';
    idUsuario = prefs.getInt('id') ?? 0;

    debugPrint('ID del cliente cargado: $idUsuario');
    await cargarCasos();
  }

  Future<void> cargarCasos() async {
    final url = Uri.parse('https://corporativolegaldigital.com/api/panel-cliente.php');
    try {
      final respuesta = await http.post(url, body: {
        'id_cliente': idUsuario.toString(),
      });

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        if (datos is Map &&
            datos['status'] == 'success' &&
            datos['casos'] != null &&
            datos['casos'] is List) {
          listaCasos = List<Map<String, dynamic>>.from(datos['casos']);
        } else {
          listaCasos = [];
        }
      } else {
        listaCasos = [];
      }
    } catch (e) {
      debugPrint('Error al cargar casos: $e');
      listaCasos = [];
    }

    if (mounted) {
      setState(() {
        cargando = false;
      });
    }
  }

  void abrirDocumento(String ruta) async {
    final url = Uri.parse('https://corporativolegaldigital.com/$ruta'.replaceAll('../', ''));
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el documento')),
      );
    }
  }

  Future<void> subirEvidencia(int idCaso) async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
      withData: true,
    );

    if (resultado == null || resultado.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ No se seleccionó ningún archivo')),
      );
      return;
    }

    final archivo = resultado.files.first;
    final prefs = await SharedPreferences.getInstance();
    final idCliente = prefs.getInt('id') ?? 0;

    final uri = Uri.parse('https://corporativolegaldigital.com/api/subir-documento-cliente.php');
    final request = http.MultipartRequest('POST', uri)
      ..fields['id_caso'] = idCaso.toString()
      ..fields['id_cliente'] = idCliente.toString()
      ..fields['descripcion'] = archivo.name;

    if (archivo.bytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'documento',
        archivo.bytes!,
        filename: archivo.name,
      ));
    } else if (archivo.path != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'documento',
        archivo.path!,
        filename: archivo.name,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ No se pudo leer el archivo')),
      );
      return;
    }

    try {
      final response = await request.send();
      final respuestaFinal = await http.Response.fromStream(response);
      final datos = json.decode(respuestaFinal.body);

      if (datos['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Evidencia subida correctamente')),
        );
        await cargarCasos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${datos['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error de conexión con el servidor')),
      );
    }
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final bool tieneCasos = listaCasos.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4AF37),
        title: Text(
          'Bienvenido, $nombreUsuario',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: cerrarSesion,
          ),
        ],
      ),
      body: SafeArea(
        child: cargando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/buscar-abogado'),
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar abogado'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      ),
                    ),
                  ),
                  Expanded(
                    child: !tieneCasos
                        ? const Center(child: Text('No hay casos registrados'))
                        : ListView.builder(
                            itemCount: listaCasos.length,
                            itemBuilder: (context, index) {
                              final caso = listaCasos[index];
                              final documentos = caso['documentos'] as List<dynamic>? ?? [];

                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(caso['titulo'] ?? 'Sin título',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('Estado: ${caso['estado'] ?? 'Desconocido'}'),
                                      Text('Descripción: ${caso['descripcion'] ?? 'Sin descripción'}'),
                                      const SizedBox(height: 8),
                                      documentos.isNotEmpty
                                          ? Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: documentos.map((doc) {
                                                final ruta = doc['archivo'];
                                                final nombre = ruta.toString().split('/').last;
                                                final descripcion = doc['descripcion'] ?? 'Sin descripción';
                                                return GestureDetector(
                                                  onTap: () => abrirDocumento(ruta),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                                    child: Text(
                                                      '📄 $descripcion → $nombre',
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        decoration: TextDecoration.underline,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            )
                                          : const Text('Documentos: Ninguno registrado'),
                                      const SizedBox(height: 8),
                                      Text(caso['fecha_actualizacion'] ?? '',
                                          style: const TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton.icon(
                                          onPressed: () => subirEvidencia(caso['id']),
                                          icon: const Icon(Icons.upload_file),
                                          label: const Text('Subir evidencia'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFD4AF37),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}