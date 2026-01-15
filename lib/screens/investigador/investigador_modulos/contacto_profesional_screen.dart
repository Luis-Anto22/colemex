import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ContactoProfesionalScreen extends StatefulWidget {
  const ContactoProfesionalScreen({super.key});

  @override
  State<ContactoProfesionalScreen> createState() =>
      _ContactoProfesionalScreenState();
}

class _ContactoProfesionalScreenState extends State<ContactoProfesionalScreen> {
  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final notasCtrl = TextEditingController();

  bool cargando = false;
  String mensaje = '';

  // ✅ Cambia este endpoint por el tuyo cuando exista
  final String endpoint = 'https://corporativolegaldigital.com/api/contacto_profesional.php';

  Color get gold => Theme.of(context).primaryColor;
  Color get headerBg =>
      Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor;

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: headerBg,
      ),
    );
  }

  Future<void> enviarContacto() async {
    final nombre = nombreCtrl.text.trim();
    final correo = correoCtrl.text.trim();
    final telefono = telefonoCtrl.text.trim();
    final notas = notasCtrl.text.trim();

    if (nombre.isEmpty || correo.isEmpty || telefono.isEmpty) {
      setState(() => mensaje = '❌ Completa nombre, correo y teléfono');
      return;
    }

    setState(() {
      cargando = true;
      mensaje = '';
    });

    try {
      final res = await http.post(
        Uri.parse(endpoint),
        body: {
          'nombre': nombre,
          'correo': correo,
          'telefono': telefono,
          'notas': notas,
        },
      );

      final body = res.body.trim();
      if (res.statusCode == 200 && body.startsWith('{')) {
        final data = json.decode(body);
        final ok = data['success'] == true || data['status'] == 'success';
        setState(() => mensaje = ok
            ? '✅ ${data['message'] ?? data['mensaje'] ?? 'Enviado correctamente'}'
            : '❌ ${data['message'] ?? data['mensaje'] ?? 'No se pudo enviar'}');
      } else {
        setState(() => mensaje = '❌ Respuesta inválida del servidor');
      }
    } catch (e) {
      setState(() => mensaje = '❌ Error de conexión: $e');
    } finally {
      setState(() => cargando = false);
    }
  }

  Future<void> llamar() async {
    final tel = telefonoCtrl.text.trim();
    if (tel.isEmpty) {
      toast('⚠️ Escribe un teléfono primero');
      return;
    }
    final uri = Uri.parse('tel:$tel');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      toast('❌ No se pudo abrir el marcador');
    }
  }

  Future<void> mandarWhatsApp() async {
    final tel = telefonoCtrl.text.trim().replaceAll(' ', '');
    if (tel.isEmpty) {
      toast('⚠️ Escribe un teléfono primero');
      return;
    }
    // México: si quieres forzar +52, ponlo aquí
    final uri = Uri.parse('https://wa.me/$tel');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      toast('❌ No se pudo abrir WhatsApp');
    }
  }

  InputDecoration dec(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(.85)),
      prefixIcon: icon == null ? null : Icon(icon, color: gold.withOpacity(.95)),
      filled: true,
      fillColor: Colors.white.withOpacity(.06),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: gold.withOpacity(.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: gold.withOpacity(.9), width: 2),
      ),
    );
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    correoCtrl.dispose();
    telefonoCtrl.dispose();
    notasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
        title: const Text('Contacto profesional'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/iconos/mazo-libro.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(.62)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: gold.withOpacity(.22)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF12161C).withOpacity(.88),
                          const Color(0xFF181E26).withOpacity(.92),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.30),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Datos de contacto',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: nombreCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: dec('Nombre', icon: Icons.person),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: correoCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: dec('Correo', icon: Icons.email),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: telefonoCtrl,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                          decoration: dec('Teléfono', icon: Icons.phone),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: notasCtrl,
                          maxLines: 4,
                          style: const TextStyle(color: Colors.white),
                          decoration: dec('Notas / Horario / Oficina', icon: Icons.notes),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: cargando ? null : llamar,
                                icon: const Icon(Icons.call),
                                label: const Text('Llamar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(color: gold.withOpacity(.65)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: cargando ? null : mandarWhatsApp,
                                icon: const Icon(Icons.chat),
                                label: const Text('WhatsApp'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(color: gold.withOpacity(.65)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: cargando ? null : enviarContacto,
                            icon: const Icon(Icons.send),
                            label: cargando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Guardar / Enviar'),
                          ),
                        ),

                        if (mensaje.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            mensaje,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: mensaje.startsWith('✅')
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
