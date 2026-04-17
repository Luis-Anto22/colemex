import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistorialInmueblesWidget extends StatefulWidget {
  final int agenteId;

  const HistorialInmueblesWidget({super.key, required this.agenteId});

  @override
  State<HistorialInmueblesWidget> createState() => _HistorialInmueblesWidgetState();
}

class _HistorialInmueblesWidgetState extends State<HistorialInmueblesWidget> {
  List<dynamic> historial = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    fetchHistorial();
  }

  Future<void> fetchHistorial() async {
    final url = Uri.parse(
        "https://corporativolegaldigital.com/api/historial_inmuebles.php?agenteId=${widget.agenteId}");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["success"] == true) {
          setState(() {
            historial = jsonData["data"];
            cargando = false;
          });
        } else {
          setState(() {
            cargando = false;
          });
        }
      } else {
        setState(() {
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Historial de Operaciones",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: cargando
              ? const Center(child: CircularProgressIndicator())
              : historial.isEmpty
                  ? const Center(child: Text("No hay historial registrado"))
                  : ListView.builder(
                      itemCount: historial.length,
                      itemBuilder: (context, index) {
                        final h = historial[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: Icon(
                              h["operacion"] == "registrar"
                                  ? Icons.add_circle
                                  : h["operacion"] == "actualizar"
                                      ? Icons.update
                                      : Icons.delete,
                              color: h["operacion"] == "eliminar"
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                            title: Text("${h["operacion"].toUpperCase()}: ${h["inmueble"]}"),
                            subtitle: Text(
                              "Ubicación: ${h["ubicacion"]}\n"
                              "Estado: ${h["estado_anterior"] ?? ''} → ${h["estado_nuevo"] ?? ''}",
                            ),
                            trailing: Text(h["fecha"]),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}