import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditarCasoScreen extends StatefulWidget {
  const EditarCasoScreen({super.key});

  @override
  State<EditarCasoScreen> createState() => _EditarCasoScreenState();
}

class _EditarCasoScreenState extends State<EditarCasoScreen> {
  Map<String, dynamic>? caso;
  final tituloController = TextEditingController();
  String estadoSeleccionado = 'en proceso';
  bool cargando = false;
  bool estadoInicializado = false;

  final List<String> estadosValidos = ['pendiente', 'en proceso', 'finalizado'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (estadoInicializado) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! Map<String, dynamic>) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ No se recibió el caso a editar')),
        );
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) Navigator.pop(context);
        });
      });
      return;
    }

    caso = args;
    tituloController.text = caso!['titulo'] ?? '';

    final estadoRecibido = (caso!['estado'] ?? 'en proceso').toString().trim();
    print('🟡 Estado recibido desde argumentos: $estadoRecibido');

    estadoSeleccionado = estadosValidos.contains(estadoRecibido)
        ? estadoRecibido
        : 'en proceso';

    print('🟠 Estado inicial asignado: $estadoSeleccionado');
    estadoInicializado = true;
  }

  Future<void> guardarCambios() async {
    final nuevoTitulo = tituloController.text.trim();
    final nuevoEstado = estadoSeleccionado.trim();

    print('🔵 Estado seleccionado para guardar: $nuevoEstado');

    final estadoOriginal = (caso!['estado'] ?? '').toString().trim();
    final tituloOriginal = (caso!['titulo'] ?? '').toString().trim();

    if (nuevoTitulo == tituloOriginal && nuevoEstado == estadoOriginal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ No hiciste ningún cambio')),
      );
      return;
    }

    setState(() => cargando = true);

    final prefs = await SharedPreferences.getInstance();
    final idAbogado = prefs.getInt('id') ?? 0;
    final idCaso = int.tryParse(caso!['id'].toString()) ?? 0;

    if (idCaso == 0 || idAbogado == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ ID inválido')),
      );
      setState(() => cargando = false);
      return;
    }

    final respuesta = await http.post(
      Uri.parse('http://192.168.100.9/COLEMEX/api/actualizar-caso.php'),
      body: {
        'id_caso': idCaso.toString(),
        'id_abogado': idAbogado.toString(),
        'titulo': nuevoTitulo,
        'estado': nuevoEstado,
      },
    );

    print('🟢 Respuesta cruda del backend: ${respuesta.body}');

    try {
      final datos = json.decode(respuesta.body);
      setState(() => cargando = false);

      if (!mounted) return;

      if (datos['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cambios guardados correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${datos['message']}')),
        );
      }
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al interpretar respuesta: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar caso'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(labelText: 'Título del caso'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: estadoSeleccionado,
              items: estadosValidos.map((estado) {
                return DropdownMenuItem(value: estado, child: Text(estado));
              }).toList(),
              onChanged: (valor) {
                print('🟣 Estado cambiado por el usuario: $valor');
                setState(() => estadoSeleccionado = valor!);
              },
              decoration: const InputDecoration(labelText: 'Estado'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: cargando ? null : guardarCambios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Guardar cambios'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}