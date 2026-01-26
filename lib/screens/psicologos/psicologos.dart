import 'package:flutter/material.dart';

// ✅ Importa las pantallas nuevas
import 'pantalla_historial_servicios.dart';
import 'pantalla_agenda.dart';
import 'pantalla_ingresos.dart';
import 'pantalla_calificaciones.dart';
import 'pantalla_notificaciones.dart';
import 'pantalla_configuracion.dart';
import 'pantalla_contacto_soporte.dart';

class PanelPsicologos extends StatelessWidget {
  final int psicologoId;

  const PanelPsicologos({super.key, required this.psicologoId});

  @override
  Widget build(BuildContext context) {
    final bool idValido = psicologoId > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Psicólogos"),
        backgroundColor: const Color(0xFF6A1B9A), // 💜 color institucional psicólogos
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 👤 Encabezado con perfil
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: const Text("Nombre del Psicólogo"),
            subtitle: const Text("Disponible • Perfil verificado"),
            trailing: const Icon(Icons.verified, color: Colors.blue),
          ),
          const Divider(),

          // 📅 Agenda
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.blue),
            title: const Text("Agenda / Citas"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PantallaAgenda(),
                ),
              );
            },
          ),

          // 📁 Historial de servicios
          idValido
              ? ListTile(
                  leading: const Icon(Icons.history, color: Colors.orange),
                  title: const Text("Historial de Servicios"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PantallaHistorialServicios(psicologoId: psicologoId),
                      ),
                    );
                  },
                )
              : const ListTile(
                  leading: Icon(Icons.warning, color: Colors.orange),
                  title: Text("ID de psicólogo no válido"),
                ),

          // 💰 Ingresos
          ListTile(
            leading: const Icon(Icons.attach_money, color: Colors.green),
            title: const Text("Ingresos y Comisiones"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PantallaIngresosPsicologos(profesionalId: psicologoId), // ✅ conectado
                ),
              );
            },
          ),

          // ⭐ Calificaciones
          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text("Calificaciones"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PantallaCalificacionesPsicologos(psicologoId: psicologoId), // ✅ corregido
                ),
              );
            },
          ),

          // 🔔 Notificaciones
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.red),
            title: const Text("Notificaciones"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PantallaNotificacionesPsicologos(psicologoId: psicologoId), // ✅ corregido
                ),
              );
            },
          ),

          // ⚙️ Configuración
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text("Configuración"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PantallaConfiguracion(),
                ),
              );
            },
          ),

          // 📞 Contacto / Soporte
          ListTile(
            leading: const Icon(Icons.support_agent, color: Colors.purple),
            title: const Text("Contacto / Soporte"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PantallaContactoSoporte(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}