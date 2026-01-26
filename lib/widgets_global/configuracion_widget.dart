import 'package:flutter/material.dart';

class ConfiguracionWidget extends StatelessWidget {
  const ConfiguracionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey),
            title: Text("Configuración"),
            subtitle: Text("Ajustes generales del panel"),
          ),
        ],
      ),
    );
  }
}