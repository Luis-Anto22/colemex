import 'package:flutter/material.dart';
import 'api_service_profesionales.dart';

// 🔒 Constante para evitar errores
const String PERFIL_ABOGADO = 'Abogados';

class RegistrarProfesionalScreen extends StatefulWidget {
  const RegistrarProfesionalScreen({Key? key}) : super(key: key);

  @override
  State<RegistrarProfesionalScreen> createState() =>
      _RegistrarProfesionalScreenState();
}

class _RegistrarProfesionalScreenState
    extends State<RegistrarProfesionalScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();

  String _perfilSeleccionado = PERFIL_ABOGADO;
  int? _especialidadSeleccionada;
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

  // 📚 Especialidades SOLO de Derecho
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

  Future<void> _registrarProfesional() async {
    if (!_formKey.currentState!.validate()) return;

    // ⚠️ Validación extra solo para abogados
    if (_perfilSeleccionado == PERFIL_ABOGADO &&
        _especialidadSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Selecciona una especialidad')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final datos = {
      "nombre": _nombreController.text.trim(),
      "correo": _correoController.text.trim(),
      "telefono": _telefonoController.text.trim(),
      "contrasena": _contrasenaController.text,
      "perfil": _perfilSeleccionado,
      "especialidad": _perfilSeleccionado == PERFIL_ABOGADO
          ? _especialidadSeleccionada.toString()
          : "",
      "ciudad": _ciudadController.text.trim(),
      "foto": _fotoController.text.trim(),
    };

    debugPrint("📤 Enviando: $datos");

    try {
      final mensaje =
          await ApiServiceProfesionales.crearProfesional(datos);
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Profesional'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration:
                    const InputDecoration(labelText: 'Nombre completo'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _correoController,
                decoration:
                    const InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _telefonoController,
                decoration:
                    const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _contrasenaController,
                decoration:
                    const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) =>
                    v != null && v.length >= 6
                        ? null
                        : 'Mínimo 6 caracteres',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _perfilSeleccionado,
                items: perfiles
                    .map((p) =>
                        DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _perfilSeleccionado = value ?? PERFIL_ABOGADO;
                    if (_perfilSeleccionado != PERFIL_ABOGADO) {
                      _especialidadSeleccionada = null;
                    }
                  });
                },
                decoration:
                    const InputDecoration(labelText: 'Perfil profesional'),
              ),

              // 👇 SOLO PARA ABOGADOS
              if (_perfilSeleccionado == PERFIL_ABOGADO) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _especialidadSeleccionada,
                  items: especialidades
                      .map((e) => DropdownMenuItem<int>(
                            value: e['id'],
                            child: Text(e['nombre']),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _especialidadSeleccionada = value),
                  decoration: const InputDecoration(
                      labelText: 'Especialidad de Derecho'),
                  validator: (value) =>
                      value == null ? 'Selecciona una especialidad' : null,
                ),
              ],

              TextFormField(
                controller: _ciudadController,
                decoration: const InputDecoration(labelText: 'Ciudad'),
              ),
              TextFormField(
                controller: _fotoController,
                decoration:
                    const InputDecoration(labelText: 'URL de foto'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(
                    _isLoading ? 'Registrando...' : 'Registrar'),
                onPressed:
                    _isLoading ? null : _registrarProfesional,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
