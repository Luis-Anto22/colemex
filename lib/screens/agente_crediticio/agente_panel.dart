import 'package:flutter/material.dart';

// COMMON
import 'package:advocatus/screens/common/agenda/agenda_screen.dart';
import 'package:advocatus/screens/common/calificaciones/calificaciones_screen.dart';
import 'package:advocatus/screens/common/configuracion/configuracion_screen.dart';
import 'package:advocatus/screens/common/historial/historial_screen.dart';
import 'package:advocatus/screens/common/ingresos/ingresos_screen.dart';
import 'package:advocatus/screens/common/notificaciones/notificaciones_screen.dart';
import 'package:advocatus/screens/common/perfil/perfil_verificado_screen.dart';
import 'package:advocatus/screens/common/soporte/soporte_screen.dart';
import 'package:advocatus/screens/common/ubicacion/ubicacion_tiempo_real_screen.dart';

// WIDGET COMÚN
import 'package:advocatus/screens/common/estado_profesional/estado_profesional_widget.dart';

// MÓDULOS AGENTE CREDITICIO
import 'crediticio_modulo/solicitudes_credito_screen.dart';
import 'crediticio_modulo/clientes_interesados_credito_screen.dart';
import 'crediticio_modulo/simulador_credito_screen.dart';

class PanelAgenteCrediticio extends StatefulWidget {
  final int agenteId;

  const PanelAgenteCrediticio({
    super.key,
    required this.agenteId,
  });

  @override
  State<PanelAgenteCrediticio> createState() => _PanelAgenteCrediticioState();
}

class _PanelAgenteCrediticioState extends State<PanelAgenteCrediticio> {
  String estado = 'Disponible';

  void _go(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _abrirSolicitudesCredito() {
    _go(
      SolicitudesCreditoScreen(
        agenteId: widget.agenteId,
      ),
    );
  }

  void _abrirClientesInteresados() {
    _go(
      ClientesInteresadosCreditoScreen(
        agenteId: widget.agenteId,
      ),
    );
  }

  void _abrirSimuladorCredito() {
    _go(
      SimuladorCreditoScreen(
        agenteId: widget.agenteId,
      ),
    );
  }

  Widget _sectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              letterSpacing: .2,
              color: Colors.white,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.25,
                color: Colors.white.withOpacity(.70),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    final gold = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(.06),
        border: Border.all(color: gold.withOpacity(.18)),
      ),
      child: child,
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final gold = Theme.of(context).primaryColor;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(.05),
          border: Border.all(color: gold.withOpacity(.14)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: gold.withOpacity(.10),
                border: Border.all(color: gold.withOpacity(.18)),
              ),
              child: Icon(icon, color: gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.2,
                      color: Colors.white.withOpacity(.72),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(.60),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final gold = Theme.of(context).primaryColor;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        width: 150,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(.05),
          border: Border.all(color: gold.withOpacity(.14)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: gold),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 10);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? theme.primaryColor;

    final shadow = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withOpacity(.25),
        blurRadius: 22,
        offset: const Offset(0, 10),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
        title: const Text(
          'Panel • Agente Crediticio',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () => _go(const NotificacionesScreen()),
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            tooltip: 'Configuración',
            onPressed: () => _go(const ConfiguracionScreen()),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/iconos/mazo-libro.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(.62),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: gold.withOpacity(.18)),
                      color: const Color(0xFF12161C).withOpacity(.82),
                      boxShadow: shadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _card(
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: gold.withOpacity(.12),
                                  border: Border.all(
                                    color: gold.withOpacity(.20),
                                  ),
                                ),
                                child: Icon(
                                  Icons.account_balance_rounded,
                                  color: gold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Portal profesional',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Créditos • Solicitudes • Simulador',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.72),
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'ID agente: ${widget.agenteId}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.55),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: gold.withOpacity(.22),
                                  ),
                                  color: Colors.white.withOpacity(.04),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.circle, size: 10, color: gold),
                                    const SizedBox(width: 8),
                                    Text(
                                      estado,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        _sectionHeader(
                          'Estado profesional',
                          subtitle:
                              'Define tu disponibilidad para recibir clientes y solicitudes de crédito.',
                        ),
                        _card(
                          child: EstadoProfesionalWidget(
                            estadoActual: estado,
                            color: gold,
                            onChanged: (nuevoEstado) {
                              setState(() {
                                estado = nuevoEstado;
                              });
                            },
                          ),
                        ),

                        _sectionHeader('Acciones rápidas'),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _quickAction(
                              icon: Icons.request_quote_outlined,
                              label: 'Solicitudes',
                              onTap: _abrirSolicitudesCredito,
                            ),
                            _quickAction(
                              icon: Icons.person_search_outlined,
                              label: 'Clientes',
                              onTap: _abrirClientesInteresados,
                            ),
                            _quickAction(
                              icon: Icons.calculate_outlined,
                              label: 'Simulador',
                              onTap: _abrirSimuladorCredito,
                            ),
                            _quickAction(
                              icon: Icons.support_agent_outlined,
                              label: 'Soporte',
                              onTap: () => _go(const SoporteScreen()),
                            ),
                          ],
                        ),

                        _sectionHeader(
                          'Base común',
                          subtitle:
                              'Módulos obligatorios para todos los socios.',
                        ),
                        _tile(
                          icon: Icons.verified_user_outlined,
                          title: 'Perfil profesional verificado',
                          subtitle: 'Datos, foto, documentos y verificación.',
                          onTap: () => _go(const PerfilVerificadoScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.location_on_outlined,
                          title: 'Ubicación en tiempo real',
                          subtitle: 'Comparte ubicación cuando estés activo.',
                          onTap: () => _go(const UbicacionTiempoRealScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.event_available_outlined,
                          title: 'Agenda / citas',
                          subtitle: 'Disponibilidad, horarios y citas.',
                          onTap: () => _go(const AgendaScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.history,
                          title: 'Historial de servicios',
                          subtitle:
                              'Registros, cambios y cierres de solicitudes.',
                          onTap: () => _go(const HistorialScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.attach_money,
                          title: 'Ingresos / comisiones',
                          subtitle: 'Resumen, pagos y facturación.',
                          onTap: () => _go(const IngresosScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.star_outline,
                          title: 'Calificaciones',
                          subtitle: 'Promedio y comentarios.',
                          onTap: () => _go(const CalificacionesScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.notifications_none,
                          title: 'Notificaciones',
                          subtitle: 'Nuevas solicitudes y alertas.',
                          onTap: () => _go(const NotificacionesScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.settings_outlined,
                          title: 'Configuración',
                          subtitle: 'Cuenta, privacidad y preferencias.',
                          onTap: () => _go(const ConfiguracionScreen()),
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.support_agent_outlined,
                          title: 'Soporte técnico',
                          subtitle: 'Ayuda técnica y soporte.',
                          onTap: () => _go(const SoporteScreen()),
                        ),

                        _sectionHeader(
                          'Módulos del agente crediticio',
                          subtitle:
                              'Herramientas específicas para créditos y clientes interesados.',
                        ),
                        _tile(
                          icon: Icons.request_quote_outlined,
                          title: 'Solicitudes de crédito',
                          subtitle:
                              'Consulta solicitudes, monto requerido, estado, documentos y evaluación.',
                          onTap: _abrirSolicitudesCredito,
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.person_search_outlined,
                          title: 'Clientes interesados',
                          subtitle:
                              'Prospectos, mensajes, nivel de interés y contacto.',
                          onTap: _abrirClientesInteresados,
                        ),
                        _gap(),
                        _tile(
                          icon: Icons.calculate_outlined,
                          title: 'Simulador de crédito',
                          subtitle:
                              'Calcula pagos aproximados, plazo, monto y capacidad estimada.',
                          onTap: _abrirSimuladorCredito,
                        ),

                        const SizedBox(height: 12),
                        Text(
                          'Tip: Mantén tu estado y agenda actualizados para recibir más oportunidades.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(.65),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}