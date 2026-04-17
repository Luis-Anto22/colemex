import 'package:flutter/material.dart';
import 'auditor_dashboard.dart';
import 'auditor_quejas.dart';
import 'auditor_calificaciones.dart';
import 'auditor_documentos.dart';

class AuditorPanel extends StatefulWidget {
  const AuditorPanel({super.key});

  @override
  State<AuditorPanel> createState() => _AuditorPanelState();
}

class _AuditorPanelState extends State<AuditorPanel> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AuditorDashboard(),
    AuditorQuejas(),
    AuditorCalificaciones(),
    AuditorDocumentos(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Auditores'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFD4AF37),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Quejas'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Calificaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Documentos'),
        ],
      ),
    );
  }
}