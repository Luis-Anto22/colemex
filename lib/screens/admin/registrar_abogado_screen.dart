import 'package:flutter/material.dart';
import '../../api_service.dart';

class RegistrarAbogadoScreen extends StatefulWidget {
  const RegistrarAbogadoScreen({Key? key}) : super(key: key);

  @override
  State<RegistrarAbogadoScreen> createState() => _RegistrarAbogadoScreenState();
}

class _RegistrarAbogadoScreenState extends State<RegistrarAbogadoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registrarAbogado() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final mensaje = await ApiService.registrarAbogado(
        _usuarioController.text.trim(),
        _contrasenaController.text.trim(),
      );

      if (!mounted) return; // ✅ evita errores si el widget ya fue desmontado

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );

      // ✅ mejor usar startsWith o contains con validación clara
      if (mensaje.contains("✅") || mensaje.toLowerCase().contains("registrado")) {
        Navigator.pop(context, true); // Regresa a la lista y refresca
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Abogado"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView( // ✅ evita overflow en pantallas pequeñas
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Usuario
              TextFormField(
                controller: _usuarioController,
                decoration: const InputDecoration(
                  labelText: "Usuario",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El usuario es obligatorio";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contraseña
              TextFormField(
                controller: _contrasenaController,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La contraseña es obligatoria";
                  }
                  if (value.length < 8) {
                    return "La contraseña debe tener al menos 8 caracteres";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botón registrar
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _registrarAbogado,
                      icon: const Icon(Icons.person_add),
                      label: const Text("Registrar abogado"),
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