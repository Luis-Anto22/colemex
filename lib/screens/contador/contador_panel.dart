import 'package:flutter/material.dart';
import 'package:advocatus/screens/common/perfil/perfil_verificado_screen.dart';
import 'package:advocatus/screens/common/ubicacion/ubicacion_tiempo_real_screen.dart';
import 'package:advocatus/screens/common/ingresos/ingresos_screen.dart';
import 'package:advocatus/screens/common/calificaciones/calificaciones_screen.dart';
import 'package:advocatus/screens/common/notificaciones/notificaciones_screen.dart';
import 'package:advocatus/screens/common/configuracion/configuracion_screen.dart';

import 'contador_casos.dart';
import 'contador_perfil.dart';
import 'api_service_contador.dart';
import 'contador_clientes.dart';
import 'contador_cfdi.dart';
import 'contador_declaraciones.dart';
import 'nomina_empleados.dart';
import 'contador_reportes.dart';

class ContadorPanel extends StatefulWidget {
  final int? idContador;

  const ContadorPanel({super.key, this.idContador});

  @override
  State<ContadorPanel> createState() => _ContadorPanelState();
}

class _ContadorPanelState extends State<ContadorPanel> {
  String estado = 'Disponible';

  bool _verificado = false;
  int _rating = 0;
  int _notificaciones = 0;

  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _perfil;

  @override
  void initState() {
    super.initState();

    if (widget.idContador != null && widget.idContador! > 0) {
      _fetchPerfil(widget.idContador!);
      _fetchNotificaciones(widget.idContador!);
    } else {
      _isLoading = false;
    }
  }

  Future<void> _fetchPerfil(int id) async {
    try {
      final respuesta = await ApiServiceContador.obtenerPerfil(id);

      if (respuesta["success"] == true && respuesta["perfil"] != null) {
        final perfil = Map<String, dynamic>.from(respuesta["perfil"]);

        setState(() {
          _perfil = perfil;
          estado = perfil["estado"] == "disponible"
              ? "Disponible"
              : "Fuera de servicio";
          _verificado = perfil["verificado"] == 1 ||
              perfil["verificado"].toString() == "1";
          _rating = int.tryParse(perfil["rating"]?.toString() ?? "0") ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = respuesta["mensaje"] ?? "No se pudo cargar el perfil";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error al obtener perfil: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNotificaciones(int id) async {
    setState(() {
      _notificaciones = 3;
    });
  }

  void _go(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
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
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.5,
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
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(.60)),
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

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _estadoChip(String label) {
    final gold = Theme.of(context).primaryColor;
    final active = estado == label;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: active ? Colors.black : Colors.white,
        ),
      ),
      selected: active,
      onSelected: (_) => setState(() => estado = label),
      selectedColor: gold,
      backgroundColor: Colors.white.withOpacity(.06),
      shape: StadiumBorder(
        side: BorderSide(color: gold.withOpacity(.22)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? theme.primaryColor;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "❌ Error: $_error",
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
        title: const Text('Panel • Contador'),
        actions: [
          IconButton(
            tooltip: 'Configuración',
            onPressed: () => _go(const ConfiguracionScreen()),
            icon: const Icon(Icons.settings_outlined),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'cerrar') {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'cerrar',
                child: Text('Cerrar sesión'),
              ),
            ],
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
            child: Container(color: Colors.black.withOpacity(.62)),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.25),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
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
                                  Icons.account_balance_wallet_outlined,
                                  color: gold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _perfil?["nombre"] ??
                                          'Portal profesional',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Contabilidad • Finanzas • Reportes',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.72),
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                                  children: [
                                    Icon(Icons.circle, size: 10, color: gold),
                                    const SizedBox(width: 8),
                                    Text(
                                      estado,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
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
                              'Define tu disponibilidad para recibir solicitudes.',
                        ),
                        _card(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _estadoChip('Disponible'),
                              _estadoChip('Ocupado'),
                              _estadoChip('Fuera de servicio'),
                            ],
                          ),
                        ),

                        _sectionHeader('Acciones rápidas'),
                        Row(
                          children: [
                            _quickAction(
                              icon: Icons.folder_outlined,
                              label: 'Casos',
                              onTap: () => _go(
                                ContadorCasos(
                                  idContador: widget.idContador ?? 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.person_outline,
                              label: 'Perfil',
                              onTap: () => _go(
                                ContadorPerfil(
                                  idContador: widget.idContador ?? 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _quickAction(
                              icon: Icons.location_on_outlined,
                              label: 'Ubicación',
                              onTap: () => _go(
                                const UbicacionTiempoRealScreen(),
                              ),
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
                          subtitle: _verificado
                              ? 'Perfil verificado correctamente.'
                              : 'Sube documentos y completa tu validación.',
                          onTap: () => _go(const PerfilVerificadoScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.location_on_outlined,
                          title: 'Ubicación en tiempo real',
                          subtitle: 'Comparte ubicación cuando estés activo.',
                          onTap: () => _go(
                            const UbicacionTiempoRealScreen(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.attach_money,
                          title: 'Ingresos / comisiones',
                          subtitle: 'Resumen financiero del profesional.',
                          onTap: () => _go(const IngresosScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.star_outline,
                          title: 'Calificaciones',
                          subtitle:
                              'Promedio actual: $_rating de 5 estrellas.',
                          onTap: () => _go(const CalificacionesScreen()),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.notifications_none,
                          title: 'Notificaciones',
                          subtitle: 'Avisos y alertas ($_notificaciones).',
                          onTap: () => _go(
                            NotificacionesScreen(
                              profesionalId: widget.idContador ?? 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.settings_outlined,
                          title: 'Configuración',
                          subtitle: 'Cuenta y preferencias.',
                          onTap: () => _go(const ConfiguracionScreen()),
                        ),

                        _sectionHeader(
                          'Módulos del contador',
                          subtitle:
                              'Herramientas específicas para gestión contable.',
                        ),
                        _tile(
                          icon: Icons.bar_chart_outlined,
                          title: 'Reportes financieros',
                          subtitle: 'Ingresos, egresos, utilidad y PDF.',
                          onTap: () => _go(
                            ContadorReportes(
                              idContador: widget.idContador ?? 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.groups_outlined,
                          title: 'Nómina y empleados',
                          subtitle: 'Empleados, recibos, pagos y XML/PDF.',
                          onTap: () => _go(
                            NominaEmpleados(
                              idContador: widget.idContador ?? 0,
                             ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.account_balance_outlined,
                          title: 'Declaraciones SAT',
                          subtitle: 'Mensuales, anuales, IVA, ISR y acuses.',
                          onTap: () => _go(
                            ContadorDeclaraciones(
                              idContador: widget.idContador ?? 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.business_center_outlined,
                          title: 'Clientes y empresas',
                          subtitle: 'Gestión de clientes y relaciones contables.',
                          onTap: () => _go(
                            ContadorClientes(
                              idContador: widget.idContador ?? 0,
                            ),
                          ),
                        ),
                        _tile(
                          icon: Icons.receipt_long_outlined,
                          title: 'Facturación CFDI',
                          subtitle: 'Facturas, RFC, XML y control fiscal.',
                          onTap: () => _go(
                            ContadorCfdi(
                              idContador: widget.idContador ?? 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(height: 10),
                        _tile(
                          icon: Icons.folder_copy_outlined,
                          title: 'Casos contables',
                          subtitle: 'Solicitudes, trámites y seguimiento.',
                          onTap: () => _go(
                            ContadorCasos(
                              idContador: widget.idContador ?? 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tip: Mantén tu perfil y ubicación actualizados para recibir más casos.',
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