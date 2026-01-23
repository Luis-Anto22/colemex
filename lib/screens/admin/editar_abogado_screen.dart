import 'package:flutter/material.dart';
import '../../api_service.dart';
import 'abogado.dart';

class EditarAbogadoScreen extends StatefulWidget {
  final Abogado abogado;

  const EditarAbogadoScreen({Key? key, required this.abogado}) : super(key: key);

  @override
  State<EditarAbogadoScreen> createState() => _EditarAbogadoScreenState();
}

class _EditarAbogadoScreenState extends State<EditarAbogadoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usuarioController;
  final TextEditingController _contrasenaController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ✅ Usamos el campo que sí existe en tu modelo (nombre)
    _usuarioController = TextEditingController(text: widget.abogado.nombre);
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final mensaje = await ApiService.actualizarAbogado(
        widget.abogado.id,
        _usuarioController.text.trim(),
        contrasena: _contrasenaController.text.trim().isEmpty
            ? null
            : _contrasenaController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );

      Navigator.pop(context, true); // Regresa a la lista y refresca
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Abogado"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
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
                  labelText: "Nueva contraseña (opcional)",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Botón guardar
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