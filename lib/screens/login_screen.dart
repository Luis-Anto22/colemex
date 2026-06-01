import 'package:flutter/material.dart';
import 'registro_usuario_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// PUSH NOTIFICATIONS
import 'package:advocatus/services/push/push_notifications_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final correoController = TextEditingController();
  final claveController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool cargando = false;
  bool ocultarPassword = true;
  String mensajeError = '';
  String tipoLogin = 'cliente'; // cliente | profesional

  static const String baseUrl = 'https://corporativolegaldigital.com/api';

  String normalizarPerfil(String? perfil) {
    if (perfil == null) return '';

    return perfil
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(' ', '_');
  }

  Future<void> iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      cargando = true;
      mensajeError = '';
    });

    final String endpoint = tipoLogin == 'cliente'
        ? '$baseUrl/login/cliente'
        : '$baseUrl/login/profesional';

    final url = Uri.parse(endpoint);

    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'correo': correoController.text.trim(),
          'contrasena': claveController.text.trim(),
        }),
      );

      Map<String, dynamic>? decoded;

      try {
        decoded = json.decode(res.body) as Map<String, dynamic>;
      } catch (_) {
        decoded = null;
      }

      if (decoded == null) {
        if (!mounted) return;

        setState(() {
          cargando = false;
          mensajeError = 'Respuesta inválida del servidor';
        });
        return;
      }

      if (res.statusCode != 200 || decoded['success'] != true) {
        final mensajeServidor =
            decoded['mensaje']?.toString() ?? decoded['message']?.toString();

        if (!mounted) return;

        setState(() {
          cargando = false;
          mensajeError =
              mensajeServidor ?? 'Error del servidor (${res.statusCode})';
        });
        return;
      }

      final usuario = decoded['usuario'];

      if (usuario == null || usuario is! Map<String, dynamic>) {
        if (!mounted) return;

        setState(() {
          cargando = false;
          mensajeError = 'Datos de usuario inválidos';
        });
        return;
      }

      final int id = int.tryParse(usuario['id']?.toString() ?? '') ?? 0;
      final String nombre = (usuario['nombre'] ?? '').toString();
      final String correoBd = (usuario['correo'] ?? '').toString();

      final String perfil = tipoLogin == 'cliente'
          ? 'cliente'
          : normalizarPerfil(usuario['perfil']?.toString());

      final String token = (decoded['token'] ?? '').toString();

      if (id == 0 || perfil.isEmpty) {
        if (!mounted) return;

        setState(() {
          cargando = false;
          mensajeError = 'Información incompleta del usuario';
        });
        return;
      }

      if (token.isEmpty) {
        if (!mounted) return;

        setState(() {
          cargando = false;
          mensajeError = 'No se recibió token de autenticación';
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('id', id);
      await prefs.setString('perfil', perfil);
      await prefs.setString('nombre', nombre);
      await prefs.setString('correo', correoBd);
      await prefs.setString('token', token);
      await prefs.setBool('sesion_activa', true);
      await prefs.setString('tipo_login', tipoLogin);

      // Guardar FCM token para notificaciones push.
      // Si falla, NO bloquea el login.
      try {
        await PushNotificationsService.guardarTokenActual();
      } catch (e) {
        debugPrint('No se pudo guardar token FCM después del login: $e');
      }

      if (!mounted) return;

      setState(() => cargando = false);

      _redirigirSegunPerfil(perfil, id, correoBd);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
        mensajeError = 'Error de conexión con el servidor';
      });
    }
  }

  void _redirigirSegunPerfil(String perfil, int id, String correoBd) {
    switch (perfil) {
      case 'admin':
      case 'administrador':
        Navigator.pushReplacementNamed(context, '/panel-admin-home');
        break;

      case 'contador':
      case 'contadores':
        if (correoBd.trim().toLowerCase() == 'admin@colemex.com') {
          Navigator.pushReplacementNamed(context, '/panel-admin-home');
        } else {
          Navigator.pushReplacementNamed(
            context,
            '/panel-contador',
            arguments: id,
          );
        }
        break;

      case 'cliente':
      case 'clientes':
        Navigator.pushReplacementNamed(
          context,
          '/panel-cliente',
          arguments: id,
        );
        break;

      case 'abogado':
      case 'abogados':
        Navigator.pushReplacementNamed(
          context,
          '/panel-abogado',
          arguments: id,
        );
        break;

      case 'psicologo':
      case 'psicologos':
        Navigator.pushReplacementNamed(
          context,
          '/panel-psicologos',
          arguments: id,
        );
        break;

      case 'investigador':
      case 'investigadores':
        Navigator.pushReplacementNamed(
          context,
          '/panel-investigador',
          arguments: id,
        );
        break;

      case 'valuador':
      case 'valuadores':
        Navigator.pushReplacementNamed(
          context,
          '/panel-valuador',
          arguments: id,
        );
        break;

      case 'agente_inmobiliario':
      case 'agentes_inmobiliarios':
        Navigator.pushReplacementNamed(
          context,
          '/panel-inmuebles',
          arguments: id,
        );
        break;

      case 'auditor':
      case 'auditores':
        Navigator.pushReplacementNamed(
          context,
          '/panel-auditor',
          arguments: id,
        );
        break;

      case 'perito_en_criminalistica':
      case 'perito_criminalistica':
      case 'peritos_en_criminalistica':
      case 'peritos':
        Navigator.pushReplacementNamed(
          context,
          '/panel-perito',
          arguments: id,
        );
        break;

      case 'ajustador':
      case 'ajustadores':
        Navigator.pushReplacementNamed(
          context,
          '/panel-ajustador',
          arguments: id,
        );
        break;

      case 'agente_crediticio':
      case 'agentes_crediticios':
        Navigator.pushReplacementNamed(
          context,
          '/panel-agente',
          arguments: id,
        );
        break;

      case 'asistencia_vial':
        Navigator.pushReplacementNamed(
          context,
          '/panel-asistencia-vial',
          arguments: id,
        );
        break;

      default:
        setState(() {
          mensajeError = 'Perfil no reconocido: $perfil';
        });
    }
  }

  @override
  void dispose() {
    correoController.dispose();
    claveController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white54),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.amber),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(.05),
    );
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
        child: Container(
          color: Colors.black.withOpacity(.65),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/iconos/logo.png',
                      height: 120,
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'INICIAR SESIÓN',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 25),
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: Colors.black,
                      fillColor: Colors.amber,
                      color: Colors.white,
                      isSelected: [
                        tipoLogin == 'cliente',
                        tipoLogin == 'profesional',
                      ],
                      onPressed: cargando
                          ? null
                          : (i) {
                              setState(() {
                                tipoLogin =
                                    i == 0 ? 'cliente' : 'profesional';
                                mensajeError = '';
                              });
                            },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('CLIENTE'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('PROFESIONAL'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: correoController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Correo electrónico'),
                      validator: (value) {
                        final text = value?.trim() ?? '';

                        if (text.isEmpty) {
                          return 'Ingresa tu correo';
                        }

                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(text)) {
                          return 'Correo inválido';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: claveController,
                      obscureText: ocultarPassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Contraseña').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            ocultarPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              ocultarPassword = !ocultarPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu contraseña';
                        }

                        if (value.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    if (mensajeError.isNotEmpty)
                      Text(
                        mensajeError,
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                        onPressed: cargando ? null : iniciarSesion,
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
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: cargando
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistroUsuarioScreen(),
                                ),
                              );
                            },
                      child: const Text(
                        '¿No tienes cuenta? Regístrate',
                        style: TextStyle(color: Colors.blue),
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