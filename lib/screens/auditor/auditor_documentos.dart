import 'package:flutter/material.dart';

class AuditorDocumentos extends StatefulWidget {
  const AuditorDocumentos({super.key});

  @override
  State<AuditorDocumentos> createState() => _AuditorDocumentosState();
}

class _AuditorDocumentosState extends State<AuditorDocumentos> {
  // Datos de ejemplo, en la práctica vendrán de tu backend
  final List<Map<String, dynamic>> _documentos = [
    {
      "nombre": "Juan Pérez",
      "rol": "Abogado",
      "tipo": "INE",
      "estado": "pendiente",
      "fecha": "2026-01-10"
    },
    {
      "nombre": "María López",
      "rol": "Contador",
      "tipo": "RFC",
      "estado": "verificado",
      "fecha": "2026-01-12"
    },
    {
      "nombre": "Carlos Ruiz",
      "rol": "Perito en criminalística",
      "tipo": "Cédula profesional",
      "estado": "rechazado",
      "fecha": "2026-01-13"
    },
  ];

  String _filtroBusqueda = "";
  String _filtroTipo = "todos";

  @override
  Widget build(BuildContext context) {
    // Filtrar documentos según búsqueda y tipo
    final filtrados = _documentos.where((d) {
      final coincideBusqueda =
          d["nombre"].toLowerCase().contains(_filtroBusqueda.toLowerCase());
      final coincideTipo = _filtroTipo == "todos" || d["tipo"] == _filtroTipo;
      return coincideBusqueda && coincideTipo;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Documentos para Verificación"),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: Column(
        children: [
          // 🔍 Buscador por nombre
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Buscar por nombre",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _filtroBusqueda = value;
                });
              },
            ),
          ),

          // 📌 Filtro por tipo de documento
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _filtroTipo,
              items: const [
                DropdownMenuItem(value: "todos", child: Text("Todos")),
                DropdownMenuItem(value: "INE", child: Text("INE")),
                DropdownMenuItem(value: "RFC", child: Text("RFC")),
                DropdownMenuItem(value: "Cédula profesional", child: Text("Cédula profesional")),
              ],
              onChanged: (value) {
                setState(() {
                  _filtroTipo = value!;
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // 📋 Lista de documentos
          Expanded(
            child: ListView.builder(
              itemCount: filtrados.length,
              itemBuilder: (context, index) {
                final d = filtrados[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text("${d["tipo"]} - ${d["nombre"]}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Rol: ${d["rol"]}"),
                        Text("Fecha: ${d["fecha"]}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          d["estado"].toUpperCase(),
                          style: TextStyle(
                            color: d["estado"] == "pendiente"
                                ? Colors.orange
                                : d["estado"] == "verificado"
                                    ? Colors.green
                                    : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              d["estado"] = "verificado";
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              d["estado"] = "rechazado";
                            });
                          },
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
    );
  }
}