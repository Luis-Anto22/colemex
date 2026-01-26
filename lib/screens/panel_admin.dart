import 'package:flutter/material.dart';
import 'admin/panel_admin_home.dart'; // Vista principal del admin

class PanelAdmin extends StatelessWidget {
  const PanelAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panel Administrador COLEMEX',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PanelAdminHome(), // Redirige al panel modular
      debugShowCheckedModeBanner: false,
    );
  }
}