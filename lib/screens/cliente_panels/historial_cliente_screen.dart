import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services/cliente_profesionales_api.dart';

class HistorialClienteScreen extends StatefulWidget {
  const HistorialClienteScreen({super.key});

  @override
  State<HistorialClienteScreen> createState() =>
      _HistorialClienteScreenState();
}

class _HistorialClienteScreenState extends State<HistorialClienteScreen> {
  static const Color _bg = Color(0xFF050B14);
  static const Color _card = Color(0xFF111B28);
  static const Color _card2 = Color(0xFF0D1724);
  static const Color _gold = Color(0xFFD6A84F);
  static const Color _green = Color(0xFF54C26B);
  static const Color _red = Color(0xFFEF4444);
  static const Color _muted = Color(0xFF9CA8BA);

  final ClienteProfesionalesApi _api = ClienteProfesionalesApi();

  bool _cargando = true;
  String _mensaje = '';
  String _filtro = '';
  List<Map<String, dynamic>> _casos = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _cargando = true;
      _mensaje = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final clienteId = prefs.getInt('id') ?? 0;

      if (clienteId <= 0) {
        if (!mounted) return;
        setState(() {
          _cargando = false;
          _mensaje = 'No se pudo identificar al cliente.';
        });
        return;
      }

      final historial = await _api.getHistorialCasosCliente(
        clienteId: clienteId,
        limit: 100,
      );

      if (!mounted) return;

      setState(() {
        _casos = historial;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _mensaje = 'No se pudo cargar el historial.';
      });
    }
  }

  List<Map<String, dynamic>> get _casosFiltrados {
    final q = _filtro.toLowerCase().trim();
    if (q.isEmpty) return _casos;

    return _casos.where((caso) {
      return _titulo(caso).toLowerCase().contains(q) ||
          _servicio(caso).toLowerCase().contains(q) ||
          '${caso['id'] ?? ''}'.contains(q);
    }).toList();
  }

  String _texto(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _titulo(Map<String, dynamic> caso) {
    final titulo = _texto(caso['titulo']);
    if (titulo.isNotEmpty) return titulo;
    final servicio = _texto(caso['servicio']);
    if (servicio.isNotEmpty) return 'Solicitud de $servicio';
    return 'Caso #${caso['id'] ?? ''}';
  }

  String _servicio(Map<String, dynamic> caso) {
    return _texto(caso['servicio'], 'Servicio no especificado');
  }

  String _estado(Map<String, dynamic> caso) {
    return _texto(caso['estado'], 'sin estado');
  }

  String _fecha(Map<String, dynamic> caso) {
    final raw = _texto(
      caso['fecha_finalizacion'] ??
          caso['fecha_creacion'] ??
          caso['created_at'] ??
          caso['fecha'],
    );

    if (raw.isEmpty) return 'Fecha no disponible';

    final value = raw.replaceFirst('T', ' ');
    if (value.length >= 16) return value.substring(0, 16);
    if (value.length >= 10) return value.substring(0, 10);
    return value;
  }

  String _descripcion(Map<String, dynamic> caso) {
    return _texto(caso['descripcion'], 'Sin descripción registrada.');
  }

  String _profesional(Map<String, dynamic> caso) {
    final nombre = _texto(
      caso['profesional_nombre'] ??
          caso['nombre_profesional'] ??
          caso['profesional']?['nombre'],
    );

    return nombre.isEmpty ? 'No asignado' : nombre;
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'finalizado':
      case 'finalizada':
      case 'completado':
      case 'completada':
        return _green;
      case 'cancelado':
      case 'cancelada':
        return _red;
      default:
        return _gold;
    }
  }

  String _labelEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'finalizado':
      case 'finalizada':
      case 'completado':
      case 'completada':
        return 'Finalizado';
      case 'cancelado':
      case 'cancelada':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  IconData _iconoServicio(String servicio) {
    final s = servicio.toLowerCase();
    if (s.contains('abogado')) return Icons.balance_rounded;
    if (s.contains('ajustador')) return Icons.directions_car_filled_rounded;
    if (s.contains('perito')) return Icons.manage_search_rounded;
    if (s.contains('valuador')) return Icons.real_estate_agent_rounded;
    if (s.contains('investigador')) return Icons.travel_explore_rounded;
    if (s.contains('psicologo') || s.contains('psicólogo')) {
      return Icons.psychology_alt_rounded;
    }
    if (s.contains('inmobiliario')) return Icons.home_work_rounded;
    if (s.contains('contador')) return Icons.calculate_rounded;
    if (s.contains('crediticio')) return Icons.account_balance_wallet_rounded;
    if (s.contains('vial')) return Icons.car_repair_rounded;
    return Icons.folder_open_rounded;
  }

  void _verDetalle(Map<String, dynamic> caso) {
    final estado = _estado(caso);
    final color = _colorEstado(estado);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 28,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _gold.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(
                          _iconoServicio(_servicio(caso)),
                          color: _gold,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _titulo(caso),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.08,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _estadoBadge(estado, color),
                  const SizedBox(height: 20),
                  _detalleLinea(Icons.miscellaneous_services_rounded,
                      'Servicio', _servicio(caso)),
                  _detalleLinea(
                      Icons.calendar_month_rounded, 'Fecha', _fecha(caso)),
                  _detalleLinea(Icons.folder_open_rounded, 'Expediente',
                      '#${caso['id'] ?? ''}'),
                  _detalleLinea(Icons.person_outline_rounded, 'Profesional',
                      _profesional(caso)),
                  const SizedBox(height: 14),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _descripcion(caso),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _estadoBadge(String estado, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        _labelEstado(estado),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _detalleLinea(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _gold, size: 22),
          const SizedBox(width: 11),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Historial',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _HeaderButton(
                icon: Icons.refresh_rounded,
                gold: true,
                onTap: _cargarHistorial,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Aquí puedes ver todos los servicios que ya han sido finalizados o cancelados.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumenCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 22, 18, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172437), Color(0xFF0D1623)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.17),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: _gold,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Total de casos en historial',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_casos.length}',
                style: const TextStyle(
                  color: _gold,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                _casos.length == 1 ? 'Caso' : 'Casos',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.58),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buscador() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _filtro = v),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'Buscar por servicio o expediente...',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.65),
              size: 30,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 17),
          ),
        ),
      ),
    );
  }

  Widget _historialCard(Map<String, dynamic> caso) {
    final estado = _estado(caso);
    final color = _colorEstado(estado);
    final servicio = _servicio(caso);

    return Container(
      decoration: BoxDecoration(
        color: _card2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.23),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => _verDetalle(caso),
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 5,
                  decoration: const BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.09),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _gold.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Icon(
                            _iconoServicio(servicio),
                            color: _gold,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _titulo(caso),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                servicio,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.58),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _estadoBadge(estado, color),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniInfo(
                            icon: Icons.calendar_month_rounded,
                            label: 'Fecha',
                            value: _fecha(caso),
                          ),
                        ),
                        Expanded(
                          child: _MiniInfo(
                            icon: Icons.folder_open_rounded,
                            label: 'Expediente',
                            value: '#${caso['id'] ?? ''}',
                          ),
                        ),
                        Expanded(
                          child: _MiniInfo(
                            icon: Icons.person_outline_rounded,
                            label: 'Profesional',
                            value: _profesional(caso),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withValues(alpha: 0.07)),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: Colors.white.withValues(alpha: 0.60),
                          size: 21,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _descripcion(caso),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.58),
                              fontSize: 14,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Ver detalle',
                          style: TextStyle(
                            color: _gold,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: _gold,
                          size: 22,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, color: _gold, size: 70),
            const SizedBox(height: 14),
            const Text(
              'Sin historial',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _mensaje.isNotEmpty
                  ? _mensaje
                  : 'Cuando finalices o canceles servicios, aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: _gold),
      );
    }

    if (_casos.isEmpty) {
      return ListView(
        children: [
          _header(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.60,
            child: _emptyState(),
          ),
        ],
      );
    }

    final visibles = _casosFiltrados;

    return RefreshIndicator(
      color: _gold,
      backgroundColor: _card,
      onRefresh: _cargarHistorial,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 28),
        itemCount: visibles.length + 3,
        separatorBuilder: (_, index) {
          if (index < 2) return const SizedBox(height: 0);
          return const SizedBox(height: 14);
        },
        itemBuilder: (_, index) {
          if (index == 0) return _header();
          if (index == 1) return _resumenCard();
          if (index == 2) return _buscador();

          final caso = visibles[index - 3];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _historialCard(caso),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            right: -80,
            height: 270,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.9,
                  colors: [
                    const Color(0xFF233653).withValues(alpha: 0.86),
                    const Color(0xFF0B1420).withValues(alpha: 0.74),
                    _bg.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(child: _body()),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool gold;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    this.gold = false,
  });

  static const Color _gold = Color(0xFFD6A84F);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF111B28),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Icon(
            icon,
            color: gold ? _gold : Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.58),
          size: 21,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}