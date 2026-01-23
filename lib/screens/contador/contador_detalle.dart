import 'package:flutter/material.dart';
import 'api_service_contador.dart'; // Importa tu servicio de contador

class ContadorDetalle extends StatefulWidget {
  final int idCaso; // ID del caso para actualizar en la API
  final String titulo;
  final String descripcion;
  final String cliente;
  final String documento; // ticket o archivo
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
  late String _estado; // Estado dinámico del caso
  bool _isUpdating = false;
  final TextEditingController _comentariosController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _estado = widget.estado;
  }

  Future<void> _actualizarEstado(String nuevoEstado) async {
    setState(() => _isUpdating = true);
    try {
      final mensaje =
          await ApiServiceContador.actualizarCaso(widget.idCaso, nuevoEstado);
      setState(() {
        _estado = nuevoEstado;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al actualizar estado: $e")),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _validarDocumento(String estatus) async {
    setState(() => _isUpdating = true);
    try {
      final mensaje = await ApiServiceContador.validarDocumento(
        widget.documento, // ticket o identificador del documento
        estatus,
        _comentariosController.text,
        1, // aquí pondrías el id del contador real
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al validar documento: $e")),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle del Caso/Documento"),
        backgroundColor: gold,
      ),
      body: Container(
        color: Colors.grey[100], // 🔹 Fondo más claro
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  widget.titulo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                // Cliente
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "Cliente: ${widget.cliente}",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Estado del caso
                Row(
                  children: [
                    Icon(
                      _estado == "abierto"
                          ? Icons.circle
                          : _estado == "cerrado"
                              ? Icons.check_circle
                              : Icons.timelapse,
                      color: _estado == "abierto"
                          ? Colors.green
                          : _estado == "cerrado"
                              ? Colors.red
                              : Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Estado: $_estado",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Descripción
                const Text(
                  "Descripción:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.descripcion,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 20),

                // Documento
                if (widget.documento.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.attach_file, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Documento/Ticket: ${widget.documento}",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("Abrir documento: ${widget.documento}"),
                            ),
                          );
                        },
                        child: Text(
                          "Ver",
                          style: TextStyle(color: gold),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Comentarios
                TextField(
                  controller: _comentariosController,
                  decoration: const InputDecoration(
                    labelText: "Comentarios",
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: Colors.black),
                  maxLines: 2,
                ),

                const Spacer(),

                // Botones de acción
                Center(
                  child: _isUpdating
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  onPressed: () async {
                                    await _validarDocumento("validado");
                                  },
                                  icon: const Icon(Icons.check),
                                  label: const Text("Validar"),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  onPressed: () async {
                                    await _validarDocumento("rechazado");
                                  },
                                  icon: const Icon(Icons.cancel),
                                  label: const Text("Rechazar"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              onPressed: () async {
                                await _actualizarEstado("cerrado"); // 👈 Se usa aquí
                              },
                              icon: const Icon(Icons.lock),
                              label: const Text("Cerrar caso"),
                            ),
                          ],
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