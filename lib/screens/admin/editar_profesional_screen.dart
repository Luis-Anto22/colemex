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
  late TextEditingController _ciudadController;
  late TextEditingController _fotoController;

  bool _isLoading = false;
  String _perfilSeleccionado = 'Abogados';
  int? _especialidadSeleccionada;

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

  final List<Map<String, dynamic>> especialidades = [
    {"id": 1, "nombre": "Derecho Civil"},
    {"id": 2, "nombre": "Derecho Penal"},
    {"id": 3, "nombre": "Derecho Familiar"},
    {"id": 4, "nombre": "Derecho Laboral"},
    {"id": 5, "nombre": "Derecho Mercantil / Corporativo"},
    {"id": 6, "nombre": "Derecho Fiscal / Tributario"},
    {"id": 7, "nombre": "Derecho Administrativo"},
    {"id": 8, "nombre": "Derecho Constitucional"},
    {"id": 9, "nombre": "Derecho Agrario"},
    {"id": 10, "nombre": "Derecho Inmobiliario"},
    {"id": 11, "nombre": "Derecho Migratorio"},
    {"id": 12, "nombre": "Derecho Internacional"},
    {"id": 13, "nombre": "Derecho Bancario y Financiero"},
    {"id": 14, "nombre": "Derecho de Propiedad Intelectual"},
    {"id": 15, "nombre": "Derecho Digital / Tecnológico"},
    {"id": 16, "nombre": "Derecho Ambiental"},
    {"id": 17, "nombre": "Derecho Aduanero"},
    {"id": 18, "nombre": "Derecho Electoral"},
    {"id": 19, "nombre": "Derecho de Seguridad Social"},
    {"id": 20, "nombre": "Derecho Médico"},
    {"id": 21, "nombre": "Derecho Energético"},
    {"id": 22, "nombre": "Derecho de Amparo"},
    {"id": 23, "nombre": "Derecho de Seguros"},
    {"id": 24, "nombre": "Derecho de Consumidor"},
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.profesional.nombre);
    _telefonoController = TextEditingController(text: widget.profesional.telefono);
    _ciudadController = TextEditingController(text: widget.profesional.ciudad);
    _fotoController = TextEditingController(text: widget.profesional.foto);
    _perfilSeleccionado = widget.profesional.perfil;

    // Inicializar especialidad si es abogado
    if (widget.profesional.perfil == 'Abogados') {
      _especialidadSeleccionada = widget.profesional.especialidadId;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _ciudadController.dispose();
    _fotoController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    if (_perfilSeleccionado == 'Abogados' && _especialidadSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Selecciona una especialidad")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final datos = {
      "nombre": _nombreController.text.trim(),
      "telefono": _telefonoController.text.trim(),
      "perfil": _perfilSeleccionado,
      "especialidad": _perfilSeleccionado == 'Abogados'
          ? _especialidadSeleccionada?.toString() ?? ""
          : "",
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
                onChanged: (value) {
                  setState(() {
                    _perfilSeleccionado = value ?? 'Abogados';
                    _especialidadSeleccionada = null; // resetear si cambia perfil
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Perfil profesional",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Solo aparece si el perfil es Abogados
              if (_perfilSeleccionado == 'Abogados') ...[
                DropdownButtonFormField<int>(
                  value: _especialidadSeleccionada,
                  items: especialidades.map((esp) {
                    return DropdownMenuItem<int>(
                      value: esp["id"],
                      child: Text(esp["nombre"]),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _especialidadSeleccionada = value),
                  decoration: const InputDecoration(
                    labelText: "Especialidad",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      _perfilSeleccionado == 'Abogados' && value == null
                          ? "Selecciona una especialidad"
                          : null,
                ),
                const SizedBox(height: 16),
              ],

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