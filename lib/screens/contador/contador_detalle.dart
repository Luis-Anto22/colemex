import 'package:flutter/material.dart';

import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/common_api.dart';

class ContadorDetalle extends StatefulWidget {
  final int idCaso;
  final String titulo;
  final String descripcion;
  final String cliente;
  final String documento;
  final String estado;

  const ContadorDetalle({
    super.key,
    required this.idCaso,
    required this.titulo,
    required this.descripcion,
    required this.cliente,
    required this.documento,
    required this.estado,
  });

  @override
  State<ContadorDetalle> createState() => _ContadorDetalleState();
}

class _ContadorDetalleState extends State<ContadorDetalle> {
  late String _estado;
  bool _isUpdating = false;
  late final CommonApi commonApi;

  final List<String> _estados = [
    'pendiente',
    'en proceso',
    'finalizado',
    'cancelado',
  ];

  @override
  void initState() {
    super.initState();
    _estado = widget.estado;
    commonApi = CommonApi(ApiClient());
  }

  Color _estadoColor(String estado) {
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

  IconData _estadoIcon(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.schedule;
      case 'en proceso':
        return Icons.timelapse;
      case 'finalizado':
        return Icons.check_circle;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _actualizarEstado(String nuevoEstado) async {
    if (nuevoEstado == _estado) return;

    setState(() => _isUpdating = true);

    try {
      await commonApi.actualizarEstadoCasoUniversal(
        casoId: widget.idCaso,
        estado: nuevoEstado,
      );

     const mensaje = 'Estado actualizado correctamente';

      if (!mounted) return;

      setState(() {
        _estado = nuevoEstado;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al actualizar estado: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle del caso"),
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.titulo.isEmpty ? 'Caso contable' : widget.titulo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Cliente: ${widget.cliente.isEmpty ? 'N/A' : widget.cliente}",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(
                      _estadoIcon(_estado),
                      color: _estadoColor(_estado),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Estado actual: $_estado",
                      style: TextStyle(
                        color: _estadoColor(_estado),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Cambiar estado",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _estados.contains(_estado) ? _estado : 'pendiente',
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Estado del caso',
                  ),
                  items: _estados.map((estado) {
                    return DropdownMenuItem<String>(
                      value: estado,
                      child: Text(estado),
                    );
                  }).toList(),
                  onChanged: _isUpdating
                      ? null
                      : (value) {
                          if (value != null) {
                            _actualizarEstado(value);
                          }
                        },
                ),

                const SizedBox(height: 24),

                const Text(
                  "Descripción",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  widget.descripcion.isEmpty
                      ? 'Sin descripción.'
                      : widget.descripcion,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.35,
                  ),
                ),

                if (widget.documento.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.attach_file, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Documento: ${widget.documento}",
                          style: const TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const Spacer(),

                if (_isUpdating)
                  const Center(child: CircularProgressIndicator())
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Volver a casos"),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}