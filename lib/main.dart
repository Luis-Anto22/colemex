import 'package:flutter/material.dart';

// 👩‍⚕️ Panel de psicólogos
import 'screens/psicologos/psicologos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'COLEMEX',
      theme: ThemeData(primarySwatch: Colors.indigo),

      // ✅ Arranca directamente en el panel de psicólogos
      home: const PanelPsicologos(psicologoId: 1), // 👈 aquí puedes poner el ID real
    );
  }
}