import 'package:flutter/material.dart';
import 'api_service_profesionales.dart';
import 'profesional.dart';

class EditarProfesionalScreen extends StatefulWidget {
  final Profesional profesional;

  const EditarProfesionalScreen({Key? key, required this.profesional}) : super(key: key);

  @override
  State<EditarProfesionalScreen> createState() => _EditarProfesionalScreenState();
}

class _EditarProfesionalScreenState extends State<EditarProfesionalScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _especialidadController;
  late TextEditingController _ciudadController;
  late TextEditingController _fotoController;

  bool _isLoading = false;
  String _perfilSeleccionado = 'Abogados';

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

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.profesional.nombre);
    _telefonoController = TextEditingController(text: widget.profesional.telefono);
    _especialidadController = TextEditingController(text: widget.profesional.especialidad);
    _ciudadController = TextEditingController(text: widget.profesional.ciudad);
    _fotoController = TextEditingController(text: widget.profesional.foto);
    _perfilSeleccionado = widget.profesional.perfil;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _especialidadController.dispose();
    _ciudadController.dispose();
    _fotoController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final datos = {
      "nombre": _nombreController.text.trim(),
      "telefono": _telefonoController.text.trim(),
      "perfil": _perfilSeleccionado,
      "especialidad": _especialidadController.text.trim(),
      "ciudad": _ciudadController.text.trim(),
      "foto": _fotoController.text.trim(),
    };

    try {
      final mensaje = await ApiServiceProfesionales.editarProfesional(widget.profesional.id, datos);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
      Navigator.pop(context, true); // Regresa a la lista y refresca
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Profesional"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre completo",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: "Teléfono",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _perfilSeleccionado,
                items: perfiles.map((perfil) {
                  return DropdownMenuItem(value: perfil, child: Text(perfil));
                }).toList(),
                onChanged: (value) => setState(() => _perfilSeleccionado = value ?? 'Abogados'),
                decoration: const InputDecoration(
                  labelText: "Perfil profesional",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _especialidadController,
                decoration: const InputDecoration(
                  labelText: "Especialidad",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ciudadController,
                decoration: const InputDecoration(
                  labelText: "Ciudad",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _fotoController,
                decoration: const InputDecoration(
                  labelText: "URL de foto (opcional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _guardarCambios,
                      icon: const Icon(Icons.save),
                      label: const Text("Guardar cambios"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}