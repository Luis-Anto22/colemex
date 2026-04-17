import 'package:flutter/material.dart';
import '../agente_dashboard.dart';
import '../agente_clientes.dart';
import '../agente_perfil.dart';

class AgenteMenu extends StatelessWidget {
  final int? idAgente;

  const AgenteMenu({super.key, this.idAgente});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFD4AF37),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: const AssetImage("assets/iconos/logo.png"),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Portal Agente Crediticio",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "colemex.com",
                    style: TextStyle(color: Colors.white70),
                  ),
                  if (idAgente != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "ID: $idAgente",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),

            // Dashboard
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFFD4AF37)),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgenteDashboard(idAgente: idAgente),
                  ),
                );
              },
            ),

            // Clientes
            ListTile(
              leading: const Icon(Icons.people, color: Color(0xFFD4AF37)),
              title: const Text("Clientes"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgenteClientes(idAgente: idAgente),
                  ),
                );
              },
            ),

            // Perfil
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFFD4AF37)),
              title: const Text("Perfil"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgentePerfil(idAgente: idAgente),
                  ),
                );
              },
            ),

            const Divider(),

            // Cerrar sesión
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Cerrar sesión"),
              onTap: () {
                Navigator.pushReplacementNamed(context, "/login");
              },
            ),
          ],
        ),
      ),
    );
  }
}