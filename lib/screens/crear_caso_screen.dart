import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrearCasoScreen extends StatefulWidget {
  const CrearCasoScreen({super.key});

  @override
  State<CrearCasoScreen> createState() => _CrearCasoScreenState();
}

class _CrearCasoScreenState extends State<CrearCasoScreen> {
  int? idAbogado;
  List<Map<String, dynamic>> clientes = [];
  int? clienteSeleccionado;
  String estadoSeleccionado = 'pendiente';
  PlatformFile? archivoSeleccionado;

  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    idAbogado = prefs.getInt('id') ?? 0;

    final respuesta = await http.get(Uri.parse('http://192.168.100.9/COLEMEX/api/clientes.php'));
    final datos = json.decode(respuesta.body);
    if (datos['status'] == 'success') {
      if (!mounted) return;
      final List<dynamic> clientesRaw = datos['clientes'];
      setState(() {
        clientes = clientesRaw.map((c) => Map<String, dynamic>.from(c)).toList();
      });
    }
  }

  Future<void> seleccionarArchivo() async {
    final resultado = await FilePicker.platform.pickFiles(withData: true);
    if (resultado != null && resultado.files.isNotEmpty) {
      setState(() {
        archivoSeleccionado = resultado.files.first;
      });
      print('Archivo seleccionado: ${archivoSeleccionado!.name}');
    } else {
      print('No se seleccionó ningún archivo');
    }
  }

  Future<void> guardarCaso() async {
    if (clienteSeleccionado == null || idAbogado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faltan datos obligatorios')),
      );
      return;
    }

    final uri = Uri.parse('http://192.168.100.9/COLEMEX/api/guardar-caso.php');
    final request = http.MultipartRequest('POST', uri)
      ..fields['cliente_id'] = clienteSeleccionado.toString()
      ..fields['titulo'] = tituloController.text
      ..fields['descripcion'] = descripcionController.text
      ..fields['estado'] = estadoSeleccionado
      ..fields['id_abogado'] = idAbogado.toString();

    if (archivoSeleccionado != null && archivoSeleccionado!.bytes != null) {
      print('Adjuntando archivo: ${archivoSeleccionado!.name}');
      request.files.add(http.MultipartFile.fromBytes(
        'documento',
        archivoSeleccionado!.bytes!,
        filename: archivoSeleccionado!.name,
      ));
    } else {
      print('No se seleccionó ningún archivo o no tiene bytes');
    }

    try {
      final respuesta = await request.send();
      final respuestaTexto = await respuesta.stream.bytesToString();
      final datos = json.decode(respuestaTexto);

      print('Respuesta completa: $respuestaTexto');

      if (!mounted) return;
      if (datos['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Caso guardado correctamente')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${datos['message']}')),
        );
      }
    } catch (e) {
      print('Error al enviar caso: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con el servidor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo caso'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField<int>(
              value: clienteSeleccionado,
              items: clientes.map<DropdownMenuItem<int>>((cliente) {
                return DropdownMenuItem<int>(
                  value: int.parse(cliente['id'].toString()),
                  child: Text(cliente['nombre'].toString()),
                );
              }).toList(),
              onChanged: (valor) => setState(() => clienteSeleccionado = valor),
              decoration: const InputDecoration(labelText: 'Selecciona cliente'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(labelText: 'Título del caso'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: estadoSeleccionado,
              items: ['pendiente', 'en proceso', 'finalizado'].map((estado) {
                return DropdownMenuItem(value: estado, child: Text(estado));
              }).toList(),
              onChanged: (valor) => setState(() => estadoSeleccionado = valor!),
              decoration: const InputDecoration(labelText: 'Estado'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: seleccionarArchivo,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
              child: Text(
                archivoSeleccionado == null
                    ? 'Seleccionar documento'
                    : 'Documento: ${archivoSeleccionado!.name}',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: guardarCaso,
              icon: const Icon(Icons.save),
              label: const Text('Guardar caso'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}