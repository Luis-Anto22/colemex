import 'package:flutter/material.dart';
import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/valuador_api.dart';

class SolicitudesAvaluoScreen extends StatefulWidget {
  final int valuadorId;

  const SolicitudesAvaluoScreen({
    super.key,
    required this.valuadorId,
  });

  @override
  State<SolicitudesAvaluoScreen> createState() =>
      _SolicitudesAvaluoScreenState();
}

class _SolicitudesAvaluoScreenState extends State<SolicitudesAvaluoScreen> {
  late final ValuadorApi api;
  late Future<List<dynamic>> future;

  bool loadingEstado = false;

  @override
  void initState() {
    super.initState();
    api = ValuadorApi(ApiClient());
    future = api.getSolicitudes(widget.valuadorId);
  }

  Future<void> _reload() async {
    setState(() {
      future = api.getSolicitudes(widget.valuadorId);
    });
  }

  Future<void> _cambiarEstado(int id, String estado) async {
    setState(() {
      loadingEstado = true;
    });

    try {
      await api.actualizarEstadoSolicitud(id: id, estado: estado);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud actualizada')),
      );

      await _reload();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() {
      loadingEstado = false;
    });
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

  IconData _iconEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.schedule;
      case 'en proceso':
        return Icons.build;
      case 'finalizado':
        return Icons.check_circle;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de avalúo'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}'),
            );
          }

          final items = snap.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text('No hay solicitudes pendientes.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final s = items[i] as Map<String, dynamic>;

                final id = int.tryParse(s['id'].toString()) ?? 0;
                final estado = (s['estado'] ?? 'pendiente').toString();
                final titulo = (s['titulo'] ?? 'Sin título').toString();
                final descripcion = (s['descripcion'] ?? '').toString();
                final fecha = (s['fecha_creacion'] ?? '').toString();

                return Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(
                      _iconEstado(estado),
                      color: _colorEstado(estado),
                    ),
                    title: Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(descripcion),
                        const SizedBox(height: 4),
                        Text(
                          "Fecha: $fecha",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: loadingEstado
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : PopupMenuButton<String>(
                            onSelected: (v) => _cambiarEstado(id, v),
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'pendiente',
                                child: Text('Pendiente'),
                              ),
                              PopupMenuItem(
                                value: 'en proceso',
                                child: Text('En proceso'),
                              ),
                              PopupMenuItem(
                                value: 'finalizado',
                                child: Text('Finalizado'),
                              ),
                              PopupMenuItem(
                                value: 'cancelado',
                                child: Text('Cancelado'),
                              ),
                            ],
                            child: Chip(
                              label: Text(estado),
                              backgroundColor:
                                  _colorEstado(estado).withOpacity(.15),
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