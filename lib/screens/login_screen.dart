import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'registro_usuario_screen.dart';

// PUSH NOTIFICATIONS
import 'package:advocatus/services/push/push_notifications_service.dart';

// BIOMETRÍA / CUENTAS GUARDADAS
import 'package:advocatus/services/auth/saved_accounts_service.dart';

// SELECTOR DE PERFILES CON HUELLA
import 'package:advocatus/services/auth/profile_selector_screen.dart';

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
  bool hayCuentasGuardadas = false;

  String mensajeError = '';
  String tipoLogin = 'cliente'; // cliente | profesional

  static const String baseUrl = 'https://corporativolegaldigital.com/api';

  @override
  void initState() {
    super.initState();
    _cargarEstadoHuella();
  }

  Future<void> _cargarEstadoHuella() async {
    final hayCuentas = await SavedAccountsService.hayCuentasGuardadas();

    if (!mounted) return;

    setState(() {
      hayCuentasGuardadas = hayCuentas;
    });
  }

  Future<void> _iniciarConHuella() async {
    if (cargando) return;

    final hayCuentas = await SavedAccountsService.hayCuentasGuardadas();

    if (!mounted) return;

    if (!hayCuentas) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Primero inicia sesión con correo y contraseña para guardar un perfil.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileSelectorScreen(),
      ),
    ).then((_) {
      if (mounted) {
        _cargarEstadoHuella();
      }
    });
  }

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

      // Guardar esta cuenta localmente para poder usar huella después.
      // Si falla, NO bloquea el login normal.
      try {
        await SavedAccountsService.guardarCuenta(
          id: id,
          nombre: nombre,
          correo: correoBd,
          perfil: perfil,
          tipoLogin: tipoLogin,
          token: token,
          biometriaActiva: true,
        );
      } catch (e) {
        debugPrint('No se pudo guardar cuenta local para huella: $e');
      }

      // Refrescar estado del botón de huella.
      await _cargarEstadoHuella();

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

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              color: Colors.white70,
            ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(.45)),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.4),
        borderRadius: BorderRadius.circular(14),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(14),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(.075),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _brandHeader(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortest = size.shortestSide;

    final logoSize = shortest < 360
        ? 96.0
        : shortest < 420
            ? 112.0
            : 128.0;

    final titleSize = shortest < 360
        ? 38.0
        : shortest < 420
            ? 44.0
            : 50.0;

    return Column(
      children: [
        Text(
          'AppBogator',
          textAlign: TextAlign.center,
          style: GoogleFonts.bodoniModa(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            letterSpacing: .4,
            height: .96,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black87,
                blurRadius: 18,
                offset: Offset(0, 5),
              ),
              Shadow(
                color: Color(0xFFD4AF37),
                blurRadius: 20,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 96,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [
                Colors.transparent,
                Color(0xFFD4AF37),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: logoSize,
          height: logoSize,
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
                offset: const Offset(0, 0),
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
        const SizedBox(height: 13),
        const Text(
          'Asistencia legal y profesional',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFE8EEF8),
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: .3,
          ),
        ),
      ],
    );
  }

  Widget _loginCard(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 720 || size.width < 370;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 430),
      padding: EdgeInsets.fromLTRB(
        isSmall ? 18 : 22,
        isSmall ? 18 : 22,
        isSmall ? 18 : 22,
        isSmall ? 18 : 22,
      ),
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'INICIAR SESIÓN',
              style: TextStyle(
                fontSize: isSmall ? 21 : 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Elige tu tipo de acceso',
              style: TextStyle(
                color: Colors.white.withOpacity(.68),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(.12),
                ),
              ),
              child: Row(
                children: [
                  _tipoLoginButton(
                    label: 'CLIENTE',
                    icon: Icons.person_outline_rounded,
                    selected: tipoLogin == 'cliente',
                    onTap: cargando
                        ? null
                        : () {
                            setState(() {
                              tipoLogin = 'cliente';
                              mensajeError = '';
                            });
                          },
                  ),
                  const SizedBox(width: 6),
                  _tipoLoginButton(
                    label: 'PROFESIONAL',
                    icon: Icons.badge_outlined,
                    selected: tipoLogin == 'profesional',
                    onTap: cargando
                        ? null
                        : () {
                            setState(() {
                              tipoLogin = 'profesional';
                              mensajeError = '';
                            });
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: correoController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                'Correo electrónico',
                icon: Icons.email_outlined,
              ),
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
            const SizedBox(height: 14),
            TextFormField(
              controller: claveController,
              obscureText: ocultarPassword,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                'Contraseña',
                icon: Icons.lock_outline_rounded,
              ).copyWith(
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
            const SizedBox(height: 16),
            if (mensajeError.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.redAccent.withOpacity(.35),
                  ),
                ),
                child: Text(
                  mensajeError,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5,
                        ),
                      ),
              ),
            ),
            if (hayCuentasGuardadas) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: cargando ? null : _iniciarConHuella,
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: const Text('Iniciar con huella'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: const Color(0xFFD4AF37).withOpacity(.75),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            TextButton(
              onPressed: cargando
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistroUsuarioScreen(),
                        ),
                      );
                    },
              child: const Text(
                '¿No tienes cuenta? Regístrate',
                style: TextStyle(
                  color: Color(0xFF9EC5FF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipoLoginButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFD4AF37) : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? Colors.black : Colors.white70,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                    letterSpacing: .2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final horizontalPadding = size.width < 370 ? 18.0 : 26.0;
    final verticalPadding = size.height < 720 ? 18.0 : 28.0;

    return Scaffold(
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
                const Color(0xFF07111F).withOpacity(.82),
                Colors.black.withOpacity(.78),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _brandHeader(context),
                    SizedBox(height: size.height < 720 ? 18 : 24),
                    _loginCard(context),
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