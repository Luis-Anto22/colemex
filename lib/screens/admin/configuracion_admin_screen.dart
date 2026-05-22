import 'dart:math';

import 'package:flutter/material.dart';

class ConfiguracionAdminScreen extends StatefulWidget {
  const ConfiguracionAdminScreen({super.key});

  @override
  State<ConfiguracionAdminScreen> createState() =>
      _ConfiguracionAdminScreenState();
}

class _ConfiguracionAdminScreenState extends State<ConfiguracionAdminScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;

  final TextEditingController _nombreAppController =
      TextEditingController(text: 'COLEMEX / Advocatus');
  final TextEditingController _soporteController =
      TextEditingController(text: 'soporte@colemex.com');
  final TextEditingController _telefonoController =
      TextEditingController(text: '55 0000 0000');
  final TextEditingController _versionController =
      TextEditingController(text: '1.0.0');

  bool _modoMantenimiento = false;
  bool _registroProfesionales = true;
  bool _registroClientes = true;
  bool _notificacionesPush = true;
  bool _pagosPlayStore = false;
  bool _verificacionObligatoria = false;

  final List<_ServicioConfigMock> _servicios = [
    _ServicioConfigMock(nombre: 'Abogados', activo: true),
    _ServicioConfigMock(nombre: 'Ajustadores', activo: true),
    _ServicioConfigMock(nombre: 'Peritos en criminalística', activo: true),
    _ServicioConfigMock(nombre: 'Valuadores', activo: true),
    _ServicioConfigMock(nombre: 'Investigadores', activo: true),
    _ServicioConfigMock(nombre: 'Psicólogos', activo: true),
    _ServicioConfigMock(nombre: 'Agentes inmobiliarios', activo: true),
    _ServicioConfigMock(nombre: 'Contadores', activo: true),
    _ServicioConfigMock(nombre: 'Agentes crediticios', activo: true),
    _ServicioConfigMock(nombre: 'Asistencia vial', activo: true),
  ];

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _nombreAppController.dispose();
    _soporteController.dispose();
    _telefonoController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  int get _serviciosActivos => _servicios.where((s) => s.activo).length;

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.90),
        foregroundColor: Colors.white,
        title: const Text(
          'Configuración',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Guardar',
            onPressed: _mostrarGuardarMock,
            icon: const Icon(Icons.save_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (_, __) {
                return CustomPaint(
                  painter: _MovingParticlesPainter(
                    progress: _backgroundController.value,
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.35,
                  colors: [
                    const Color(0xFF64748B).withOpacity(0.24),
                    const Color(0xFF020617).withOpacity(0.92),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isWide ? 24 : 16,
                16,
                isWide ? 24 : 16,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderConfiguracion(
                    serviciosActivos: _serviciosActivos,
                    mantenimiento: _modoMantenimiento,
                    pagos: _pagosPlayStore,
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle(
                    title: 'Ajustes generales',
                    subtitle:
                        'Configuración visual del sistema. Después se conectará a la API.',
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool twoColumns = constraints.maxWidth >= 1000;

                      if (twoColumns) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildGeneralPanel()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildSistemaPanel()),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _buildGeneralPanel(),
                          const SizedBox(height: 16),
                          _buildSistemaPanel(),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 26),
                  const _SectionTitle(
                    title: 'Servicios disponibles',
                    subtitle:
                        'Activa o desactiva módulos visibles en la plataforma.',
                  ),
                  const SizedBox(height: 14),
                  _ServiciosPanel(
                    servicios: _servicios,
                    onToggle: (index, value) {
                      setState(() {
                        _servicios[index].activo = value;
                      });
                    },
                  ),
                  const SizedBox(height: 26),
                  _ActionsPanel(
                    onSave: _mostrarGuardarMock,
                    onReset: _mostrarResetMock,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralPanel() {
    return _DarkPanel(
      title: 'Información de la app',
      icon: Icons.app_settings_alt_rounded,
      glowColor: const Color(0xFF94A3B8),
      child: Column(
        children: [
          _PremiumTextField(
            controller: _nombreAppController,
            label: 'Nombre de la aplicación',
            icon: Icons.gavel_rounded,
            color: const Color(0xFF38BDF8),
          ),
          const SizedBox(height: 14),
          _PremiumTextField(
            controller: _soporteController,
            label: 'Correo de soporte',
            icon: Icons.email_rounded,
            color: const Color(0xFF22C55E),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _PremiumTextField(
            controller: _telefonoController,
            label: 'Teléfono de soporte',
            icon: Icons.phone_rounded,
            color: const Color(0xFFFACC15),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _PremiumTextField(
            controller: _versionController,
            label: 'Versión de app',
            icon: Icons.info_rounded,
            color: const Color(0xFFA855F7),
          ),
        ],
      ),
    );
  }

  Widget _buildSistemaPanel() {
    return _DarkPanel(
      title: 'Reglas del sistema',
      icon: Icons.admin_panel_settings_rounded,
      glowColor: const Color(0xFF38BDF8),
      child: Column(
        children: [
          _ConfigSwitch(
            title: 'Modo mantenimiento',
            subtitle: 'Bloquea accesos temporalmente para usuarios.',
            icon: Icons.construction_rounded,
            color: const Color(0xFFEF4444),
            value: _modoMantenimiento,
            onChanged: (value) {
              setState(() => _modoMantenimiento = value);
            },
          ),
          _ConfigSwitch(
            title: 'Registro de profesionales',
            subtitle: 'Permite que nuevos profesionales se registren.',
            icon: Icons.badge_rounded,
            color: const Color(0xFF38BDF8),
            value: _registroProfesionales,
            onChanged: (value) {
              setState(() => _registroProfesionales = value);
            },
          ),
          _ConfigSwitch(
            title: 'Registro de clientes',
            subtitle: 'Permite que nuevos clientes creen cuenta.',
            icon: Icons.people_alt_rounded,
            color: const Color(0xFF22C55E),
            value: _registroClientes,
            onChanged: (value) {
              setState(() => _registroClientes = value);
            },
          ),
          _ConfigSwitch(
            title: 'Notificaciones push',
            subtitle: 'Preparado para Firebase Cloud Messaging.',
            icon: Icons.notifications_active_rounded,
            color: const Color(0xFFA855F7),
            value: _notificacionesPush,
            onChanged: (value) {
              setState(() => _notificacionesPush = value);
            },
          ),
          _ConfigSwitch(
            title: 'Pagos Play Store',
            subtitle: 'Por ahora apagado hasta probar Google Play Billing.',
            icon: Icons.payments_rounded,
            color: const Color(0xFFF97316),
            value: _pagosPlayStore,
            onChanged: (value) {
              setState(() => _pagosPlayStore = value);
            },
          ),
          _ConfigSwitch(
            title: 'Verificación obligatoria',
            subtitle:
                'Activar al final: pago → documentos → auditor → panel.',
            icon: Icons.verified_user_rounded,
            color: const Color(0xFFFACC15),
            value: _verificacionObligatoria,
            onChanged: (value) {
              setState(() => _verificacionObligatoria = value);
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  void _mostrarGuardarMock() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _PremiumBottomSheet(
          title: 'Guardar configuración',
          icon: Icons.save_rounded,
          glowColor: const Color(0xFF38BDF8),
          child: Text(
            'Por ahora esta configuración es visual. Después conectaremos estos valores a tu tabla configuraciones o a endpoints del admin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        );
      },
    );
  }

  void _mostrarResetMock() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _PremiumBottomSheet(
          title: 'Restablecer ajustes',
          icon: Icons.restart_alt_rounded,
          glowColor: const Color(0xFFFACC15),
          child: Text(
            'Después esta acción podrá restaurar la configuración base del sistema.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        );
      },
    );
  }
}

class _HeaderConfiguracion extends StatelessWidget {
  final int serviciosActivos;
  final bool mantenimiento;
  final bool pagos;

  const _HeaderConfiguracion({
    required this.serviciosActivos,
    required this.mantenimiento,
    required this.pagos,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 720;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 26 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.065),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withOpacity(0.16),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                const _HeaderIcon(),
                const SizedBox(width: 18),
                const Expanded(child: _HeaderText()),
                const SizedBox(width: 18),
                _HeaderCounters(
                  serviciosActivos: serviciosActivos,
                  mantenimiento: mantenimiento,
                  pagos: pagos,
                ),
              ],
            )
          : Column(
              children: [
                const _HeaderIcon(),
                const SizedBox(height: 16),
                const _HeaderText(),
                const SizedBox(height: 16),
                _HeaderCounters(
                  serviciosActivos: serviciosActivos,
                  mantenimiento: mantenimiento,
                  pagos: pagos,
                ),
              ],
            ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF94A3B8),
            Color(0xFF475569),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withOpacity(0.25),
            blurRadius: 28,
          ),
        ],
      ),
      child: const Icon(
        Icons.settings_rounded,
        color: Colors.white,
        size: 38,
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 720;

    return Column(
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        const Text(
          'Configuración del sistema',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Ajustes generales, servicios activos y reglas futuras del flujo profesional.',
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.62),
            fontSize: 13.5,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HeaderCounters extends StatelessWidget {
  final int serviciosActivos;
  final bool mantenimiento;
  final bool pagos;

  const _HeaderCounters({
    required this.serviciosActivos,
    required this.mantenimiento,
    required this.pagos,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _SmallCounter(
          label: 'Servicios',
          value: serviciosActivos.toString(),
          icon: Icons.apps_rounded,
          color: const Color(0xFF38BDF8),
        ),
        _SmallCounter(
          label: 'Sistema',
          value: mantenimiento ? 'Off' : 'On',
          icon: mantenimiento
              ? Icons.construction_rounded
              : Icons.check_circle_rounded,
          color: mantenimiento
              ? const Color(0xFFEF4444)
              : const Color(0xFF22C55E),
        ),
        _SmallCounter(
          label: 'Pagos',
          value: pagos ? 'On' : 'Off',
          icon: Icons.payments_rounded,
          color: pagos ? const Color(0xFF22C55E) : const Color(0xFFFACC15),
        ),
      ],
    );
  }
}

class _SmallCounter extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SmallCounter({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 122,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.075),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiciosPanel extends StatelessWidget {
  final List<_ServicioConfigMock> servicios;
  final void Function(int index, bool value) onToggle;

  const _ServiciosPanel({
    required this.servicios,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return _DarkPanel(
      title: 'Módulos de servicio',
      icon: Icons.apps_rounded,
      glowColor: const Color(0xFF22C55E),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: servicios.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width >= 900 ? 2 : 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio:
              MediaQuery.of(context).size.width >= 900 ? 4.0 : 3.1,
        ),
        itemBuilder: (_, index) {
          final servicio = servicios[index];

          return _ServicioTile(
            nombre: servicio.nombre,
            activo: servicio.activo,
            onChanged: (value) => onToggle(index, value),
          );
        },
      ),
    );
  }
}

class _ServicioTile extends StatelessWidget {
  final String nombre;
  final bool activo;
  final ValueChanged<bool> onChanged;

  const _ServicioTile({
    required this.nombre,
    required this.activo,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = activo ? const Color(0xFF22C55E) : const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Icon(
              _iconForServicio(nombre),
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  activo ? 'Activo en la plataforma' : 'Oculto temporalmente',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: activo,
            activeColor: const Color(0xFF22C55E),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  IconData _iconForServicio(String nombre) {
    final n = nombre.toLowerCase();

    if (n.contains('abogado')) return Icons.gavel_rounded;
    if (n.contains('ajustador')) return Icons.car_crash_rounded;
    if (n.contains('perito')) return Icons.biotech_rounded;
    if (n.contains('valuador')) return Icons.home_work_rounded;
    if (n.contains('investigador')) return Icons.travel_explore_rounded;
    if (n.contains('psic')) return Icons.psychology_rounded;
    if (n.contains('inmobiliario')) return Icons.apartment_rounded;
    if (n.contains('contador')) return Icons.calculate_rounded;
    if (n.contains('crediticio')) return Icons.credit_score_rounded;
    if (n.contains('vial')) return Icons.local_shipping_rounded;

    return Icons.apps_rounded;
  }
}

class _ConfigSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ConfigSwitch({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _MiniIcon(icon: icon, color: color),
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
                      fontSize: 14.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              activeColor: color,
              onChanged: onChanged,
            ),
          ],
        ),
        if (!isLast)
          Divider(
            height: 22,
            color: Colors.white.withOpacity(0.09),
          ),
      ],
    );
  }
}

class _ActionsPanel extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onReset;

  const _ActionsPanel({
    required this.onSave,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.end,
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.18)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text(
              'Restablecer',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onSave,
            icon: const Icon(Icons.save_rounded),
            label: const Text(
              'Guardar configuración',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color color;
  final TextInputType? keyboardType;

  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.color,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      cursorColor: color,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.55),
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(icon, color: color),
        filled: true,
        fillColor: Colors.black.withOpacity(0.26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: color, width: 1.4),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF94A3B8),
                Color(0xFF475569),
              ],
            ),
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF94A3B8).withOpacity(0.25),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.58),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DarkPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color glowColor;
  final Widget child;

  const _DarkPanel({
    required this.title,
    required this.icon,
    required this.glowColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.065),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.13),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _GlowIcon(icon: icon, glowColor: glowColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _MiniIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.11),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

class _GlowIcon extends StatelessWidget {
  final IconData icon;
  final Color glowColor;

  const _GlowIcon({
    required this.icon,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: glowColor.withOpacity(0.12),
        border: Border.all(color: glowColor.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(color: glowColor.withOpacity(0.22), blurRadius: 22),
        ],
      ),
      child: Icon(icon, color: glowColor, size: 27),
    );
  }
}

class _PremiumBottomSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color glowColor;
  final Widget child;

  const _PremiumBottomSheet({
    required this.title,
    required this.icon,
    required this.glowColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 20),
            _GlowIcon(icon: icon, glowColor: glowColor),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            child,
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: glowColor,
                  foregroundColor: glowColor == const Color(0xFFFACC15)
                      ? Colors.black
                      : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_rounded),
                label: const Text(
                  'Entendido',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovingParticlesPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _MovingParticlesPainter({required this.progress})
      : particles = List.generate(80, (index) {
          final random = Random(index * 891);
          return _Particle(
            x: random.nextDouble(),
            y: random.nextDouble(),
            radius: 0.8 + random.nextDouble() * 2.1,
            speed: 0.015 + random.nextDouble() * 0.045,
            opacity: 0.22 + random.nextDouble() * 0.58,
          );
        });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      final animatedY = (particle.y + progress * particle.speed) % 1.0;
      final wave = sin((progress * 2 * pi) + particle.y * 10) * 14;

      final position = Offset(
        particle.x * size.width + wave,
        animatedY * size.height,
      );

      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(position, particle.radius, paint);
    }

    final linePaint = Paint()
      ..strokeWidth = 0.4
      ..color = Colors.white.withOpacity(0.055);

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];

        final o1 = Offset(
          p1.x * size.width,
          ((p1.y + progress * p1.speed) % 1.0) * size.height,
        );

        final o2 = Offset(
          p2.x * size.width,
          ((p2.y + progress * p2.speed) % 1.0) * size.height,
        );

        if ((o1 - o2).distance < 100) {
          canvas.drawLine(o1, o2, linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MovingParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _Particle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double opacity;

  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}

class _ServicioConfigMock {
  final String nombre;
  bool activo;

  _ServicioConfigMock({
    required this.nombre,
    required this.activo,
  });
}