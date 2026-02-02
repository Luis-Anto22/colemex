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

    // Validación de campos vacíos
    if (nombre.isEmpty ||
        correo.isEmpty ||
        telefono.isEmpty ||
        ciudad.isEmpty ||
        contrasena.isEmpty ||
        confirmar.isEmpty) {
      setState(() {
        mensaje = '❌ Debes completar todos los campos';
      });
      return;
    }

    // Validación de teléfono
    if (telefono.length != 10 || !RegExp(r'^\d{10}$').hasMatch(telefono)) {
      setState(() {
        mensaje = '❌ El teléfono debe tener 10 dígitos numéricos';
      });
      return;
    }

    // Validación de contraseñas
    if (contrasena != confirmar) {
      setState(() {
        mensaje = '❌ Las contraseñas no coinciden';
      });
      return;
    }

    setState(() {
      cargando = true;
      mensaje = '';
    });

    // ✅ Endpoint para clientes
    final url = Uri.parse('https://corporativolegaldigital.com/api/registro-cliente.php');

    try {
      final respuesta = await http.post(url, body: {
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'ciudad': ciudad,
        'contrasena': contrasena,
      });

      debugPrint("Código: ${respuesta.statusCode}");
      debugPrint("Cuerpo: ${respuesta.body}");

      setState(() {
        cargando = false;
      });

      if (respuesta.statusCode == 200) {
        if (respuesta.headers['content-type']?.contains('application/json') == true) {
          final datos = json.decode(respuesta.body);

          if (datos['status'] == 'success') {
            setState(() {
              mensaje = '✅ ${datos['message']}';
            });
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pop(context);
            });
          } else {
            setState(() {
              mensaje = '❌ ${datos['message']}';
            });
          }
        } else {
          setState(() {
            mensaje = '❌ El servidor no devolvió JSON válido';
          });
        }
      } else {
        setState(() {
          mensaje = '❌ Error en la respuesta del servidor';
        });
      }
    } catch (e) {
      setState(() {
        cargando = false;
        mensaje = '❌ Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de cliente"),
        backgroundColor: const Color(0xFFD4AF37), // Dorado institucional
      ),
      body: Stack(
        children: [
          // Fondo con imagen
          Positioned.fill(
            child: Image.asset(
              'assets/iconos/mazo-libro.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.2),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Scroll con altura completa
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Registro de cliente",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3B55),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: "Nombre completo"),
                    ),
                    TextField(
                      controller: correoController,
                      decoration: const InputDecoration(labelText: "Correo electrónico"),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: telefonoController,
                      decoration: const InputDecoration(labelText: "Teléfono (10 dígitos)"),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      controller: ciudadController,
                      decoration: const InputDecoration(labelText: "Ciudad"),
                    ),
                    TextField(
                      controller: contrasenaController,
                      decoration: const InputDecoration(labelText: "Contraseña"),
                      obscureText: true,
                    ),
                    TextField(
                      controller: confirmarController,
                      decoration: const InputDecoration(labelText: "Confirmar contraseña"),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    cargando
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: registrarUsuario,
                            icon: const Icon(Icons.person_add),
                            label: const Text("Registrar"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E3B55),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                    const SizedBox(height: 10),
                    Text(
                      mensaje,
                      style: TextStyle(
                        color: mensaje.startsWith('✅') ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}