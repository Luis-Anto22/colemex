import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services/api_client.dart';
import '../../services/api_services/calificaciones_api.dart';

class CalificarProfesionalScreen extends StatefulWidget {
  final int profesionalId;
  final int? casoId;
  final int? notificacionId;
  final String? nombreProfesional;

  const CalificarProfesionalScreen({
    super.key,
    required this.profesionalId,
    this.casoId,
    this.notificacionId,
    this.nombreProfesional,
  });

  @override
  State<CalificarProfesionalScreen> createState() =>
      _CalificarProfesionalScreenState();
}

class _CalificarProfesionalScreenState
    extends State<CalificarProfesionalScreen> {
  final CalificacionesApi _api = CalificacionesApi(ApiClient());
  final TextEditingController _comentarioCtrl = TextEditingController();

  int _estrellas = 5;
  bool _guardando = false;

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando) return;

    final prefs = await SharedPreferences.getInstance();
    final clienteId = prefs.getInt('id') ?? 0;

    if (clienteId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar al cliente')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      await _api.crearCalificacion(
        profesionalId: widget.profesionalId,
        clienteId: clienteId,
        estrellas: _estrellas,
        comentario: _comentarioCtrl.text.trim(),
        casoId: widget.casoId,
        notificacionId: widget.notificacionId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calificación enviada correctamente')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );

      if (msg.contains('Ya calificaste')) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.nombreProfesional?.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calificar profesional'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Icon(
            Icons.star_rounded,
            size: 72,
            color: Color(0xFFF59E0B),
          ),
          const SizedBox(height: 12),
          Text(
            nombre == null || nombre.isEmpty
                ? 'Califica al profesional'
                : 'Califica a $nombre',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu opinión ayuda a otros clientes a elegir mejor.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final value = index + 1;
              final selected = value <= _estrellas;

              return IconButton(
                onPressed: () {
                  setState(() => _estrellas = value);
                },
                icon: Icon(
                  selected ? Icons.star_rounded : Icons.star_border_rounded,
                  color: const Color(0xFFF59E0B),
                  size: 40,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _comentarioCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Comentario opcional',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: const Icon(Icons.send_rounded),
            label: Text(_guardando ? 'Enviando...' : 'Enviar calificación'),
          ),
        ],
      ),
    );
  }
}