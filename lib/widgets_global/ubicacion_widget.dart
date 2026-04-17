import 'package:flutter/material.dart';

class UbicacionWidget extends StatelessWidget {
  const UbicacionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const ciudad = "Xico, Veracruz"; // 🔧 luego vendrá de la BD/API

    return Card(
      child: const ListTile(
        leading: Icon(Icons.location_on, color: Colors.red),
        title: Text("Ubicación"),
        subtitle: Text(ciudad),
      ),
    );
  }
}