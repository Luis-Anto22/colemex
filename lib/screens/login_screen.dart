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
  final correoController = TextEditingController();
  final claveController = TextEditingController();

  bool cargando = false;
  String mensajeError = '';
  String tipoLogin = 'cliente';

  // ✅ NORMALIZACIÓN ÚNICA Y CORRECTA
  String normalizarPerfil(String perfil) {
    return perfil
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll(' ', '_');
  }

  Future<void> iniciarSesion() async {
    final correo = correoController.text.trim();
    final clave = claveController.text.trim();

    if (correo.isEmpty || clave.isEmpty) {
      setState(() => mensajeError = '❌ Completa todos los campos');
      return;
    }

    setState(() {
      cargando = true;
      mensajeError = '';
    });

    final url = Uri.parse(
      tipoLogin == 'cliente'
          ? 'https://corporativolegaldigital.com/api/login-cliente.php'
          : 'https://corporativolegaldigital.com/api/login-abogado.php',
    );

    try {
      final res = await http.post(url, body: {
        'correo': correo,
        'contrasena': clave,
      });

      final data = json.decode(res.body);

      if (data['success'] != true) {
        setState(() {
          cargando = false;
          mensajeError = data['mensaje'] ?? 'Credenciales incorrectas';
        });
        return;
      }

      final u = data['usuario'];

      final int id = int.parse(u['id'].toString());
      final String nombre = u['nombre'];
      final String correoBd = u['correo'];

      // ✅ AQUÍ SÍ USAMOS LA FUNCIÓN
      final String perfil = normalizarPerfil(u['perfil']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('id', id);
      await prefs.setString('perfil', perfil);
      await prefs.setString('nombre', nombre);
      await prefs.setString('correo', correoBd);

      if (!mounted) return;

      setState(() => cargando = false);
      _redirigirSegunPerfil(perfil, id);

    } catch (e) {
      setState(() {
        cargando = false;
        mensajeError = '❌ Error de conexión con el servidor';
      });
    }
  }

  void _redirigirSegunPerfil(String perfil, int id) {
    switch (perfil) {
      case 'admin':
      case 'administrador':
        Navigator.pushReplacementNamed(context, '/panel-admin-home');
        break;

      case 'abogados':
        Navigator.pushReplacementNamed(context, '/panel-abogado', arguments: id);
        break;

      case 'investigadores':
        Navigator.pushReplacementNamed(context, '/panel-investigador', arguments: id);
        break;

      case 'psicologos':
        Navigator.pushReplacementNamed(context, '/panel-psicologos', arguments: id);
        break;

      case 'contadores':
        Navigator.pushReplacementNamed(context, '/panel-contador', arguments: id);
        break;

      case 'valuadores':
        Navigator.pushReplacementNamed(context, '/panel-valuador', arguments: id);
        break;

      case 'ajustadores':
        Navigator.pushReplacementNamed(context, '/panel-ajustador', arguments: id);
        break;

      case 'peritos_en_criminalistica':   // 🔹 Ajuste agregado
        Navigator.pushReplacementNamed(context, '/panel-perito', arguments: id);
        break;

      case 'agentes_crediticios':
        Navigator.pushReplacementNamed(context, '/panel-agente', arguments: id);
        break;

      case 'agentes_inmobiliarios':
        Navigator.pushReplacementNamed(context, '/panel-inmuebles', arguments: id);
        break;

      case 'cliente':
        Navigator.pushReplacementNamed(context, '/panel-cliente');
        break;

      default:
        setState(() {
          mensajeError = 'Perfil no reconocido: $perfil';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/iconos/mazo-libro.png"), // 🔹 Fondo
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // 🔹 Logo arriba del texto
                Image.asset(
                  "assets/iconos/logo.png",
                  height: 120,
                ),
                const SizedBox(height: 20),

                const Text(
                  'SELECCIONA TU PERFIL',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white, // texto blanco para contraste
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                ToggleButtons(
                  isSelected: [tipoLogin == 'cliente', tipoLogin == 'profesional'],
                  onPressed: (i) {
                    setState(() {
                      tipoLogin = i == 0 ? 'cliente' : 'profesional';
                    });
                  },
                  children: const [
                    Padding(padding: EdgeInsets.all(12), child: Text('CLIENTE')),
                    Padding(padding: EdgeInsets.all(12), child: Text('PROFESIONAL')),
                  ],
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: correoController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: claveController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                ),
                const SizedBox(height: 20),

                if (mensajeError.isNotEmpty)
                  Text(
                    mensajeError,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: cargando ? null : iniciarSesion,
                  child: cargando
                      ? const CircularProgressIndicator()
                      : const Text('Iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}