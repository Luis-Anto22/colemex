import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UniversalLocationButton extends StatefulWidget {
  final int? idProfesional;
  final double lat;
  final double lng;

  const UniversalLocationButton({
    super.key,
    required this.idProfesional,
    required this.lat,
    required this.lng,
  });

  @override
  State<UniversalLocationButton> createState() => _UniversalLocationButtonState();
}

class _UniversalLocationButtonState extends State<UniversalLocationButton> {
  bool _isSaving = false;

  Future<void> _guardarUbicacion(BuildContext context) async {
    if (widget.idProfesional == null || widget.idProfesional == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID de profesional no válido")),
      );
      return;
    }

    if (widget.lat == 0.0 || widget.lng == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ubicación inválida")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await http.post(
        Uri.parse("https://corporativolegaldigital.com/api/universal/ubicacion_universal.php"),
        body: {
          "profesional_id": widget.idProfesional.toString(),
          "latitud": widget.lat.toString(),
          "longitud": widget.lng.toString(),
        },
      );

      setState(() => _isSaving = false);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse["message"] ?? "Ubicación guardada correctamente")),
          );
          // Navigator.pop(context); // opcional
        } else {
          final errorMsg = jsonResponse["message"] ?? "Error desconocido";
          final errorDetail = jsonResponse["error_detail"];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorDetail != null ? "$errorMsg: $errorDetail" : errorMsg)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error HTTP ${response.statusCode}: ${response.body}")),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar ubicación: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _isSaving ? null : () => _guardarUbicacion(context),
      label: _isSaving
          ? const Text("Guardando...")
          : const Text("Guardar ubicación"),
      icon: _isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.save),
    );
  }
}