import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'registrar_inmueble_widget.dart'; // 👈 asegúrate de importar tu formulario

class PropiedadesWidget extends StatefulWidget {
  final int agenteId;

  const PropiedadesWidget({super.key, required this.agenteId});

  @override
  State<PropiedadesWidget> createState() => _PropiedadesWidgetState();
}

class _PropiedadesWidgetState extends State<PropiedadesWidget> {
  List<dynamic> propiedades = [];

  @override
  void initState() {
    super.initState();
    fetchPropiedades(); // 👈 carga las propiedades al iniciar el widget
  }

  Future<void> fetchPropiedades() async {
    final url = Uri.parse(
        "https://corporativolegaldigital.com/api/listar_inmuebles.php?agenteId=${widget.agenteId}");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["success"] == true) {
          setState(() {
            propiedades = jsonData["data"];
          });
        } else {
          print("Error: ${jsonData["message"]}");
        }
      } else {
        print("Error HTTP: ${response.statusCode}");
      }
    } catch (e) {
      print("Error de conexión: $e");
    }
  }

  Future<void> actualizarEstado(int inmuebleId, String nuevoEstado) async {
    final response = await http.post(
      Uri.parse('https://corporativolegaldigital.com/api/actualizar_estado_inmueble.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'id': inmuebleId.toString(),
        'estado': nuevoEstado,
      },
    );

    final jsonData = jsonDecode(response.body);
    if (jsonData['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Propiedad actualizada a $nuevoEstado')),
      );
      fetchPropiedades(); // refrescar lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${jsonData['message']}')),
      );
    }
  }

  Future<void> eliminarInmueble(int inmuebleId) async {
    final response = await http.post(
      Uri.parse('https://corporativolegaldigital.com/api/eliminar_inmueble.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'id': inmuebleId.toString(),
      },
    );

    final jsonData = jsonDecode(response.body);
    if (jsonData['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Propiedad eliminada')),
      );
      fetchPropiedades(); // refrescar lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${jsonData['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Propiedades Listadas",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: propiedades.isEmpty
              ? const Center(child: Text("No hay propiedades registradas"))
              : ListView.builder(
                  itemCount: propiedades.length,
                  itemBuilder: (context, index) {
                    final inmueble = propiedades[index];
                    final inmuebleId = int.parse(inmueble["id"].toString());

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(inmueble["titulo"],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                                "${inmueble["recamaras"]} recámaras • ${inmueble["banos"]} baños"),
                            Text("Estado: ${inmueble["estado"]}"),
                            Text("Precio: \$${inmueble["precio"]} MXN"),
                            Text("Ubicación: ${inmueble["ubicacion"]}"),

                            const SizedBox(height: 10),

                            // 👇 Menú desplegable para cambiar estado
                            Row(
                              children: [
                                const Text("Cambiar estado: "),
                                DropdownButton<String>(
                                  value: inmueble["estado"],
                                  items: const [
                                    DropdownMenuItem(
                                        value: "disponible",
                                        child: Text("Disponible")),
                                    DropdownMenuItem(
                                        value: "en_proceso",
                                        child: Text("En proceso")),
                                    DropdownMenuItem(
                                        value: "vendido",
                                        child: Text("Vendido")),
                                    DropdownMenuItem(
                                        value: "rentado",
                                        child: Text("Rentado")),
                                  ],
                                  onChanged: (nuevoEstado) {
                                    if (nuevoEstado != null) {
                                      actualizarEstado(inmuebleId, nuevoEstado);
                                    }
                                  },
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    eliminarInmueble(inmuebleId);
                                  },
                                  child: const Text("Eliminar"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
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
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text("Registrar nueva propiedad"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RegistrarInmuebleWidget(agenteId: widget.agenteId),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}