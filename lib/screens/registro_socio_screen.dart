import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class RegistroSocioScreen extends StatefulWidget {
  const RegistroSocioScreen({super.key});

  @override
  State<RegistroSocioScreen> createState() => _RegistroSocioScreenState();
}
class _RegistroSocioScreenState extends State<RegistroSocioScreen> {
  String? perfilSeleccionado;
  String? especialidad;
  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();
  final contrasenaController = TextEditingController();
  String mensaje = '';
  bool cargando = false;

  Uint8List? fotoBytes;
  String? fotoNombre;
  String? fotoPath;

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

  final ImagePicker _picker = ImagePicker();
    /// 📷 Tomar foto con la cámara
  Future<void> tomarFoto() async {
    var permiso = await Permission.camera.request();
    if (!permiso.isGranted) {
      setState(() => mensaje = '⚠️ Permiso de cámara denegado');
      return;
    }

    final foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      final bytes = await foto.readAsBytes();
      setState(() {
        fotoBytes = bytes;
        fotoNombre = foto.name;
        fotoPath = foto.path;
        mensaje = '📸 Foto tomada correctamente';
      });
    }
  }

  /// 🖼️ Seleccionar foto desde la galería
  Future<void> seleccionarDeGaleria() async {
  // ✅ Solicita permiso correcto para Android
  var permiso = await Permission.storage.request();

  if (!permiso.isGranted) {
    setState(() => mensaje = '⚠️ Permiso de galería denegado');
    return;
  }

  final imagen = await _picker.pickImage(source: ImageSource.gallery);

  if (imagen != null) {
    final bytes = await imagen.readAsBytes();
    setState(() {
      fotoBytes = bytes;
      fotoNombre = imagen.name;
      fotoPath = imagen.path;
      mensaje = '📸 Foto seleccionada correctamente';
    });
  } else {
    setState(() => mensaje = '⚠️ No se seleccionó ninguna imagen');
  }
}

    Future<void> continuarRegistro() async {
    final nombre = nombreController.text.trim();
    final correo = correoController.text.trim();
    final telefono = telefonoController.text.trim();
    final contrasena = contrasenaController.text.trim();

    if (nombre.isEmpty || correo.isEmpty || telefono.isEmpty || contrasena.isEmpty) {
      setState(() => mensaje = '❌ Completa todos los campos');
      return;
    }

    if (perfilSeleccionado == null) {
      setState(() => mensaje = '❌ Selecciona un perfil');
      return;
    }

    if (perfilSeleccionado == 'Abogados' && especialidad == null) {
      setState(() => mensaje = '❌ Selecciona una especialidad');
      return;
    }

    if ((fotoPath == null || fotoPath!.isEmpty) && fotoBytes == null) {
  setState(() => mensaje = '❌ Debes subir una foto de rostro');
  return;
    }


    
    setState(() {
      cargando = true;
      mensaje = '';
    });

    final url = Uri.parse('https://corporativolegaldigital.com/api/registro-abogado.php');
    final request = http.MultipartRequest('POST', url);

    request.fields['usuario'] = nombre;
    request.fields['contrasena'] = contrasena;
    request.fields['correo'] = correo;
    request.fields['telefono'] = telefono;
    request.fields['perfil'] = perfilSeleccionado ?? '';
    request.fields['especialidad'] = especialidad ?? '';
    request.fields['ciudad'] = 'Ciudad de México';

    if (fotoBytes != null) {
  // Si tienes los bytes (imagen cargada en memoria)
  request.files.add(http.MultipartFile.fromBytes(
    'foto',
    fotoBytes!,
    filename: fotoNombre ?? 'imagen.jpg',
    contentType: MediaType('image', 'jpeg'),
  ));
} else if (fotoPath != null && fotoPath!.isNotEmpty) {
  // Si tienes un path válido (Android/iOS)
  request.files.add(await http.MultipartFile.fromPath(
    'foto',
    fotoPath!,
    filename: fotoNombre,
    contentType: MediaType('image', 'jpeg'),
  ));
}

    try {
      final respuesta = await request.send();
      final cuerpo = await respuesta.stream.bytesToString();

      setState(() => cargando = false);

      if (respuesta.statusCode == 200 && cuerpo.startsWith('{')) {
        final datos = json.decode(cuerpo);
        final exito = datos['success'] == true;
        final texto = datos['mensaje'] ?? (exito ? '✅ Registro completado' : '❌ Error inesperado');

        setState(() => mensaje = texto);

        if (exito && mounted) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, '/login');
          });
        }
      } else {
        setState(() => mensaje = '❌ Error al conectar con el servidor');
      }
    } catch (e) {
      setState(() {
        cargando = false;
        mensaje = '❌ Error al enviar datos: $e';
      });
    }
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de socio'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecciona tu perfil:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              initialValue: perfilSeleccionado,
              items: perfiles.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (value) => setState(() => perfilSeleccionado = value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Selecciona un perfil',
              ),
            ),
            if (perfilSeleccionado == 'Abogados') ...[
              const SizedBox(height: 16),
              const Text('Especialidad:', style: TextStyle(fontSize: 16)),
              DropdownButtonFormField<String>(
                initialValue: especialidad,
                items: especialidades.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) => setState(() => especialidad = value),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Selecciona una especialidad',
                ),
              ),
            ],
            const SizedBox(height: 16),

            // ✅ Botones separados para foto
            ElevatedButton.icon(
              onPressed: cargando ? null : tomarFoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: cargando ? null : seleccionarDeGaleria,
              icon: const Icon(Icons.photo_library),
              label: const Text('Subir desde galería'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
              ),
            ),

            if (fotoBytes != null) ...[
              const SizedBox(height: 12),
              Image.memory(fotoBytes!, height: 150),
            ],

            const SizedBox(height: 16),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombres completos', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: correoController,
              decoration: const InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: telefonoController,
              decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
                        TextField(
              controller: contrasenaController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: cargando ? null : continuarRegistro,
              child: cargando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Continuar'),
            ),
            const SizedBox(height: 16),
            if (mensaje.isNotEmpty)
              Text(
                mensaje,
                style: TextStyle(
                  color: mensaje.startsWith('✅') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}