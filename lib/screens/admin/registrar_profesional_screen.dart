import 'package:flutter/material.dart';
import 'api_service_profesionales.dart';

class RegistrarProfesionalScreen extends StatefulWidget {
  const RegistrarProfesionalScreen({Key? key}) : super(key: key);

  @override
  State<RegistrarProfesionalScreen> createState() => _RegistrarProfesionalScreenState();
}

class _RegistrarProfesionalScreenState extends State<RegistrarProfesionalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _especialidadController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();

  String _perfilSeleccionado = 'Abogados';
  bool _isLoading = false;

  final List<String> perfiles = [
    'Abogados',
    'Ajustadores',
    'Peritos en criminalística',
    'Valuadores',
    'Investigadores',
    'Psicólogos',
    'Agentes inmobiliarios',
    'Contadores',
    'Agentes crediticios',
  ];

  Future<void> _registrarProfesional() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final datos = {
      "nombre": _nombreController.text.trim(),
      "correo": _correoController.text.trim(),
      "telefono": _telefonoController.text.trim(),
      "contrasena": _contrasenaController.text,
      "perfil": _perfilSeleccionado,
      "especialidad": _especialidadController.text.trim(),
      "ciudad": _ciudadController.text.trim(),
      "foto": _fotoController.text.trim(),
    };

    try {
      final mensaje = await ApiServiceProfesionales.crearProfesional(datos);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
      Navigator.pop(context, true); // indica que se registró correctamente
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Profesional"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: "Nombre completo"),
                validator: (value) => value == null || value.isEmpty ? "Campo obligatorio" : null,
              ),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: "Correo electrónico"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty ? "Campo obligatorio" : null,
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: "Teléfono"),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _contrasenaController,
                decoration: const InputDecoration(labelText: "Contraseña"),
                obscureText: true,
                validator: (value) => value == null || value.length < 6 ? "Mínimo 6 caracteres" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _perfilSeleccionado,
                items: perfiles.map((perfil) {
                  return DropdownMenuItem(value: perfil, child: Text(perfil));
                }).toList(),
                onChanged: (value) => setState(() => _perfilSeleccionado = value ?? 'Abogados'),
                decoration: const InputDecoration(labelText: "Perfil profesional"),
              ),
              TextFormField(
                controller: _especialidadController,
                decoration: const InputDecoration(labelText: "Especialidad"),
              ),
              TextFormField(
                controller: _ciudadController,
                decoration: const InputDecoration(labelText: "Ciudad"),
              ),
              TextFormField(
                controller: _fotoController,
                decoration: const InputDecoration(labelText: "URL de foto (opcional)"),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(_isLoading ? "Registrando..." : "Registrar"),
                onPressed: _isLoading ? null : _registrarProfesional,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}