import 'package:flutter/material.dart';
import 'profesional.dart';

class DetalleProfesionalScreen extends StatelessWidget {
  final Profesional profesional;

  const DetalleProfesionalScreen({Key? key, required this.profesional}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle de ${profesional.nombre}"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profesional.foto.isNotEmpty
                        ? NetworkImage(profesional.foto)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: profesional.foto.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  profesional.nombre,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                _infoRow("Correo", profesional.correo),
                _infoRow("Teléfono", profesional.telefono),
                _infoRow("Perfil", profesional.perfil),
                _infoRow("Especialidad", profesional.especialidad),
                _infoRow("Ciudad", profesional.ciudad),
                _infoRow("Estado", profesional.estado),
                _infoRow("Verificado", profesional.verificado == 1 ? "Sí" : "No"),
                _infoRow("Fecha registro", profesional.fechaRegistro.toString()),

                const SizedBox(height: 20),
                if (profesional.latitude != null && profesional.longitude != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ubicación aproximada:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Lat: ${profesional.latitude}, Lng: ${profesional.longitude}"),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : "No especificado"),
          ),
        ],
      ),
    );
  }
}