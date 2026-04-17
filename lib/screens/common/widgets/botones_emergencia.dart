import 'package:flutter/material.dart';

class BotonesEmergencia extends StatelessWidget {
  final void Function(String tipo) onBuscar;

  const BotonesEmergencia({super.key, required this.onBuscar});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => onBuscar('civil'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('🚗 Emergencia Civil'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => onBuscar('penal'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('⚖️ Emergencia Penal'),
        ),
      ],
    );
  }
}
