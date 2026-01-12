import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class PanelAbogado extends StatefulWidget {
  const PanelAbogado({super.key});

  @override
  State<PanelAbogado> createState() => _PanelAbogadoState();
}

class _PanelAbogadoState extends State<PanelAbogado> {
  String nombreUsuario = '';
  String perfilUsuario = '';
  int idAbogado = 0;
  List<Map<String, dynamic>>? listaCasos;
  String mensajeError = '';

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    nombreUsuario = prefs.getString('nombre') ?? 'Usuario';
    perfilUsuario = prefs.getString('perfil') ?? 'abogado';
    idAbogado = prefs.getInt('id') ?? 0;

    print('🟢 ID abogado cargado: $idAbogado');

    if (idAbogado > 0) {
      await cargarCasos();
    } else {
      setState(() {
        mensajeError = 'ID de abogado no válido.';
      });
    }
  }

  Future<void> cargarCasos() async {
    print('📡 Ejecutando cargarCasos con ID: $idAbogado');

    try {
      final respuesta = await http.post(
        Uri.parse('https://corporativolegaldigital.com/api/panel-abogado.php'),
        body: {'id_abogado': idAbogado.toString()},
      );

      print('📨 Código: ${respuesta.statusCode}');
      print('📨 Respuesta: ${respuesta.body}');

      final datos = json.decode(respuesta.body);

      if (datos['status'] == 'success' && datos['casos'] is List) {
        setState(() {
          listaCasos = List<Map<String, dynamic>>.from(datos['casos']);
        });
      } else {
        setState(() {
          mensajeError = datos['message'] ?? 'Error desconocido.';
          listaCasos = [];
        });
      }
    } catch (e) {
      print('❌ Error al conectar: $e');
      setState(() {
        mensajeError = 'Error de conexión con el servidor.';
        listaCasos = [];
      });
    }
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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

  void confirmarEliminacion(int idCaso) async {
    final prefs = await SharedPreferences.getInstance();
    final idAbogado = prefs.getInt('id') ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar caso?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final respuesta = await http.post(
                Uri.parse('https://corporativolegaldigital.com/api/eliminar-caso.php'),
                body: {
                  'id_caso': idCaso.toString(),
                  'id_abogado': idAbogado.toString(),
                },
              );
              final datos = json.decode(respuesta.body);
              if (datos['status'] == 'success') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Caso eliminado correctamente')),
                );
                await cargarCasos();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Error: ${datos['message']}')),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4AF37),
        title: Text(
          'Bienvenido, Lic. $nombreUsuario',
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
        child: Column(
          children: [
            // 🔹 Botón para registrar ubicación del despacho (siempre visible)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final idAbogado = prefs.getInt('id') ?? 0;

                  if (idAbogado > 0) {
                    Navigator.pushNamed(
                      context,
                      '/ubicacion-despacho',
                      arguments: {'id': idAbogado},
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ No se encontró el ID del abogado'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.location_on),
                label: const Text('Registrar ubicación del despacho'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            // 🔹 Lista de casos o mensaje
            Expanded(
              child: listaCasos == null
                  ? const Center(child: CircularProgressIndicator())
                  : listaCasos!.isEmpty
                      ? Center(
                          child: Text(
                            mensajeError.isNotEmpty ? mensajeError : 'No hay casos asignados.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: listaCasos!.length,
                          itemBuilder: (context, index) {
                            final caso = listaCasos![index];
                            final documentos = caso['documentos'] as List<dynamic>? ?? [];

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      caso['titulo'] ?? 'Sin título',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Descripción: ${caso['descripcion'] ?? 'Sin descripción'}'),
                                    Text('Estado: ${caso['estado'] ?? 'Sin estado'}'),
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          caso['fecha_actualizacion'] ?? '',
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue),
                                              tooltip: 'Editar caso',
                                              onPressed: () {
                                                Navigator.pushNamed(context, '/editar-caso', arguments: caso);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.upload_file, color: Colors.orange),
                                              tooltip: 'Subir documento',
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/subir-documento',
                                                  arguments: {
                                                    'id_caso': caso['id'],
                                                    'id_abogado': idAbogado,
                                                  },
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              tooltip: 'Eliminar caso',
                                              onPressed: () => confirmarEliminacion(caso['id']),
                                            ),
                                          ],
                                        ),
                                      ],
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4AF37),
        onPressed: () {
          Navigator.pushNamed(context, '/crear-caso');
        },
        child: const Icon(Icons.add),
        tooltip: 'Crear nuevo caso',
      ),
    );
  }
}