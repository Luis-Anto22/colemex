import 'package:flutter/material.dart';
import '../../../services/api_client.dart';
import '../../../services/valuador_api.dart';

class SolicitudesAvaluoScreen extends StatefulWidget {
  const SolicitudesAvaluoScreen({super.key});

  @override
  State<SolicitudesAvaluoScreen> createState() =>
      _SolicitudesAvaluoScreenState();
}

class _SolicitudesAvaluoScreenState extends State<SolicitudesAvaluoScreen> {
  final int valuadorId = 1; // TODO: real
  late final ValuadorApi api;
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    api = ValuadorApi(ApiClient());
    future = api.getSolicitudes(valuadorId);
  }

  Future<void> _reload() async {
    setState(() {
      future = api.getSolicitudes(valuadorId);
    });
  }

  Future<void> _cambiarEstado(int id, String estado) async {
    try {
      await api.actualizarEstadoSolicitud(id: id, estado: estado);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud actualizada')));
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      case 'finalizado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de avalúo'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No hay solicitudes pendientes.'));
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final s = items[i] as Map<String, dynamic>;
                final id = int.parse(s['id'].toString());
                final estado = (s['estado'] ?? '').toString();

                return Card(
                  child: ListTile(
                    title: Text((s['titulo'] ?? 'Sin título').toString()),
                    subtitle:
                        Text((s['descripcion'] ?? '').toString()),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) => _cambiarEstado(id, v),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                            value: 'pendiente', child: Text('Pendiente')),
                        PopupMenuItem(
                            value: 'en proceso', child: Text('En proceso')),
                        PopupMenuItem(
                            value: 'finalizado', child: Text('Finalizado')),
                        PopupMenuItem(
                            value: 'cancelado', child: Text('Cancelado')),
                      ],
                      child: Chip(
                        label: Text(estado.isEmpty ? 'pendiente' : estado),
                        backgroundColor: _colorEstado(estado).withOpacity(.15),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
