import 'package:flutter/material.dart';

// ✅ Importa tus layouts y helpers universales
import '../universal_panel_layout.dart';
import '../universal_location_button.dart';
import '../../widgets_global/ui_helpers.dart';

// ✅ Importa las pantallas nuevas
import 'pantalla_historial_servicios.dart';
import 'pantalla_agenda.dart';
import 'pantalla_ingresos.dart';
import 'pantalla_calificaciones.dart';
import 'pantalla_notificaciones.dart';
import 'pantalla_configuracion.dart';
import 'pantalla_contacto_soporte.dart';
import '../localizacion.dart'; // 🔹 Panel de localización

class PanelPsicologos extends StatelessWidget {
  final int psicologoId;

  const PanelPsicologos({super.key, required this.psicologoId});

  @override
  Widget build(BuildContext context) {
    final bool idValido = psicologoId > 0;

    return UniversalPanelLayout(
      titulo: "Panel de Psicólogos",
      accionesAppBar: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PantallaConfiguracion()),
            );
          },
        ),
      ],
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

        // 🔹 Accesos rápidos horizontales
        SizedBox(
          height: 90,
          child: Row(
            children: [
              UiHelpers.quickAction(
                context,
                icon: Icons.calendar_today,
                label: "Agenda",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PantallaAgenda()),
                  );
                },
              ),
              UiHelpers.quickAction(
                context,
                icon: Icons.history,
                label: "Historial",
                onTap: () {
                  if (idValido) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PantallaHistorialServicios(psicologoId: psicologoId),
                      ),
                    );
                  }
                },
              ),
              UiHelpers.quickAction(
                context,
                icon: Icons.attach_money,
                label: "Ingresos",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaIngresosPsicologos(profesionalId: psicologoId),
                    ),
                  );
                },
              ),
              UiHelpers.quickAction(
                context,
                icon: Icons.star,
                label: "Calificaciones",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaCalificacionesPsicologos(psicologoId: psicologoId),
                    ),
                  );
                },
              ),
              UiHelpers.quickAction(
                context,
                icon: Icons.notifications,
                label: "Notificaciones",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaNotificacionesPsicologos(psicologoId: psicologoId),
                    ),
                  );
                },
              ),
              UiHelpers.quickAction(
                context,
                icon: Icons.location_on_outlined,
                label: "Ubicación",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocalizacionPanel(
                        idProfesional: psicologoId,
                        perfil: "Psicólogos",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const Divider(),

        // 📅 Agenda
        ListTile(
          leading: const Icon(Icons.calendar_today, color: Colors.blue),
          title: const Text("Agenda / Citas"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PantallaAgenda()),
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
                      builder: (context) => PantallaHistorialServicios(psicologoId: psicologoId),
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
                builder: (context) => PantallaIngresosPsicologos(profesionalId: psicologoId),
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
                builder: (context) => PantallaCalificacionesPsicologos(psicologoId: psicologoId),
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
                builder: (context) => PantallaNotificacionesPsicologos(psicologoId: psicologoId),
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
              MaterialPageRoute(builder: (context) => const PantallaConfiguracion()),
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
              MaterialPageRoute(builder: (context) => const PantallaContactoSoporte()),
            );
          },
        ),

        const Divider(),

        // 📍 Botón de ubicación universal
        UniversalLocationButton(
          idProfesional: psicologoId,
          lat: 19.4326, // ejemplo latitud
          lng: -99.1332, // ejemplo longitud
        ),
      ],
    );
  }
}