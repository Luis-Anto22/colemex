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
  bool ocultarPassword = true;
  bool ocultarConfirmar = true;

  static const String baseUrl = 'https://corporativolegaldigital.com/api';

  Future<void> registrarUsuario() async {
    final nombre = nombreController.text.trim();
    final correo = correoController.text.trim();
    final telefono = telefonoController.text.trim();
    final ciudad = ciudadController.text.trim();
    final contrasena = contrasenaController.text.trim();
    final confirmar = confirmarController.text.trim();

    if (nombre.isEmpty ||
        correo.isEmpty ||
        telefono.isEmpty ||
        ciudad.isEmpty ||
        contrasena.isEmpty ||
        confirmar.isEmpty) {
      setState(() => mensaje = '❌ Todos los campos son obligatorios');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(correo)) {
      setState(() => mensaje = '❌ Ingresa un correo válido');
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(telefono)) {
      setState(() => mensaje = '❌ El teléfono debe tener 10 dígitos');
      return;
    }

    if (contrasena != confirmar) {
      setState(() => mensaje = '❌ Las contraseñas no coinciden');
      return;
    }

    if (contrasena.length < 8) {
      setState(() => mensaje = '❌ La contraseña debe tener mínimo 8 caracteres');
      return;
    }

    setState(() {
      cargando = true;
      mensaje = '';
    });

    try {
      final respuesta = await http.post(
        Uri.parse('$baseUrl/registro/cliente'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nombre': nombre,
          'correo': correo,
          'telefono': telefono,
          'ciudad': ciudad,
          'contrasena': contrasena,
        }),
      );

      final body = respuesta.body.isNotEmpty ? jsonDecode(respuesta.body) : {};

      if (!mounted) return;

      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        setState(() {
          mensaje = '✅ ${body['message'] ?? 'Cliente registrado correctamente'}';
        });

        nombreController.clear();
        correoController.clear();
        telefonoController.clear();
        ciudadController.clear();
        contrasenaController.clear();
        confirmarController.clear();

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        setState(() {
          mensaje = '❌ ${body['message'] ?? 'Error del servidor'}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        mensaje = '❌ Error de conexión con el servidor';
      });
    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    ciudadController.dispose();
    contrasenaController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(
    String label, {
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(.45)),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.4),
        borderRadius: BorderRadius.circular(14),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(.075),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String label, {
    required IconData icon,
    TextInputType tipo = TextInputType.text,
    bool esPassword = false,
    bool? oculto,
    VoidCallback? cambiarOculto,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        obscureText: esPassword ? (oculto ?? true) : false,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        decoration: _inputDecoration(
          label,
          icon: icon,
          suffixIcon: esPassword
              ? IconButton(
                  onPressed: cambiarOculto,
                  icon: Icon(
                    (oculto ?? true)
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.white70,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _logoHeader() {
    return Column(
      children: [
        Container(
          width: 112,
          height: 112,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(.18),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(.42),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(.18),
                blurRadius: 26,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/iconos/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Crear cuenta',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 29,
            fontWeight: FontWeight.w900,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Regístrate como cliente',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(.68),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width < 370 ? 18.0 : 26.0;

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      appBar: AppBar(
        title: const Text(
          'Registro de cliente',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black.withOpacity(.45),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/iconos/mazo-libro.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(.76),
                const Color(0xFF07111F).withOpacity(.84),
                Colors.black.withOpacity(.80),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    _logoHeader(),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 430),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF07111F).withOpacity(.78),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(.14),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.38),
                            blurRadius: 28,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _campo(
                            nombreController,
                            'Nombre completo',
                            icon: Icons.person_outline_rounded,
                          ),
                          _campo(
                            correoController,
                            'Correo electrónico',
                            icon: Icons.email_outlined,
                            tipo: TextInputType.emailAddress,
                          ),
                          _campo(
                            telefonoController,
                            'Teléfono',
                            icon: Icons.phone_outlined,
                            tipo: TextInputType.phone,
                          ),
                          _campo(
                            ciudadController,
                            'Ciudad',
                            icon: Icons.location_city_outlined,
                          ),
                          _campo(
                            contrasenaController,
                            'Contraseña',
                            icon: Icons.lock_outline_rounded,
                            esPassword: true,
                            oculto: ocultarPassword,
                            cambiarOculto: () {
                              setState(() {
                                ocultarPassword = !ocultarPassword;
                              });
                            },
                          ),
                          _campo(
                            confirmarController,
                            'Confirmar contraseña',
                            icon: Icons.lock_reset_rounded,
                            esPassword: true,
                            oculto: ocultarConfirmar,
                            cambiarOculto: () {
                              setState(() {
                                ocultarConfirmar = !ocultarConfirmar;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          if (mensaje.isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: mensaje.startsWith('✅')
                                    ? Colors.green.withOpacity(.12)
                                    : Colors.redAccent.withOpacity(.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: mensaje.startsWith('✅')
                                      ? Colors.green.withOpacity(.45)
                                      : Colors.redAccent.withOpacity(.35),
                                ),
                              ),
                              child: Text(
                                mensaje,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: mensaje.startsWith('✅')
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: cargando ? null : registrarUsuario,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: cargando
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2.4,
                                      ),
                                    )
                                  : const Text(
                                      'REGISTRAR',
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: cargando
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            child: const Text(
                              '¿Ya tienes cuenta? Inicia sesión',
                              style: TextStyle(
                                color: Color(0xFF9EC5FF),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '© AppBogator',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.52),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}