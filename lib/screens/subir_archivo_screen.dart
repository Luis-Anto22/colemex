import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SubirArchivoScreen extends StatefulWidget {
  const SubirArchivoScreen({super.key});

  @override
  State<SubirArchivoScreen> createState() => _SubirArchivoScreenState();
}

class _SubirArchivoScreenState extends State<SubirArchivoScreen> {
  Map<String, dynamic>? datos;
  PlatformFile? archivoSeleccionado;
  final descripcionController = TextEditingController();
  bool cargando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      datos = args;
      print('🟢 Argumentos recibidos: $datos');
    } else {
      print('❌ Argumentos inválidos: $args');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ No se recibieron los datos del caso')),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      });
    }
  }

  Future<void> seleccionarArchivo() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'docx'],
      withData: true,
    );

    if (resultado != null && resultado.files.isNotEmpty) {
      setState(() => archivoSeleccionado = resultado.files.first);
      print('📁 Archivo seleccionado: ${archivoSeleccionado!.name}');
    }
  }

  Future<void> subirArchivo() async {
    if (archivoSeleccionado == null || descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Selecciona un archivo y escribe una descripción')),
      );
      return;
    }

    final idCaso = datos?['id_caso'];
    if (idCaso == null || idCaso.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ ID de caso no válido')),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final idAbogado = prefs.getInt('id') ?? 0;

      final uri = Uri.parse('http://192.168.100.9/COLEMEX/api/subir-documento.php');
      final request = http.MultipartRequest('POST', uri)
        ..fields['id_caso'] = idCaso.toString()
        ..fields['id_abogado'] = idAbogado.toString()
        ..fields['descripcion'] = descripcionController.text.trim();

      if (kIsWeb) {
        if (archivoSeleccionado?.bytes == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ No se pudo leer el archivo en Web')),
          );
          setState(() => cargando = false);
          return;
        }

        request.files.add(http.MultipartFile.fromBytes(
          'documento',
          archivoSeleccionado!.bytes!,
          filename: archivoSeleccionado!.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'documento',
          archivoSeleccionado!.path!,
          filename: archivoSeleccionado!.name,
        ));
      }

      final response = await request.send().timeout(const Duration(seconds: 15));
      final respuestaFinal = await http.Response.fromStream(response);

      print('🟢 Respuesta cruda: ${respuestaFinal.body}');
      final datosRespuesta = json.decode(respuestaFinal.body);

      if (datosRespuesta['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Documento subido correctamente')),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context, true);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${datosRespuesta['message']}')),
        );
      }
    } catch (e) {
      print('❌ Error de red: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error de conexión con el servidor')),
      );
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Documento al Caso'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    archivoSeleccionado?.name ?? 'Ningún archivo seleccionado',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: seleccionarArchivo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                  ),
                  child: const Text('Seleccionar archivo'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción del documento',
                hintText: 'Ej. Contrato firmado',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: cargando ? null : subirArchivo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Subir archivo'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}