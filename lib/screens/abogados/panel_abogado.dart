import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:advocatus/screens/abogados/abogado_modulos/casos_activos_screen.dart';
import 'package:advocatus/screens/abogados/abogado_modulos/clientes_abogado_screen.dart';
import 'package:advocatus/screens/abogados/abogado_modulos/generador_documentos_screen.dart';
import 'package:advocatus/screens/abogados/abogado_modulos/bitacora_legal_screen.dart';

// comunes
import 'package:advocatus/screens/common/agenda/agenda_screen.dart';
import 'package:advocatus/screens/common/ubicacion/ubicacion_tiempo_real_screen.dart';
import 'package:advocatus/screens/common/historial/historial_screen.dart';
import 'package:advocatus/screens/common/ingresos/ingresos_screen.dart';
import 'package:advocatus/screens/common/calificaciones/calificaciones_screen.dart';
import 'package:advocatus/screens/common/notificaciones/notificaciones_screen.dart';
import 'package:advocatus/screens/common/configuracion/configuracion_screen.dart';
import 'package:advocatus/screens/common/soporte/soporte_screen.dart';
import 'package:advocatus/screens/common/perfil/perfil_verificado_screen.dart';

class PanelAbogadoScreen extends StatefulWidget {
  final int? abogadoId;

  const PanelAbogadoScreen({
    super.key,
    this.abogadoId,
  });

  @override
  State<PanelAbogadoScreen> createState() => _PanelAbogadoScreenState();
}

class _PanelAbogadoScreenState extends State<PanelAbogadoScreen> {
  String estado = 'Disponible';
  String nombreLic = 'Licenciado';

  @override
  void initState() {
    super.initState();
    _cargarNombre();
  }

  Future<void> _cargarNombre() async {
    final prefs = await SharedPreferences.getInstance();
    final nombreGuardado = (prefs.getString('nombre') ?? '').trim();

    if (!mounted) return;

    setState(() {
      nombreLic = nombreGuardado.isNotEmpty ? nombreGuardado : 'Licenciado';
    });
  }

  String _saludoPorHora() {
    final hora = DateTime.now().hour;

    if (hora >= 5 && hora < 12) {
      return 'Buenos días';
    } else if (hora >= 12 && hora < 19) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  String _nombreConTitulo(String nombre) {
    final n = nombre.trim();

    if (n.isEmpty) return 'Licenciado';

    final lower = n.toLowerCase();
    if (lower.startsWith('lic. ') ||
        lower.startsWith('lic ') ||
        lower.startsWith('licenciado ')) {
      return n;
    }

    return 'Lic. $n';
  }

  void _go(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
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
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              letterSpacing: .2,
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
    final theme = Theme.of(context);
    final gold = theme.primaryColor;

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
    final theme = Theme.of(context);
    final gold = theme.primaryColor;

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
    final theme = Theme.of(context);
    final gold = theme.primaryColor;

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
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _estadoChip(String label) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
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

    final saludo = _saludoPorHora();
    final nombreMostrado = _nombreConTitulo(nombreLic);

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
        title: const Text('Panel • Abogado'),
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
            child: Container(color: Colors.black.withOpacity(.62)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Theme(
                    data: theme.copyWith(
                      textTheme: theme.textTheme.apply(
                        bodyColor: Colors.white,
                        displayColor: Colors.white,
                      ),
                      iconTheme: theme.iconTheme.copyWith(color: Colors.white),
                    ),
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
                                    Icons.gavel_outlined,
                                    color: gold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$saludo, $nombreMostrado',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Casos • Clientes • Documentos legales',
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
                                      Icon(
                                        Icons.circle,
                                        size: 10,
                                        color: gold,
                                      ),
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
                                'Define tu disponibilidad para recibir nuevos asuntos o consultas.',
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
                                icon: Icons.folder_open_outlined,
                                label: 'Casos',
                                onTap: () => _go(const CasosActivosScreen()),
                              ),
                              const SizedBox(width: 10),
                              _quickAction(
                                icon: Icons.people_alt_outlined,
                                label: 'Clientes',
                                onTap: () =>
                                    _go(const ClientesAbogadoScreen()),
                              ),
                              const SizedBox(width: 10),
                              _quickAction(
                                icon: Icons.description_outlined,
                                label: 'Documentos',
                                onTap: () =>
                                    _go(const GeneradorDocumentosScreen()),
                              ),
                              const SizedBox(width: 10),
                              _quickAction(
                                icon: Icons.event_available_outlined,
                                label: 'Agenda',
                                onTap: () => _go(const AgendaScreen()),
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
                            subtitle:
                                'Completa datos, documentos y validación.',
                            onTap: () => _go(const PerfilVerificadoScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.location_on_outlined,
                            title: 'Ubicación en tiempo real',
                            subtitle:
                                'Comparte ubicación cuando estés activo.',
                            onTap: () =>
                                _go(const UbicacionTiempoRealScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.event_available_outlined,
                            title: 'Agenda / citas',
                            subtitle:
                                'Organiza consultas, reuniones y pendientes.',
                            onTap: () => _go(const AgendaScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.history,
                            title: 'Historial de servicios',
                            subtitle:
                                'Consulta tus atenciones y movimientos previos.',
                            onTap: () => _go(const HistorialScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.attach_money,
                            title: 'Ingresos / comisiones',
                            subtitle:
                                'Revisa cobros, pagos y resumen de ingresos.',
                            onTap: () => _go(const IngresosScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.star_outline,
                            title: 'Calificaciones',
                            subtitle:
                                'Promedio y comentarios de tus clientes.',
                            onTap: () => _go(const CalificacionesScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.notifications_none,
                            title: 'Notificaciones',
                            subtitle:
                                'Alertas importantes y novedades del sistema.',
                            onTap: () => _go(const NotificacionesScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.settings_outlined,
                            title: 'Configuración',
                            subtitle:
                                'Cuenta, seguridad y preferencias.',
                            onTap: () => _go(const ConfiguracionScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.support_agent_outlined,
                            title: 'Soporte técnico',
                            subtitle:
                                'Ayuda y contacto con soporte.',
                            onTap: () => _go(const SoporteScreen()),
                          ),
                          _sectionHeader(
                            'Módulos del abogado',
                            subtitle:
                                'Herramientas sencillas y útiles para tu práctica diaria.',
                          ),
                          _tile(
                            icon: Icons.folder_open_outlined,
                            title: 'Casos activos',
                            subtitle:
                                'Consulta asuntos en proceso y seguimiento básico.',
                            onTap: () => _go(const CasosActivosScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.people_alt_outlined,
                            title: 'Clientes',
                            subtitle:
                                'Lista de clientes con datos y asunto principal.',
                            onTap: () => _go(const ClientesAbogadoScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.description_outlined,
                            title: 'Generador de documentos',
                            subtitle:
                                'Crea formatos simples con datos preestablecidos.',
                            onTap: () =>
                                _go(const GeneradorDocumentosScreen()),
                          ),
                          const SizedBox(height: 10),
                          _tile(
                            icon: Icons.edit_note_outlined,
                            title: 'Bitácora legal',
                            subtitle:
                                'Guarda notas rápidas y seguimiento por asunto.',
                            onTap: () => _go(const BitacoraLegalScreen()),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tip: Mantén tu agenda y tus casos actualizados para dar una mejor experiencia a tus clientes.',
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
          ),
        ],
      ),
    );
  }
}