import 'package:flutter/material.dart';

// ✅ Importa las pantallas nuevas
import 'pantalla_agenda_inmuebles.dart';
import 'pantalla_propiedades.dart';
import 'pantalla_historial_inmuebles.dart';
import 'pantalla_ingresos_inmuebles.dart';
import 'pantalla_calificaciones_inmuebles.dart';
import 'pantalla_notificaciones_inmuebles.dart';
import 'pantalla_configuracion_inmuebles.dart';
import 'pantalla_contacto_soporte_inmuebles.dart';

class PanelAgentesInmobiliarios extends StatelessWidget {
  final int agenteId;

  const PanelAgentesInmobiliarios({super.key, required this.agenteId});

  @override
  Widget build(BuildContext context) {
    final bool idValido = agenteId > 0;

<<<<<<< Updated upstream
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Agentes Inmobiliarios"),
        backgroundColor: const Color(0xFFD4AF37), // Dorado institucional
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
            title: const Text("Nombre del Agente"),
            subtitle: const Text("Disponible • Perfil verificado"),
            trailing: const Icon(Icons.verified, color: Colors.blue),
=======
    return UniversalPanelLayout(
      titulo: "Panel de Agentes Inmobiliarios",
      accionesAppBar: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PantallaConfiguracionInmuebles()),
            );
          },
        ),
        UniversalMenu(
          onSelected: (value) {
            if (value == 'cerrar') {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
        ),
      ],
      children: [
        // 👤 Encabezado con perfil
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.person, color: Colors.white),
>>>>>>> Stashed changes
          ),
          const Divider(),

          // 📅 Agenda
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.blue),
            title: const Text("Agenda / Citas"),
            onTap: () {
              Navigator.push(
                context,
<<<<<<< Updated upstream
                MaterialPageRoute(
                  builder: (context) => const PantallaAgendaInmuebles(),
                ),
              );
            },
          ),

          // 🏠 Propiedades listadas
          ListTile(
            leading: const Icon(Icons.home, color: Colors.teal),
            title: const Text("Propiedades Listadas"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaPropiedades(agenteId: agenteId), // ✅ corregido
                ),
              );
            },
          ),

          // 📁 Historial de ventas/rentas
          idValido
              ? ListTile(
                  leading: const Icon(Icons.history, color: Colors.orange),
                  title: const Text("Historial de Operaciones"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PantallaHistorialInmuebles(agenteId: agenteId),
=======
                icon: Icons.calendar_today,
                label: "Agenda",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PantallaAgendaInmuebles()),
                  );
                },
              ),
              UiHelpers.quickAction(
                context,
                icon: Icons.home,
                label: "Propiedades",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PantallaPropiedades(agenteId: agenteId)),
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
                          builder: (context) =>
                              PantallaHistorialInmuebles(agenteId: agenteId)),
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
                        builder: (context) =>
                            PantallaIngresosInmuebles(profesionalId: agenteId)),
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
                        builder: (context) => PantallaCalificacionesInmuebles(
                            agenteId: agenteId)),
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
                        builder: (context) => PantallaNotificacionesInmuebles(
                            agenteId: agenteId)),
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
                        idProfesional: agenteId,
                        perfil: "Agentes inmobiliarios",
>>>>>>> Stashed changes
                      ),
                    );
                  },
                )
              : const ListTile(
                  leading: Icon(Icons.warning, color: Colors.orange),
                  title: Text("ID de agente no válido"),
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
                      PantallaIngresosInmuebles(profesionalId: agenteId), // ✅ conectado
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
                      PantallaCalificacionesInmuebles(agenteId: agenteId), // ✅ corregido
                ),
              );
            },
          ),

<<<<<<< Updated upstream
          // 🔔 Notificaciones
ListTile(
  leading: const Icon(Icons.notifications, color: Colors.red),
  title: const Text("Notificaciones"),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaNotificacionesInmuebles(agenteId: agenteId), // ✅ corregido
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
                  builder: (context) => const PantallaConfiguracionInmuebles(),
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
                  builder: (context) =>
                      const PantallaContactoSoporteInmuebles(),
                ),
              );
            },
          ),
        ],
      ),
=======
        // 📅 Agenda
        ListTile(
          leading: const Icon(Icons.calendar_today, color: Colors.blue),
          title: const Text("Agenda / Citas"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PantallaAgendaInmuebles()),
            );
          },
        ),

        // 🏠 Propiedades listadas
        ListTile(
          leading: const Icon(Icons.home, color: Colors.teal),
          title: const Text("Propiedades Listadas"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PantallaPropiedades(agenteId: agenteId)),
            );
          },
        ),

        // 📁 Historial de ventas/rentas
        idValido
            ? ListTile(
                leading: const Icon(Icons.history, color: Colors.orange),
                title: const Text("Historial de Operaciones"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PantallaHistorialInmuebles(agenteId: agenteId)),
                  );
                },
              )
            : const ListTile(
                leading: Icon(Icons.warning, color: Colors.orange),
                title: Text("ID de agente no válido"),
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
                      PantallaIngresosInmuebles(profesionalId: agenteId)),
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
                      PantallaCalificacionesInmuebles(agenteId: agenteId)),
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
                      PantallaNotificacionesInmuebles(agenteId: agenteId)),
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
                  builder: (context) => const PantallaConfiguracionInmuebles()),
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
                  builder: (context) =>
                      const PantallaContactoSoporteInmuebles()),
            );
          },
        ),

        const Divider(),

        // 📍 Botón de ubicación universal
        // Integracion:
        // Este boton delega el guardado a UniversalLocationButton,
        // que a su vez usa CommonApi + ApiClient para llamar al backend.
        UniversalLocationButton(
          idProfesional: agenteId,
        ),
      ],
>>>>>>> Stashed changes
    );
  }
}
