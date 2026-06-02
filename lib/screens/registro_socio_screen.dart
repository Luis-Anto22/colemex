import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class RegistroSocioScreen extends StatefulWidget {
  const RegistroSocioScreen({super.key});

  @override
  State<RegistroSocioScreen> createState() => _RegistroSocioScreenState();
}

class _RegistroSocioScreenState extends State<RegistroSocioScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();
  final contrasenaController = TextEditingController();

  String? perfilSeleccionado;
  String? especialidad;

  bool cargando = false;
  bool ocultarPassword = true;

  String mensaje = '';

  Uint8List? fotoBytes;
  String? fotoNombre;

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

  final List<String> especialidades = [
    'Civil',
    'Penal',
    'Familiar',
    'Laboral',
    'Mercantil',
    'Administrativo',
  ];

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  Future<void> tomarFoto() async {
    try {
      if (!kIsWeb) {
        final permiso = await Permission.camera.request();
        if (!permiso.isGranted) {
          setState(() => mensaje = '⚠️ Permiso de cámara denegado');
          return;
        }
      }

      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (foto == null) return;

      final bytes = await foto.readAsBytes();

      setState(() {
        fotoBytes = bytes;
        fotoNombre = foto.name.isNotEmpty ? foto.name : 'foto_rostro.jpg';
        mensaje = '✅ Foto tomada correctamente';
      });
    } catch (e) {
      setState(() => mensaje = '❌ Error al tomar foto: $e');
    }
  }

  Future<void> seleccionarDeGaleria() async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (imagen == null) return;

      final bytes = await imagen.readAsBytes();

      setState(() {
        fotoBytes = bytes;
        fotoNombre = imagen.name.isNotEmpty ? imagen.name : 'foto_rostro.jpg';
        mensaje = '✅ Foto seleccionada correctamente';
      });
    } catch (e) {
      setState(() => mensaje = '❌ Error al abrir galería: $e');
    }
  }

  Future<void> continuarRegistro() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (perfilSeleccionado == null) {
      setState(() => mensaje = '❌ Selecciona un perfil');
      return;
    }

    if (perfilSeleccionado == 'Abogados' && especialidad == null) {
      setState(() => mensaje = '❌ Selecciona una especialidad');
      return;
    }

    if (fotoBytes == null) {
      setState(() => mensaje = '❌ Debes subir una foto de rostro');
      return;
    }

    setState(() {
      cargando = true;
      mensaje = '';
    });

    try {
      final uri = Uri.parse(
        'https://corporativolegaldigital.com/api/registro/profesional',
      );

      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
      });

      request.fields.addAll({
        'nombre': nombreController.text.trim(),
        'correo': correoController.text.trim().toLowerCase(),
        'telefono': telefonoController.text.trim(),
        'contrasena': contrasenaController.text.trim(),
        'perfil': perfilSeleccionado!,
        'especialidad': especialidad ?? '',
        'ciudad': 'Ciudad de México',
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'foto',
          fotoBytes!,
          filename: fotoNombre ?? 'foto_rostro.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 30),
          );

      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      Map<String, dynamic>? data;

      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        data = null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final success = data?['success'] == true ||
            data?['ok'] == true ||
            data?['profesional'] != null;

        final texto = data?['mensaje'] ??
            data?['message'] ??
            '✅ Registro completado correctamente';

        setState(() {
          mensaje = texto.toString().startsWith('✅')
              ? texto.toString()
              : '✅ $texto';
        });

        if (success || data != null) {
          await Future.delayed(const Duration(seconds: 1));

          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else if (response.statusCode == 422) {
        setState(() {
          mensaje = _extraerErroresValidacion(data) ??
              '❌ Datos inválidos. Revisa el correo, contraseña o teléfono.';
        });
      } else {
        setState(() {
          mensaje = data?['mensaje']?.toString() ??
              data?['message']?.toString() ??
              '❌ Error ${response.statusCode}: no se pudo registrar';
        });
      }
    } on TimeoutException {
      setState(() {
        mensaje = '❌ El servidor tardó demasiado en responder';
      });
    } catch (e) {
      setState(() {
        mensaje = '❌ Error al enviar datos: $e';
      });
    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  String? _extraerErroresValidacion(Map<String, dynamic>? data) {
    if (data == null) return null;

    if (data['errors'] is Map) {
      final errors = data['errors'] as Map;
      final mensajes = <String>[];

      errors.forEach((_, value) {
        if (value is List && value.isNotEmpty) {
          mensajes.add(value.first.toString());
        } else if (value != null) {
          mensajes.add(value.toString());
        }
      });

      if (mensajes.isNotEmpty) {
        return '❌ ${mensajes.join('\n')}';
      }
    }

    return data['mensaje']?.toString() ?? data['message']?.toString();
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
      filled: true,
      fillColor: Colors.white.withOpacity(.075),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(.45)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String label, {
    required IconData icon,
    TextInputType tipo = TextInputType.text,
    bool esPassword = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        obscureText: esPassword ? ocultarPassword : false,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        validator: validator,
        decoration: _inputDecoration(
          label,
          icon: icon,
          suffixIcon: esPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      ocultarPassword = !ocultarPassword;
                    });
                  },
                  icon: Icon(
                    ocultarPassword
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

  Widget _dropdownPerfil() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: perfilSeleccionado,
        dropdownColor: const Color(0xFF111D2D),
        iconEnabledColor: Colors.white70,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        items: perfiles.map((p) {
          return DropdownMenuItem(value: p, child: Text(p));
        }).toList(),
        onChanged: cargando
            ? null
            : (value) {
                setState(() {
                  perfilSeleccionado = value;
                  especialidad = null;
                  mensaje = '';
                });
              },
        decoration: _inputDecoration(
          'Selecciona tu perfil',
          icon: Icons.badge_outlined,
        ),
      ),
    );
  }

  Widget _dropdownEspecialidad() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: especialidad,
        dropdownColor: const Color(0xFF111D2D),
        iconEnabledColor: Colors.white70,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        items: especialidades.map((e) {
          return DropdownMenuItem(value: e, child: Text(e));
        }).toList(),
        onChanged: cargando
            ? null
            : (value) {
                setState(() {
                  especialidad = value;
                  mensaje = '';
                });
              },
        decoration: _inputDecoration(
          'Especialidad',
          icon: Icons.gavel_rounded,
        ),
      ),
    );
  }

  Widget _fotoBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.14)),
      ),
      child: Column(
        children: [
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(.25),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(.55),
                width: 1.3,
              ),
            ),
            child: fotoBytes == null
                ? const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Color(0xFFD4AF37),
                    size: 46,
                  )
                : ClipOval(
                    child: Image.memory(
                      fotoBytes!,
                      fit: BoxFit.cover,
                      width: 118,
                      height: 118,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Foto de rostro',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Necesaria para validar tu perfil profesional',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(.62),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: cargando ? null : tomarFoto,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Cámara'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: const Color(0xFFD4AF37).withOpacity(.75),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: cargando ? null : seleccionarDeGaleria,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galería'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: const Color(0xFFD4AF37).withOpacity(.75),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mensajeBox() {
    if (mensaje.isEmpty) return const SizedBox.shrink();

    final ok = mensaje.startsWith('✅');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ok
            ? Colors.green.withOpacity(.12)
            : Colors.redAccent.withOpacity(.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              ok ? Colors.green.withOpacity(.45) : Colors.redAccent.withOpacity(.35),
        ),
      ),
      child: Text(
        mensaje,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: ok ? Colors.greenAccent : Colors.redAccent,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _header() {
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
          'Registro profesional',
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
          'Únete como socio de AppBogator',
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
    final horizontalPadding = MediaQuery.of(context).size.width < 370 ? 18.0 : 26.0;

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      appBar: AppBar(
        title: const Text(
          'Registro de socio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _header(),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 430),
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF07111F).withOpacity(.78),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(.14)),
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
                            _dropdownPerfil(),
                            if (perfilSeleccionado == 'Abogados')
                              _dropdownEspecialidad(),
                            _fotoBox(),
                            _campo(
                              nombreController,
                              'Nombres completos',
                              icon: Icons.person_outline_rounded,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Ingresa tu nombre';
                                }
                                return null;
                              },
                            ),
                            _campo(
                              correoController,
                              'Correo electrónico',
                              icon: Icons.email_outlined,
                              tipo: TextInputType.emailAddress,
                              validator: (v) {
                                final correo = v?.trim() ?? '';
                                if (correo.isEmpty) return 'Ingresa tu correo';
                                if (!correo.contains('@') || !correo.contains('.')) {
                                  return 'Correo inválido';
                                }
                                return null;
                              },
                            ),
                            _campo(
                              telefonoController,
                              'Teléfono',
                              icon: Icons.phone_outlined,
                              tipo: TextInputType.phone,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Ingresa tu teléfono';
                                }
                                if (v.trim().length < 10) {
                                  return 'Teléfono inválido';
                                }
                                return null;
                              },
                            ),
                            _campo(
                              contrasenaController,
                              'Contraseña',
                              icon: Icons.lock_outline_rounded,
                              esPassword: true,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Ingresa tu contraseña';
                                }
                                if (v.trim().length < 6) {
                                  return 'Mínimo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            _mensajeBox(),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: cargando ? null : continuarRegistro,
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
                                        'REGISTRARME',
                                        style: TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: cargando ? null : () => Navigator.pop(context),
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
      ),
    );
  }
}