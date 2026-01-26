import 'package:flutter/material.dart';
import 'api_service_crediticio.dart';

class AgenteCalificaciones extends StatefulWidget {
  final int? idAgente;
  const AgenteCalificaciones({super.key, this.idAgente});

  @override
  State<AgenteCalificaciones> createState() => _AgenteCalificacionesState();
}

class _AgenteCalificacionesState extends State<AgenteCalificaciones> {
  List<dynamic> _calificaciones = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarCalificaciones();
  }

  Future<void> _cargarCalificaciones() async {
    try {
      final data = await ApiServiceCrediticio.listarCalificaciones(widget.idAgente ?? 0);
      setState(() {
        _calificaciones = data;
        _cargando = false;
      });
    } catch (e) {
      debugPrint("❌ Error al cargar calificaciones: $e");
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calificaciones Recibidas"),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _calificaciones.isEmpty
              ? const Center(child: Text("No hay calificaciones registradas"))
              : ListView.builder(
                  itemCount: _calificaciones.length,
                  itemBuilder: (context, index) {
                    final cal = _calificaciones[index];
                    final estrellas = cal["estrellas"] ?? 0;
                    final comentario = cal["comentario"] ?? "";
                    final fecha = cal["fecha"] ?? "";

                    return ListTile(
                      leading: Icon(Icons.star, color: Colors.amber[700]),
                      title: Text("$estrellas estrellas"),
                      subtitle: Text(comentario),
                      trailing: Text(fecha),
                    );
                  },
                ),
    );
  }
}