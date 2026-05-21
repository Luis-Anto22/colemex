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
  State<SolicitudesAvaluoScreen> createState() => _SolicitudesAvaluoScreenState();
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
    if (id <= 0) return;

    setState(() => loadingEstado = true);

    try {
      await api.actualizarEstadoSolicitud(id: id, estado: estado);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            estado == 'en proceso'
                ? 'Solicitud aceptada correctamente'
                : estado == 'cancelado'
                    ? 'Solicitud rechazada correctamente'
                    : 'Solicitud actualizada',
          ),
        ),
      );

      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => loadingEstado = false);
    }
  }

  Future<void> _editarSolicitud(Map<String, dynamic> item) async {
    final id = int.tryParse(item['id'].toString()) ?? 0;
    if (id <= 0) return;

    String estado = (item['estado'] ?? 'pendiente').toString();

    final guardar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar solicitud'),
        content: DropdownButtonFormField<String>(
          value: estado,
          decoration: const InputDecoration(labelText: 'Estado'),
          items: const [
            DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
            DropdownMenuItem(value: 'en proceso', child: Text('En proceso')),
            DropdownMenuItem(value: 'finalizado', child: Text('Finalizado')),
            DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
          ],
          onChanged: (v) {
            if (v != null) estado = v;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (guardar == true) {
      await _cambiarEstado(id, estado);
    }
  }

  Future<void> _eliminarSolicitud(Map<String, dynamic> item) async {
    final id = int.tryParse(item['id'].toString()) ?? 0;
    if (id <= 0) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar solicitud'),
        content: Text(
          '¿Seguro que quieres eliminar "${(item['titulo'] ?? 'esta solicitud').toString()}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await api.eliminarSolicitud(solicitudId: id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud eliminada correctamente')),
      );

      await _reload();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase().trim()) {
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
    switch (estado.toLowerCase().trim()) {
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

  String _estadoLabel(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'pendiente':
        return 'Pendiente';
      case 'en proceso':
        return 'En proceso';
      case 'finalizado':
        return 'Finalizado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado.isEmpty ? 'Sin estado' : estado;
    }
  }

  Widget _chipEstado(String estado) {
    final color = _colorEstado(estado);

    return Chip(
      label: Text(
        _estadoLabel(estado),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withOpacity(.15),
      side: BorderSide(color: color.withOpacity(.25)),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _botonesAceptarRechazar({
    required int id,
    required String estado,
  }) {
    if (estado.toLowerCase().trim() != 'pendiente') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: loadingEstado ? null : () => _cambiarEstado(id, 'en proceso'),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Aceptar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: loadingEstado ? null : () => _cambiarEstado(id, 'cancelado'),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Rechazar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _solicitudCard(Map<String, dynamic> s) {
    final id = int.tryParse(s['id'].toString()) ?? 0;
    final estado = (s['estado'] ?? 'pendiente').toString();
    final titulo = (s['titulo'] ?? 'Sin título').toString();
    final descripcion = (s['descripcion'] ?? '').toString();
    final fecha = (s['fecha_creacion'] ?? '').toString();

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconEstado(estado), color: _colorEstado(estado)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (descripcion.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(descripcion),
                  ],
                  const SizedBox(height: 6),
                  Text('Fecha: $fecha', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  _chipEstado(estado),
                  _botonesAceptarRechazar(id: id, estado: estado),
                ],
              ),
            ),
            loadingEstado
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'editar') {
                        _editarSolicitud(s);
                      } else if (v == 'eliminar') {
                        _eliminarSolicitud(s);
                      } else {
                        _cambiarEstado(id, v);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'editar', child: Text('Editar')),
                      PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                      PopupMenuDivider(),
                      PopupMenuItem(value: 'pendiente', child: Text('Pendiente')),
                      PopupMenuItem(value: 'en proceso', child: Text('En proceso')),
                      PopupMenuItem(value: 'finalizado', child: Text('Finalizado')),
                      PopupMenuItem(value: 'cancelado', child: Text('Cancelado')),
                    ],
                  ),
          ],
        ),
      ),
    );
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
          ),
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
                return _solicitudCard(s);
              },
            ),
          );
        },
      ),
    );
  }
}