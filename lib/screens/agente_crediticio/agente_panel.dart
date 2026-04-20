import 'package:flutter/material.dart';

import 'agente_dashboard.dart';
import 'agente_clientes.dart';
import 'agente_perfil.dart';
import 'agente_notificaciones.dart';
import 'agente_calificaciones.dart';
import 'agente_casos.dart';

import '../universal_panel_layout.dart';
import '../../widgets_global/ui_helpers.dart';
import '../universal_menu.dart';
import '../localizacion.dart';
import '../../widgets/notification_badge_icon.dart';

class AgentePanel extends StatelessWidget {
  final int? idAgente;

  const AgentePanel({super.key, this.idAgente});

  void _go(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return UniversalPanelLayout(
      titulo: 'Portal • Agente Crediticio',
      accionesAppBar: [
        NotificationBadgeIcon(
          profesionalId: idAgente,
          onPressed: () =>
              _go(context, AgenteNotificaciones(idAgente: idAgente)),
        ),
        UniversalMenu(
          onSelected: (value) {
            if (value == 'cerrar') {
              Navigator.pushReplacementNamed(context, '/login');
            } else if (value == 'configuracion') {
              // Abrir pantalla de configuración
            }
          },
        ),
      ],
      children: [
        UiHelpers.sectionHeader(
          context,
          'Acciones rápidas',
          subtitle: 'Accede rápidamente a tus herramientas principales.',
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            UiHelpers.quickAction(
              context,
              icon: Icons.assignment,
              label: 'Solicitudes',
              onTap: () {
                // lógica de solicitudes
              },
            ),
            UiHelpers.quickAction(
              context,
              icon: Icons.location_on_outlined,
              label: 'Ubicación',
              onTap: () => _go(
                context,
                LocalizacionPanel(
                  idProfesional: idAgente,
                  perfil: 'Agentes crediticios',
                ),
              ),
            ),
            UiHelpers.quickAction(
              context,
              icon: Icons.calendar_today,
              label: 'Agenda',
              onTap: () {
                // lógica de agenda
              },
            ),
            UiHelpers.quickAction(
              context,
              icon: Icons.headset_mic,
              label: 'Soporte',
              onTap: () {
                // lógica de soporte
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        UiHelpers.sectionHeader(
          context,
          'Base común',
          subtitle: 'Módulos obligatorios para todos los socios.',
        ),
        UiHelpers.tile(
          context,
          icon: Icons.dashboard,
          title: 'Dashboard',
          subtitle: 'Resumen de actividad y métricas.',
          onTap: () => _go(context, AgenteDashboard(idAgente: idAgente)),
        ),
        const SizedBox(height: 12),
        UiHelpers.tile(
          context,
          icon: Icons.people,
          title: 'Clientes',
          subtitle: 'Lista de clientes asignados.',
          onTap: () => _go(context, AgenteClientes(idAgente: idAgente)),
        ),
        const SizedBox(height: 12),
        UiHelpers.tile(
          context,
          icon: Icons.person,
          title: 'Perfil',
          subtitle: 'Información profesional y documentos.',
          onTap: () => _go(context, AgentePerfil(idAgente: idAgente)),
        ),
        const SizedBox(height: 12),
        UiHelpers.tile(
          context,
          icon: Icons.star,
          title: 'Calificaciones',
          subtitle: 'Evaluaciones y comentarios recibidos.',
          onTap: () => _go(context, AgenteCalificaciones(idAgente: idAgente)),
        ),
        const SizedBox(height: 12),
        UiHelpers.tile(
          context,
          icon: Icons.folder,
          title: 'Casos',
          subtitle: 'Gestión de expedientes y seguimientos.',
          onTap: () => _go(context, AgenteCasos(idAgente: idAgente)),
        ),
        const SizedBox(height: 20),
        Text(
          'Tip: Mantén tu perfil y ubicación actualizados para recibir más asignaciones.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(.65),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}