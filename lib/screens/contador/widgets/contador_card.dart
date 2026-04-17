import 'package:flutter/material.dart';

class ContadorCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;
  final Color color;
  final String? subtitulo; // 🔹 Nuevo: texto adicional opcional
  final String? estado;    // 🔹 Nuevo: estado para badge visual
  final VoidCallback? onTap;
  final VoidCallback? onAction; // 🔹 Nuevo: acción secundaria (ej. ver detalle)

  const ContadorCard({
    super.key,
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.color,
    this.subtitulo,
    this.estado,
    this.onTap,
    this.onAction,
  });

  Color _getEstadoColor() {
    switch (estado) {
      case "validado":
        return Colors.green;
      case "rechazado":
        return Colors.red;
      case "pendiente":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icono, size: 40, color: color),
                  const SizedBox(height: 12),
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (subtitulo != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitulo!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    valor,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (onAction != null) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      onPressed: onAction,
                      child: const Text("Ver detalle"),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // 🔹 Badge de estado en la esquina superior derecha
          if (estado != null)
            Positioned(
              right: 12,
              top: 12,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: _getEstadoColor(),
              ),
            ),
        ],
      ),
    );
  }
}