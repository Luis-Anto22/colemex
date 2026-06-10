import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:advocatus/screens/common/notificaciones/notificaciones_screen.dart';

import 'casos_archivados_screen.dart';
import '../../services/api_services/cliente_profesionales_api.dart';
import '../../services/api_services/api_client.dart';

class PanelInicio extends StatefulWidget {
  final String nombreUsuario;
  final String? servicioSeleccionado;
  final List<String> serviciosDisponibles;
  final String especialidadBusqueda;
  final VoidCallback onAbrirServicios;
  final ValueChanged<String> onSeleccionarServicio;
  final ValueChanged<String> onBuscarEspecialidad;

  const PanelInicio({
    super.key,
    required this.nombreUsuario,
    required this.servicioSeleccionado,
    required this.serviciosDisponibles,
    required this.especialidadBusqueda,
    required this.onAbrirServicios,
    required this.onSeleccionarServicio,
    required this.onBuscarEspecialidad,
  });

  @override
  State<PanelInicio> createState() => _PanelInicioState();
}

class _PanelInicioState extends State<PanelInicio> {
  static const Color _bg = Color(0xFF050B14);
  static const Color _card = Color(0xFF111B28);
  static const Color _gold = Color(0xFFD6A84F);
  static const Color _red = Color(0xFFB8322D);

  final ClienteProfesionalesApi _api = ClienteProfesionalesApi();
  final ApiClient _apiClient = ApiClient();

  final Set<int> _casosSeleccionados = {};
  bool _modoSeleccionCasos = false;

  late final TextEditingController _busquedaController;

  bool _cargandoEspecialidades = false;
  List<String> _especialidades = [];
  List<Map<String, String>> _sugerenciasBusqueda = [];

  int _notificacionesNoLeidas = 0;
  bool _cargandoNotificaciones = false;

  bool _cargandoCasos = true;
  String _errorCasos = '';
  List<Map<String, dynamic>> _casos = [];

  int _totalActivos = 0;
  int _totalArchivados = 0;

  @override
  void initState() {
    super.initState();
    _busquedaController =
        TextEditingController(text: widget.especialidadBusqueda);
    _busquedaController.addListener(_onBusquedaChanged);
    _cargarEspecialidades();
    _cargarMisCasos();
    _cargarConteoNotificaciones();
  }

  @override
  void didUpdateWidget(covariant PanelInicio oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.especialidadBusqueda != oldWidget.especialidadBusqueda &&
        _busquedaController.text != widget.especialidadBusqueda) {
      _busquedaController.text = widget.especialidadBusqueda;
    }
  }

  @override
  void dispose() {
    _busquedaController.removeListener(_onBusquedaChanged);
    _busquedaController.dispose();
    super.dispose();
  }

  Future<int> _obtenerClienteId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id') ?? 0;
  }
  Future<void> _cargarConteoNotificaciones() async {
  if (_cargandoNotificaciones) return;

  final clienteId = await _obtenerClienteId();

  if (clienteId <= 0) return;

  setState(() {
    _cargandoNotificaciones = true;
  });

  try {
    final res = await _apiClient.get(
      '/notificaciones/count',
      params: {
        'cliente_id': clienteId,
      },
    );

    if (!mounted) return;

    final data = res['data'];

    int total = 0;

    if (data is Map) {
      total = int.tryParse(
            '${data['unread_count'] ?? data['no_leidas'] ?? data['unread'] ?? data['total'] ?? 0}',
          ) ??
          0;
    } else {
      total = int.tryParse(
            '${res['unread_count'] ?? res['no_leidas'] ?? res['total'] ?? 0}',
          ) ??
          0;
    }

    setState(() {
      _notificacionesNoLeidas = total;
      _cargandoNotificaciones = false;
    });
  } catch (_) {
    if (!mounted) return;

    setState(() {
      _cargandoNotificaciones = false;
    });
  }
}

  Future<void> _cargarMisCasos() async {
    if (!mounted) return;

    setState(() {
      _cargandoCasos = true;
      _errorCasos = '';
    });

    try {
      final clienteId = await _obtenerClienteId();

      if (clienteId <= 0) {
        if (!mounted) return;

        setState(() {
          _cargandoCasos = false;
          _errorCasos = 'No se pudo identificar al cliente.';
          _casos = [];
          _totalActivos = 0;
        });
        return;
      }

      final casos = await _api.getMisCasos(
        clienteId: clienteId,
        limit: 50,
      );

      if (!mounted) return;

      setState(() {
        _casos = casos;
        _totalActivos = casos.length;
        _cargandoCasos = false;
        _casosSeleccionados.clear();
        _modoSeleccionCasos = false;
      });

      await _cargarConteoCasos();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _cargandoCasos = false;
        _errorCasos = 'No se pudo cargar el historial de casos.';
      });
    }
  }

  Future<void> _cargarConteoCasos() async {
    try {
      final clienteId = await _obtenerClienteId();

      if (clienteId <= 0) return;

      final conteo = await _api.getConteoCasos(clienteId: clienteId);

      if (!mounted) return;

      setState(() {
        _totalActivos = conteo['activos'] ?? _totalActivos;
        _totalArchivados = conteo['archivados'] ?? 0;
      });
    } catch (_) {
      // No rompemos la pantalla si falla solo el conteo.
    }
  }

  Future<void> _cargarEspecialidades() async {
    if (mounted) {
      setState(() {
        _cargandoEspecialidades = true;
      });
    }

    try {
      final items = await _api.getEspecialidades(limit: 150);

      if (!mounted) return;

      setState(() {
        _especialidades = items.toSet().toList()..sort();
        _cargandoEspecialidades = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _cargandoEspecialidades = false;
      });
    }
  }

  void _onBusquedaChanged() {
    final q = _busquedaController.text.trim().toLowerCase();

    if (q.isEmpty) {
      if (mounted && _sugerenciasBusqueda.isNotEmpty) {
        setState(() {
          _sugerenciasBusqueda = [];
        });
      }
      return;
    }

    final sugerencias = <Map<String, String>>[];
    final seen = <String>{};

    void addSugerencia({
      required String tipo,
      required String valor,
      required String icono,
    }) {
      final key = '${tipo.toLowerCase()}::${valor.toLowerCase()}';

      if (!seen.add(key)) return;

      sugerencias.add({
        'tipo': tipo,
        'valor': valor,
        'icono': icono,
      });
    }

    final serviciosMatch = widget.serviciosDisponibles
        .where((s) => s.toLowerCase().contains(q))
        .take(5);

    for (final servicio in serviciosMatch) {
      addSugerencia(
        tipo: 'servicio',
        valor: servicio,
        icono: 'miscellaneous_services_rounded',
      );
    }

    final especialidadesMatch =
        _especialidades.where((e) => e.toLowerCase().contains(q)).take(7);

    for (final especialidad in especialidadesMatch) {
      addSugerencia(
        tipo: 'especialidad',
        valor: especialidad,
        icono: 'balance_rounded',
      );
    }

    if (!mounted) return;

    setState(() {
      _sugerenciasBusqueda = sugerencias.take(8).toList();
    });
  }

  String? _servicioExacto(String q) {
    final objetivo = q.trim().toLowerCase();

    if (objetivo.isEmpty) return null;

    for (final servicio in widget.serviciosDisponibles) {
      if (servicio.trim().toLowerCase() == objetivo) {
        return servicio;
      }
    }

    return null;
  }

  void _buscar() {
    final valor = _busquedaController.text.trim();

    if (valor.isEmpty) {
      widget.onBuscarEspecialidad('');
      return;
    }

    final servicio = _servicioExacto(valor);

    if (servicio != null) {
      widget.onSeleccionarServicio(servicio);
      widget.onBuscarEspecialidad('');
      widget.onAbrirServicios();
      return;
    }

    widget.onBuscarEspecialidad(valor);
    widget.onAbrirServicios();
  }

  void _seleccionarSugerencia(Map<String, String> sugerencia) {
    final valor = sugerencia['valor']?.trim() ?? '';
    final tipo = sugerencia['tipo']?.toLowerCase().trim() ?? '';

    if (valor.isEmpty) return;

    _busquedaController.text = valor;
    _busquedaController.selection = TextSelection.fromPosition(
      TextPosition(offset: _busquedaController.text.length),
    );

    setState(() {
      _sugerenciasBusqueda = [];
    });

    if (tipo == 'servicio') {
      widget.onSeleccionarServicio(valor);
      widget.onBuscarEspecialidad('');
      widget.onAbrirServicios();
      return;
    }

    widget.onBuscarEspecialidad(valor);
    widget.onAbrirServicios();
  }

  IconData _iconoSugerencia(String icono) {
    switch (icono) {
      case 'balance_rounded':
        return Icons.balance_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  String _normalizarServicio(String servicio) {
    return servicio
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
  }

  IconData _iconoServicio(String servicio) {
    switch (_normalizarServicio(servicio)) {
      case 'abogados':
      case 'abogado':
        return Icons.balance_rounded;
      case 'ajustadores':
      case 'ajustador':
        return Icons.directions_car_filled_rounded;
      case 'peritos en criminalistica':
      case 'perito en criminalistica':
        return Icons.manage_search_rounded;
      case 'valuadores':
      case 'valuador':
        return Icons.real_estate_agent_rounded;
      case 'investigadores':
      case 'investigador':
        return Icons.travel_explore_rounded;
      case 'psicologos':
      case 'psicologo':
        return Icons.psychology_alt_rounded;
      case 'agentes inmobiliarios':
      case 'agente inmobiliario':
        return Icons.home_work_rounded;
      case 'contadores':
      case 'contador':
        return Icons.calculate_rounded;
      case 'agentes crediticios':
      case 'agente crediticio':
        return Icons.account_balance_wallet_rounded;
      case 'asistencia vial':
      case 'asistencia_vial':
        return Icons.car_repair_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  Color _colorServicio(String servicio) {
    switch (_normalizarServicio(servicio)) {
      case 'abogados':
      case 'abogado':
        return const Color(0xFFD6A84F);
      case 'ajustadores':
      case 'ajustador':
        return const Color(0xFF54C26B);
      case 'peritos en criminalistica':
      case 'perito en criminalistica':
        return const Color(0xFF5D93FF);
      case 'valuadores':
      case 'valuador':
        return const Color(0xFF49C591);
      case 'investigadores':
      case 'investigador':
        return const Color(0xFF5D93FF);
      case 'psicologos':
      case 'psicologo':
        return const Color(0xFF9B5CFF);
      case 'agentes inmobiliarios':
      case 'agente inmobiliario':
        return const Color(0xFF49C591);
      case 'contadores':
      case 'contador':
        return const Color(0xFF9B5CFF);
      case 'agentes crediticios':
      case 'agente crediticio':
        return const Color(0xFF59C37A);
      case 'asistencia vial':
      case 'asistencia_vial':
        return const Color(0xFFE59A36);
      default:
        return _gold;
    }
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return const Color(0xFFE59A36);
      case 'en proceso':
        return const Color(0xFFD6A84F);
      case 'finalizado':
        return const Color(0xFF54C26B);
      default:
        return const Color(0xFF97A3B6);
    }
  }

  String _fechaCorta(String fechaRaw) {
    if (fechaRaw.isEmpty) return '';

    final value = fechaRaw.replaceFirst('T', ' ');

    if (value.length >= 16) return value.substring(0, 16);
    if (value.length >= 10) return value.substring(0, 10);

    return value;
  }

  Future<void> _archivarCaso(int index) async {
    if (index < 0 || index >= _casos.length) return;

    final caso = _casos[index];
    final casoId = int.tryParse('${caso['id']}');
    final clienteId = await _obtenerClienteId();

    if (casoId == null || clienteId <= 0) return;

    final res = await _apiClient.archivarCasoCliente(
      casoId: casoId,
      clienteId: clienteId,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caso archivado')),
      );

      await _cargarMisCasos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'No se pudo archivar')),
      );
    }
  }

  Future<void> _eliminarCaso(int index) async {
    if (index < 0 || index >= _casos.length) return;

    final caso = _casos[index];
    final casoId = int.tryParse('${caso['id']}');
    final clienteId = await _obtenerClienteId();

    if (casoId == null || clienteId <= 0) return;

    final res = await _apiClient.eliminarCasoCliente(
      casoId: casoId,
      clienteId: clienteId,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caso eliminado')),
      );

      await _cargarMisCasos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'No se pudo eliminar')),
      );
    }
  }

  Future<void> _archivarSeleccionados() async {
    final clienteId = await _obtenerClienteId();

    if (clienteId <= 0 || _casosSeleccionados.isEmpty) return;

    final indices = _casosSeleccionados.toList()
      ..sort((a, b) => b.compareTo(a));

    for (final index in indices) {
      if (index < 0 || index >= _casos.length) continue;

      final casoId = int.tryParse('${_casos[index]['id']}');

      if (casoId == null) continue;

      await _apiClient.archivarCasoCliente(
        casoId: casoId,
        clienteId: clienteId,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Casos archivados')),
    );

    await _cargarMisCasos();
  }

  Future<void> _eliminarSeleccionados() async {
    final clienteId = await _obtenerClienteId();

    if (clienteId <= 0 || _casosSeleccionados.isEmpty) return;

    final indices = _casosSeleccionados.toList()
      ..sort((a, b) => b.compareTo(a));

    for (final index in indices) {
      if (index < 0 || index >= _casos.length) continue;

      final casoId = int.tryParse('${_casos[index]['id']}');

      if (casoId == null) continue;

      await _apiClient.eliminarCasoCliente(
        casoId: casoId,
        clienteId: clienteId,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Casos eliminados')),
    );

    await _cargarMisCasos();
  }

  void _toggleSeleccionCaso(int index) {
    setState(() {
      if (_casosSeleccionados.contains(index)) {
        _casosSeleccionados.remove(index);
      } else {
        _casosSeleccionados.add(index);
      }

      if (_casosSeleccionados.isEmpty) {
        _modoSeleccionCasos = false;
      }
    });
  }

  String _saludo() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días,';
    if (hour < 19) return 'Buenas tardes,';
    return 'Buenas noches,';
  }

  String _primerNombre() {
    final nombre = widget.nombreUsuario.trim();
    if (nombre.isEmpty) return 'Cliente';
    return nombre.split(' ').first;
  }

  void _irAServicio(String servicio) {
    widget.onSeleccionarServicio(servicio);
    widget.onBuscarEspecialidad('');
    widget.onAbrirServicios();
  }

  Widget _buildTopHeader(bool compact) {
    return Padding(
      padding: EdgeInsets.fromLTRB(6, compact ? 2 : 8, 6, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _saludo(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: compact ? 18 : 21,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${_primerNombre()}!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 24 : 29,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: _gold,
                      size: 19,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Chalco, Estado de México',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.74),
                          fontSize: compact ? 13 : 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withValues(alpha: 0.72),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () async {
                  final clienteId = await _obtenerClienteId();

                  if (!mounted) return;

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificacionesScreen(
                        clienteId: clienteId > 0 ? clienteId : null,
                      ),
                    ),
                  );

                  if (!mounted) return;
                  _cargarConteoNotificaciones();
                },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              if (_notificacionesNoLeidas > 0)
              Positioned(
                right: 8,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _notificacionesNoLeidas > 99
                        ? '99+'
                        : '$_notificacionesNoLeidas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: compact ? 43 : 48,
            height: compact ? 43 : 48,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _gold.withValues(alpha: 0.7)),
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/iconos/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(bool compact) {
    return Container(
      height: compact ? 250 : 270,
      margin: const EdgeInsets.only(top: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF121C29), Color(0xFF060B12)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.34,
              child: Image.asset(
                'assets/iconos/mazo-libro.png',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF0B111B),
                    const Color(0xFF0B111B).withValues(alpha: 0.82),
                    const Color(0xFF0B111B).withValues(alpha: 0.28),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 26,
            top: 36,
            child: InkWell(
              onTap: () => _irAServicio('Asistencia vial'),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: compact ? 100 : 116,
                height: compact ? 144 : 158,
                decoration: BoxDecoration(
                  color: _red,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _red.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emergency_share_rounded,
                      color: Colors.white,
                      size: 37,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        letterSpacing: 5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Emergencia\ninmediata',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 13,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: compact ? 22 : 28,
            top: compact ? 26 : 32,
            right: compact ? 138 : 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Qué servicio\nnecesitas hoy?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 25 : 30,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Profesionales verificados listos\npara ayudarte.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: compact ? 13 : 15,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: compact ? 22 : 28,
            right: compact ? 124 : 170,
            bottom: 28,
            child: _buildBuscadorHero(compact),
          ),
        ],
      ),
    );
  }

  Widget _buildBuscadorHero(bool compact) {
    return Column(
      children: [
        Container(
          height: compact ? 52 : 58,
          decoration: BoxDecoration(
            color: const Color(0xFF151F2D).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: TextField(
            controller: _busquedaController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _buscar(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar servicio...',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.white.withValues(alpha: 0.82),
                size: 28,
              ),
              suffixIcon: IconButton(
                tooltip: 'Buscar',
                onPressed: _buscar,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        if (_cargandoEspecialidades)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _gold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Cargando especialidades...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),
              ],
            ),
          ),
        if (_sugerenciasBusqueda.isNotEmpty &&
            _busquedaController.text.trim().isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF121C29),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: _sugerenciasBusqueda.map((sugerencia) {
                final tipo = sugerencia['tipo']?.toLowerCase().trim() ?? '';
                final valor = sugerencia['valor'] ?? '';
                final icono = sugerencia['icono'] ?? '';

                return ListTile(
                  dense: true,
                  leading: Icon(
                    _iconoSugerencia(icono),
                    color: _gold,
                    size: 18,
                  ),
                  title: Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    tipo == 'servicio' ? 'Servicio' : 'Especialidad',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.48),
                    ),
                  ),
                  onTap: () => _seleccionarSugerencia(sugerencia),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildServiciosPrincipales(bool compact) {
    final servicios = [
      'Abogados',
      'Ajustadores',
      'Peritos en criminalistica',
      'Psicologos',
      'Agentes inmobiliarios',
      'Asistencia vial',
      'Contadores',
      'Agentes crediticios',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Servicios principales',
          action: 'Ver todos',
          onTap: widget.onAbrirServicios,
        ),
        const SizedBox(height: 14),
        GridView.builder(
          itemCount: servicios.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: compact ? 10 : 13,
            mainAxisSpacing: compact ? 10 : 13,
            childAspectRatio: compact ? 0.86 : 0.92,
          ),
          itemBuilder: (context, index) {
            final servicio = servicios[index];
            final color = _colorServicio(servicio);

            return InkWell(
              onTap: () => _irAServicio(servicio),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.055),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _iconoServicio(servicio),
                      color: color,
                      size: compact ? 34 : 41,
                    ),
                    const SizedBox(height: 9),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        _nombreCortoServicio(servicio),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: compact ? 11 : 12.6,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _nombreCortoServicio(String servicio) {
    switch (_normalizarServicio(servicio)) {
      case 'peritos en criminalistica':
        return 'Peritos';
      case 'agentes inmobiliarios':
        return 'Inmobiliario';
      case 'agentes crediticios':
        return 'Agentes\nCrediticios';
      case 'asistencia vial':
        return 'Asistencia\nVial';
      default:
        return servicio;
    }
  }

  Widget _buildServiciosEnCurso(bool compact) {
    final casosVisibles = _casos.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Tus servicios en curso',
          action: 'Ver todos',
          onTap: _cargarMisCasos,
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: _cargandoCasos
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(color: _gold),
                  ),
                )
              : _errorCasos.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        _errorCasos,
                        style: const TextStyle(
                          color: Color(0xFFFFA4A4),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : casosVisibles.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            'No tienes servicios en curso.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.62),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < casosVisibles.length; i++)
                              _buildCasoPremium(
                                casosVisibles[i],
                                i,
                                compact,
                                showProgress: i == 0,
                                isLast: i == casosVisibles.length - 1,
                              ),
                          ],
                        ),
        ),
      ],
    );
  }

  Widget _buildCasoPremium(
    Map<String, dynamic> caso,
    int index,
    bool compact, {
    required bool showProgress,
    required bool isLast,
  }) {
    final estado = caso['estado']?.toString() ?? 'pendiente';
    final colorEstado = _colorEstado(estado);
    final tituloRaw = caso['titulo']?.toString().trim() ?? '';
    final titulo = tituloRaw.isEmpty ? 'Caso #${caso['id'] ?? ''}' : tituloRaw;
    final servicio = caso['servicio']?.toString().trim() ?? '';
    final profesional = caso['profesional_nombre']?.toString().trim() ?? '';
    final fechaRaw =
        caso['fecha']?.toString() ?? caso['fecha_creacion']?.toString() ?? '';
    final fecha = _fechaCorta(fechaRaw.trim());
    final seleccionado = _casosSeleccionados.contains(index);

    return Dismissible(
      key: ValueKey(caso['id'] ?? index),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        color: Colors.blue,
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        final realIndex = _casos.indexOf(caso);
        if (direction == DismissDirection.startToEnd) {
          await _archivarCaso(realIndex);
        } else if (direction == DismissDirection.endToStart) {
          await _eliminarCaso(realIndex);
        }
        return false;
      },
      child: InkWell(
        onTap: () {
          if (_modoSeleccionCasos) {
            _toggleSeleccionCaso(_casos.indexOf(caso));
          }
        },
        onLongPress: () {
          final realIndex = _casos.indexOf(caso);
          setState(() {
            _modoSeleccionCasos = true;
            _casosSeleccionados.add(realIndex);
          });
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(18, 16, 14, isLast ? 16 : 14),
          decoration: BoxDecoration(
            color: seleccionado
                ? Colors.blue.withValues(alpha: 0.12)
                : Colors.transparent,
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.055),
                    ),
                  ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  if (_modoSeleccionCasos)
                    Checkbox(
                      value: seleccionado,
                      onChanged: (_) =>
                          _toggleSeleccionCaso(_casos.indexOf(caso)),
                      activeColor: _gold,
                    ),
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: colorEstado.withValues(alpha: 0.13),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _iconoServicio(servicio),
                      color: colorEstado,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: compact ? 14 : 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profesional.isNotEmpty
                              ? profesional
                              : servicio.isNotEmpty
                                  ? servicio
                                  : 'Consulta inicial',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.56),
                            fontSize: compact ? 12 : 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        estado,
                        style: TextStyle(
                          color: colorEstado,
                          fontSize: compact ? 12 : 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        fecha.isNotEmpty
                            ? fecha
                            : 'Expediente #${caso['id'] ?? ''}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.46),
                          fontSize: compact ? 10.5 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ],
              ),
              if (showProgress) ...[
                const SizedBox(height: 18),
                _buildProgressLine(colorEstado),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressLine(Color activeColor) {
    return Row(
      children: [
        _StepDot(label: 'Solicitado', active: true, color: activeColor),
        Expanded(child: _StepLine(active: true, color: activeColor)),
        _StepDot(label: 'Aceptado', active: true, color: activeColor),
        Expanded(child: _StepLine(active: true, color: activeColor)),
        _StepDot(label: 'En camino', active: true, color: activeColor),
        Expanded(child: _StepLine(active: false, color: activeColor)),
        _StepDot(label: 'Finalizado', active: false, color: activeColor),
      ],
    );
  }

  Widget _buildAccesosRapidos(bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accesos rápidos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _QuickAccess(
                icon: Icons.folder_rounded,
                title: 'Mis casos\n($_totalActivos)',
                color: const Color(0xFF7CA9FF),
                onTap: _cargarMisCasos,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAccess(
                icon: Icons.archive_rounded,
                title: 'Archivados\n($_totalArchivados)',
                color: const Color(0xFFD6A84F),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CasosArchivadosScreen(),
                    ),
                  );

                  if (!mounted) return;
                  await _cargarMisCasos();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAccess(
                icon: Icons.check_box_outlined,
                title: _modoSeleccionCasos ? 'Cancelar' : 'Seleccionar',
                color: const Color(0xFF54C26B),
                onTap: () {
                  if (_casos.isEmpty) return;
                  setState(() {
                    _modoSeleccionCasos = !_modoSeleccionCasos;
                    _casosSeleccionados.clear();
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAccess(
                icon: Icons.history_rounded,
                title: 'Historial',
                color: const Color(0xFF8DAAFF),
                onTap: _cargarMisCasos,
              ),
            ),
          ],
        ),
        if (_modoSeleccionCasos && _casosSeleccionados.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _archivarSeleccionados,
                  icon: const Icon(Icons.archive_rounded),
                  label: const Text('Archivar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: const Color(0xFF111827),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _eliminarSeleccionados,
                  icon: const Icon(Icons.delete_rounded),
                  label: const Text('Eliminar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 380;

    return Container(
      color: _bg,
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            right: -80,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.9,
                  colors: [
                    const Color(0xFF233653).withValues(alpha: 0.9),
                    const Color(0xFF0B1420).withValues(alpha: 0.78),
                    _bg.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 190,
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(
                'assets/iconos/mazo-libro.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: _gold,
              backgroundColor: _card,
              onRefresh: _cargarMisCasos,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  compact ? 16 : 22,
                  0,
                  compact ? 16 : 22,
                  26,
                ),
                children: [
                  _buildTopHeader(compact),
                  _buildHeroCard(compact),
                  const SizedBox(height: 26),
                  _buildServiciosPrincipales(compact),
                  const SizedBox(height: 28),
                  _buildServiciosEnCurso(compact),
                  const SizedBox(height: 28),
                  _buildAccesosRapidos(compact),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD6A84F);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              'Ver todos',
              style: TextStyle(
                color: gold,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;

  const _StepDot({
    required this.label,
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: Column(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? color : const Color(0xFF354254),
            ),
            child: Icon(
              active ? Icons.check_rounded : Icons.circle,
              color: active ? const Color(0xFF0B111B) : const Color(0xFF354254),
              size: active ? 14 : 7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active
                  ? Colors.white.withValues(alpha: 0.82)
                  : Colors.white.withValues(alpha: 0.42),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  final Color color;

  const _StepLine({
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -13),
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: active ? color : const Color(0xFF354254),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _QuickAccess extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccess({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF111B28),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 31),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 11.5,
                height: 1.12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
