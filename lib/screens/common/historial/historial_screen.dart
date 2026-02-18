import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_client.dart';
import '../../../services/common_api.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final CommonApi api = CommonApi(ApiClient());
  bool cargando = true;
  String mensaje = '';
  List<dynamic> items = [];
  int profesionalId = 0;
  String perfil = '';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    profesionalId = prefs.getInt('id') ?? 0;
    perfil = (prefs.getString('perfil') ?? '').trim();
    if (profesionalId <= 0) {
      setState(() {
        cargando = false;
        mensaje = 'ID no valido';
      });
      return;
    }

    try {
      final data = await api.getHistorial(
        profesionalId: profesionalId,
        perfil: perfil,
      );
      if (!mounted) return;
      setState(() {
        items = data;
        cargando = false;
        mensaje = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        cargando = false;
        mensaje = 'Error: $e';
      });
    }
  }

  String _titleFor(Map<String, dynamic> item) {
    if (item['inmueble'] != null) {
      return 'Inmueble: ${item['inmueble']}';
    }
    if (item['operacion'] != null) {
      return 'Operacion: ${item['operacion']}';
    }
    if (item['servicio'] != null && item['detalle'] != null) {
      return item['servicio'].toString();
    }
    if (item['titulo'] != null) {
      return item['titulo'].toString();
    }
    return 'Servicio';
  }

  String _subtitleFor(Map<String, dynamic> item) {
    if (item['ubicacion'] != null) {
      return 'Ubicacion: ${item['ubicacion']}';
    }
    if (item['estado_anterior'] != null || item['estado_nuevo'] != null) {
      final a = (item['estado_anterior'] ?? '').toString();
      final n = (item['estado_nuevo'] ?? '').toString();
      if (a.isNotEmpty || n.isNotEmpty) {
        return 'Estado: $a -> $n';
      }
    }
    if (item['detalle'] != null) {
      return item['detalle'].toString();
    }
    if (item['estado'] != null) {
      return 'Estado: ${item['estado']}';
    }
    return '';
  }

  String _trailingFor(Map<String, dynamic> item) {
    if (item['fecha'] != null) return item['fecha'].toString();
    if (item['creado_en'] != null) return item['creado_en'].toString();
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de servicios'),
        actions: [
          IconButton(onPressed: _cargar, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.history, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text(
              'Historial',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'Servicios anteriores, cierres y detalles.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (cargando)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (items.isEmpty)
              Expanded(
                child: Center(
                  child: Text(mensaje.isEmpty ? 'Sin historial.' : mensaje),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final m = items[i] as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.folder_open, color: gold),
                        title: Text(_titleFor(m)),
                        subtitle: Text(_subtitleFor(m)),
                        trailing: Text(_trailingFor(m)),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
