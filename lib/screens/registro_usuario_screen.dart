import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();
  final ciudadController = TextEditingController();
  final contrasenaController = TextEditingController();
  final confirmarController = TextEditingController();

  String mensaje = '';
  bool cargando = false;

  Future<void> registrarUsuario() async {
    final nombre = nombreController.text.trim();
    final correo = correoController.text.trim();
    final telefono = telefonoController.text.trim();
    final ciudad = ciudadController.text.trim();
    final contrasena = contrasenaController.text.trim();
    final confirmar = confirmarController.text.trim();

    // ================= VALIDACIONES =================

    if (nombre.isEmpty ||
        correo.isEmpty ||
        telefono.isEmpty ||
        ciudad.isEmpty ||
        contrasena.isEmpty ||
        confirmar.isEmpty) {
      setState(() {
        mensaje = '❌ Todos los campos son obligatorios';
      });
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(telefono)) {
      setState(() {
        mensaje = '❌ El teléfono debe tener 10 dígitos';
      });
      return;
    }

    if (contrasena != confirmar) {
      setState(() {
        mensaje = '❌ Las contraseñas no coinciden';
      });
      return;
    }

    if (contrasena.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(contrasena) ||
        !RegExp(r'[0-9]').hasMatch(contrasena) ||
        !RegExp(r'[!@#\$&*~%^()_\-+=]').hasMatch(contrasena)) {
      setState(() {
        mensaje =
            '❌ La contraseña debe tener 8 caracteres, una mayúscula, un número y un símbolo';
      });
      return;
    }

    setState(() {
      cargando = true;
      mensaje = '';
    });

    final url = Uri.parse(
        'https://corporativolegaldigital.com/api/registro-cliente.php');

    try {
      final respuesta = await http.post(url, body: {
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'ciudad': ciudad,
        'contrasena': contrasena,
      });

      setState(() {
        cargando = false;
      });

      if (respuesta.statusCode == 200) {
        try {
          final datos = json.decode(respuesta.body);

          if (datos['success'] == true) {
            setState(() {
              mensaje = '✅ ${datos['message']}';
            });

            // Limpiar campos
            nombreController.clear();
            correoController.clear();
            telefonoController.clear();
            ciudadController.clear();
            contrasenaController.clear();
            confirmarController.clear();

            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) Navigator.pop(context);
            });
          } else {
            setState(() {
              mensaje = '❌ ${datos['message']}';
            });
          }
        } catch (e) {
          setState(() {
            mensaje = '❌ Error al procesar la respuesta del servidor';
          });
        }
      } else {
        setState(() {
          mensaje = '❌ Error del servidor (${respuesta.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        cargando = false;
        mensaje = '❌ Error de conexión';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de cliente"),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/iconos/mazo-libro.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.25),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Crear cuenta",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3B55),
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  _campo(nombreController, "Nombre completo"),
                  _campo(correoController, "Correo electrónico",
                      tipo: TextInputType.emailAddress),
                  _campo(telefonoController, "Teléfono (10 dígitos)",
                      tipo: TextInputType.phone),
                  _campo(ciudadController, "Ciudad"),
                  _campo(contrasenaController, "Contraseña",
                      esPassword: true),
                  _campo(confirmarController, "Confirmar contraseña",
                      esPassword: true),
                  const SizedBox(height: 25),
                  cargando
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: registrarUsuario,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E3B55),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "REGISTRAR",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                  const SizedBox(height: 15),
                  Text(
                    mensaje,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: mensaje.startsWith('✅')
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campo(TextEditingController controller, String label,
      {TextInputType tipo = TextInputType.text, bool esPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        obscureText: esPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }
}
