import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IngresosWidget extends StatefulWidget {
  final int profesionalId; // 👈 ID del agente inmobiliario

  const IngresosWidget({super.key, required this.profesionalId});

  @override
  State<IngresosWidget> createState() => _IngresosWidgetState();
}

class _IngresosWidgetState extends State<IngresosWidget> {
  List<dynamic> ingresos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    fetchIngresos();
  }

  Future<void> fetchIngresos() async {
    final url = Uri.parse(
        "https://corporativolegaldigital.com/api/ingresos_inmueble.php?profesionalId=${widget.profesionalId}");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["success"] == true) {
          setState(() {
            ingresos = jsonData["data"];
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
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.attach_money, color: Colors.green),
            title: Text("Ingresos y Comisiones"),
          ),
          cargando
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              : ingresos.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("No hay ingresos registrados"),
                    )
                  : Column(
                      children: ingresos.map((i) {
                        return ListTile(
                          title: Text(i['concepto'] ?? "Sin concepto"),
                          subtitle: Text(
                            "Monto: \$${i['monto']} • Comisión: \$${i['comision']}",
                          ),
                          trailing: Text(i['fecha']),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}