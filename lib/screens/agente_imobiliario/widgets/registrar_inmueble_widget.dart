import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;   // 👈 para peticiones HTTP
import 'dart:convert';                     // 👈 para decodificar JSON

class RegistrarInmuebleWidget extends StatefulWidget {
  final int agenteId;

  const RegistrarInmuebleWidget({super.key, required this.agenteId});

  @override
  State<RegistrarInmuebleWidget> createState() => _FormularioInmuebleWidgetState();
}

class _FormularioInmuebleWidgetState extends State<RegistrarInmuebleWidget> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _recamarasController = TextEditingController();
  final TextEditingController _banosController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _clienteController = TextEditingController();

  String _estado = "En promoción"; // valor inicial
  bool cargando = false;

  Future<void> registrarInmueble(Map<String, String> inmuebleData) async {
    setState(() => cargando = true);

    final url = Uri.parse("https://corporativolegaldigital.com/api/registrar_inmueble.php");
    final response = await http.post(url, body: inmuebleData);

    setState(() => cargando = false);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inmueble registrado correctamente")),
        );
        Navigator.pop(context); // 👈 regresa al listado
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${jsonData["message"]}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error HTTP: ${response.statusCode}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Inmueble"),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: "Título (ej. Casa en CDMX)"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(labelText: "Ubicación"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              TextFormField(
                controller: _recamarasController,
                decoration: const InputDecoration(labelText: "Número de recámaras"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _banosController,
                decoration: const InputDecoration(labelText: "Número de baños"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: "Precio (MXN)"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _clienteController,
                decoration: const InputDecoration(labelText: "Cliente asignado"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(labelText: "Estado del inmueble"),
                items: const [
                  DropdownMenuItem(value: "En promoción", child: Text("En promoción")),
                  DropdownMenuItem(value: "En renta", child: Text("En renta")),
                  DropdownMenuItem(value: "En venta", child: Text("En venta")),
                ],
                onChanged: (value) {
                  setState(() {
                    _estado = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              cargando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final inmuebleData = {
                            "agenteId": widget.agenteId.toString(),
                            "titulo": _tituloController.text,
                            "ubicacion": _ubicacionController.text,
                            "recamaras": _recamarasController.text,
                            "banos": _banosController.text,
                            "precio": _precioController.text,
                            "cliente": _clienteController.text,
                            "estado": _estado,
                            "tipo_operacion": "venta", // 👈 puedes ajustar según tu lógica
                          };

                          registrarInmueble(inmuebleData);
                        }
                      },
                      child: const Text("Registrar Inmueble"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}