import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController claveController = TextEditingController();
  String perfilSeleccionado = 'profesional'; // por defecto profesional
  bool cargando = false;
  String mensajeError = '';

  Future<void> iniciarSesion() async {
    final usuario = usuarioController.text.trim();
    final clave = claveController.text.trim();

    if (usuario.isEmpty || clave.isEmpty) {
      setState(() {
        mensajeError = '❌ Debes completar todos los campos';
      });
      return;
    }

    setState(() {
      cargando = true;
      mensajeError = '';
    });

    final url = Uri.parse(
      perfilSeleccionado == 'cliente'
          ? 'https://corporativolegaldigital.com/api/login-cliente.php'
          : 'https://corporativolegaldigital.com/api/login-abogado.php',
    );

    try {
      final respuesta = await http.post(
        url,
        body: perfilSeleccionado == 'cliente'
            ? {
                'correo': usuario,
                'contrasena': clave,
              }
            : {
                'correo': usuario, // ahora usamos correo también para profesionales
                'contrasena': clave,
              },
      );

      final cuerpo = respuesta.body.trim();
      print('Respuesta cruda: $cuerpo');

      setState(() {
        cargando = false;
      });

      if (respuesta.statusCode == 200 && cuerpo.startsWith('{')) {
        final datos = json.decode(cuerpo);

        if (datos['success'] == true && datos['usuario'] is Map) {
          final usuario = datos['usuario'];
          final perfil = usuario['perfil'] ?? perfilSeleccionado;
          final nombre = usuario['nombre'] ?? 'Usuario';
          final id = int.tryParse(usuario['id'].toString()) ?? 0;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('id', id);
          await prefs.setString('nombre', nombre);
          await prefs.setString('perfil', perfil);

          if (!mounted) return;

          final ruta = perfil == 'admin'
              ? '/panel-admin'
              : perfil == 'profesional'
                  ? '/panel-abogado'
                  : perfil == 'cliente'
                      ? '/panel-cliente'
                      : '/panel';

          Navigator.pushReplacementNamed(context, ruta);
        } else {
          setState(() {
            mensajeError = datos['mensaje'] ?? '❌ Credenciales incorrectas';
          });
        }
      } else {
        setState(() {
          mensajeError = '❌ Respuesta inválida del servidor';
        });
      }
    } catch (e) {
      setState(() {
        mensajeError = '❌ No se pudo conectar al servidor';
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/iconos/mazo-libro.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/iconos/logo.png', height: 120),
                  const SizedBox(height: 20),
                  const Text(
                    'SELECCIONA TU PERFIL',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ToggleButtons(
                    isSelected: [
                      perfilSeleccionado == 'cliente',
                      perfilSeleccionado == 'profesional',
                    ],
                    onPressed: (index) {
                      setState(() {
                        perfilSeleccionado =
                            index == 0 ? 'cliente' : 'profesional';
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    fillColor: const Color(0xFFD4AF37),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text('SOY CLIENTE'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text('SOY PROFESIONAL'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: usuarioController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: perfilSeleccionado == 'cliente'
                          ? 'Correo institucional'
                          : 'Correo profesional',
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD4AF37), width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: claveController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD4AF37), width: 2),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  if (mensajeError.isNotEmpty)
                    Text(
                      mensajeError,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: cargando ? null : iniciarSesion,
                    child: cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registro-usuario');
                    },
                    child: const Text(
                      'Registrar cliente',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registro-socio');
                    },
                    child: const Text(
                      'Registrar profesional',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}