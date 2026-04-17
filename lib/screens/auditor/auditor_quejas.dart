import 'package:flutter/material.dart';

class AuditorQuejas extends StatefulWidget {
  const AuditorQuejas({super.key});

  @override
  State<AuditorQuejas> createState() => _AuditorQuejasState();
}

class _AuditorQuejasState extends State<AuditorQuejas> {
  // Datos de ejemplo, en la práctica vendrán de tu backend
  final List<Map<String, dynamic>> _quejas = [
    {
      "titulo": "Retraso en entrega de documentos",
      "descripcion": "El abogado tardó más de lo acordado.",
      "rol": "Abogado",
      "estado": "pendiente",
      "fecha": "2026-01-10"
    },
    {
      "titulo": "Atención deficiente",
      "descripcion": "El contador no respondió a tiempo.",
      "rol": "Contador",
      "estado": "revisada",
      "fecha": "2026-01-12"
    },
    {
      "titulo": "Excelente servicio",
      "descripcion": "El agente inmobiliario fue muy atento.",
      "rol": "Agente inmobiliario",
      "estado": "resuelta",
      "fecha": "2026-01-13"
    },
  ];

  String _filtroBusqueda = "";
  String _filtroEstado = "todos";

  @override
  Widget build(BuildContext context) {
    // Filtrar quejas según búsqueda y estado
    final filtradas = _quejas.where((q) {
      final coincideBusqueda = q["titulo"]
          .toLowerCase()
          .contains(_filtroBusqueda.toLowerCase());
      final coincideEstado =
          _filtroEstado == "todos" || q["estado"] == _filtroEstado;
      return coincideBusqueda && coincideEstado;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quejas y Recomendaciones"),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: Column(
        children: [
          // 🔍 Buscador
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Buscar por título",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _filtroBusqueda = value;
                });
              },
            ),
          ),

          // 📌 Filtro por estado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _filtroEstado,
              items: const [
                DropdownMenuItem(value: "todos", child: Text("Todos")),
                DropdownMenuItem(value: "pendiente", child: Text("Pendiente")),
                DropdownMenuItem(value: "revisada", child: Text("Revisada")),
                DropdownMenuItem(value: "resuelta", child: Text("Resuelta")),
              ],
              onChanged: (value) {
                setState(() {
                  _filtroEstado = value!;
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // 📋 Lista de quejas
          Expanded(
            child: ListView.builder(
              itemCount: filtradas.length,
              itemBuilder: (context, index) {
                final q = filtradas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(q["titulo"]),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Descripción: ${q["descripcion"]}"),
                        Text("Rol: ${q["rol"]}"),
                        Text("Fecha: ${q["fecha"]}"),
                      ],
                    ),
                    trailing: Text(
                      q["estado"].toUpperCase(),
                      style: TextStyle(
                        color: q["estado"] == "pendiente"
                            ? Colors.orange
                            : q["estado"] == "revisada"
                                ? Colors.blue
                                : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}