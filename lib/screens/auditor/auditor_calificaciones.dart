import 'package:flutter/material.dart';

class AuditorCalificaciones extends StatefulWidget {
  const AuditorCalificaciones({super.key});

  @override
  State<AuditorCalificaciones> createState() => _AuditorCalificacionesState();
}

class _AuditorCalificacionesState extends State<AuditorCalificaciones> {
  // Datos de ejemplo, en la práctica vendrán de tu backend
  final List<Map<String, dynamic>> _profesionales = [
    {"nombre": "Juan Pérez", "rol": "Abogado", "calificacion": 4.5},
    {"nombre": "María López", "rol": "Contador", "calificacion": 3.8},
    {"nombre": "Carlos Ruiz", "rol": "Perito en criminalística", "calificacion": 4.9},
    {"nombre": "Ana Torres", "rol": "Agente inmobiliario", "calificacion": 4.2},
    {"nombre": "Luis Gómez", "rol": "Psicólogo", "calificacion": 3.5},
  ];

  String _filtroBusqueda = "";
  String _filtroRol = "todos";

  @override
  Widget build(BuildContext context) {
    // Filtrar según búsqueda y rol
    final filtrados = _profesionales.where((p) {
      final coincideBusqueda =
          p["nombre"].toLowerCase().contains(_filtroBusqueda.toLowerCase());
      final coincideRol = _filtroRol == "todos" || p["rol"] == _filtroRol;
      return coincideBusqueda && coincideRol;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calificaciones de Profesionales"),
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

          // 📌 Filtro por rol
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _filtroRol,
              items: const [
                DropdownMenuItem(value: "todos", child: Text("Todos")),
                DropdownMenuItem(value: "Abogado", child: Text("Abogado")),
                DropdownMenuItem(value: "Contador", child: Text("Contador")),
                DropdownMenuItem(value: "Perito en criminalística", child: Text("Perito en criminalística")),
                DropdownMenuItem(value: "Agente inmobiliario", child: Text("Agente inmobiliario")),
                DropdownMenuItem(value: "Psicólogo", child: Text("Psicólogo")),
              ],
              onChanged: (value) {
                setState(() {
                  _filtroRol = value!;
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // 📋 Tabla de calificaciones
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Nombre")),
                  DataColumn(label: Text("Rol")),
                  DataColumn(label: Text("Calificación")),
                ],
                rows: filtrados.map((p) {
                  return DataRow(cells: [
                    DataCell(Text(p["nombre"])),
                    DataCell(Text(p["rol"])),
                    DataCell(Text(p["calificacion"].toString())),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}