import 'package:flutter/material.dart';

/// Menú universal para todos los portales
class UniversalMenu extends StatelessWidget {
  final void Function(String) onSelected;

  const UniversalMenu({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'configuracion',
          child: Text('Configuración'),
        ),
        const PopupMenuItem(
          value: 'cerrar',
          child: Text('Cerrar sesión'),
        ),
      ],
      icon: const Icon(Icons.more_vert, color: Colors.white),
    );
  }
}