import 'package:flutter/material.dart';
import 'agente_dashboard.dart';
import 'agente_clientes.dart';
import 'agente_perfil.dart';
import 'agente_notificaciones.dart';
import 'agente_calificaciones.dart';
import 'agente_casos.dart';
import 'widgets/agente_menu.dart';

class AgentePanel extends StatelessWidget {
  final int? idAgente;

  const AgentePanel({super.key, this.idAgente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Portal Agente Crediticio"),
        backgroundColor: Colors.blueGrey[700],
        elevation: 2,
      ),
      drawer: AgenteMenu(idAgente: idAgente),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              "Bienvenido Agente",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Botón Dashboard
            _buildButton(
              context,
              icon: Icons.dashboard,
              label: "Dashboard",
              screen: AgenteDashboard(idAgente: idAgente),
            ),

            // Botón Clientes
            _buildButton(
              context,
              icon: Icons.people,
              label: "Clientes",
              screen: AgenteClientes(idAgente: idAgente),
            ),

            // Botón Perfil
            _buildButton(
              context,
              icon: Icons.person,
              label: "Perfil",
              screen: AgentePerfil(idAgente: idAgente),
            ),

            // Botón Notificaciones
            _buildButton(
              context,
              icon: Icons.notifications,
              label: "Notificaciones",
              screen: AgenteNotificaciones(idAgente: idAgente),
            ),

            // Botón Calificaciones
            _buildButton(
              context,
              icon: Icons.star,
              label: "Calificaciones",
              screen: AgenteCalificaciones(idAgente: idAgente),
            ),

            // Botón Casos
            _buildButton(
              context,
              icon: Icons.folder,
              label: "Casos",
              screen: AgenteCasos(idAgente: idAgente),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required IconData icon, required String label, required Widget screen}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon),
        label: Text(label),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }
}