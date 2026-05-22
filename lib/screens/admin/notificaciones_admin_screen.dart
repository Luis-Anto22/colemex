import 'dart:math';

import 'package:flutter/material.dart';

import 'api_service_profesionales.dart';

class NotificacionesAdminScreen extends StatefulWidget {
  const NotificacionesAdminScreen({super.key});

  @override
  State<NotificacionesAdminScreen> createState() =>
      _NotificacionesAdminScreenState();
}

class _NotificacionesAdminScreenState extends State<NotificacionesAdminScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _destinatario = 'Todos';
  String _filtroTipo = 'Todos';
  String _perfilDestino = 'Todos';

  bool _isLoading = true;
  bool _isSending = false;

  String? _error;
  List<_NotificacionAdmin> _notificaciones = [];

  final List<String> _perfiles = const [
    'Todos',
    'Abogados',
    'Ajustadores',
    'Peritos en criminalística',
    'Valuadores',
    'Investigadores',
    'Psicólogos',
    'Agentes inmobiliarios',
    'Contadores',
    'Agentes crediticios',
    'Asistencia vial',
  ];

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _searchController.addListener(_onSearchChanged);

    _cargarNotificaciones();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _tituloController.dispose();
    _mensajeController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _cargarNotificaciones() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiServiceProfesionales.obtenerNotificacionesAdmin(
        buscar: _searchController.text.trim(),
        destinatario: _filtroTipo,
      );

      final notificaciones = data
          .map((item) => _NotificacionAdmin.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();

      if (!mounted) return;

      setState(() {
        _notificaciones = notificaciones;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<_NotificacionAdmin> get _filtradas {
    final query = _searchController.text.trim().toLowerCase();

    return _notificaciones.where((n) {
      final coincideBusqueda = query.isEmpty ||
          n.titulo.toLowerCase().contains(query) ||
          n.mensaje.toLowerCase().contains(query) ||
          n.destinatario.toLowerCase().contains(query) ||
          n.estado.toLowerCase().contains(query) ||
          n.perfil.toLowerCase().contains(query);

      final coincideTipo =
          _filtroTipo == 'Todos' || n.destinatario == _filtroTipo;

      return coincideBusqueda && coincideTipo;
    }).toList();
  }

  int get _enviadas =>
      _notificaciones.where((n) => n.estado.toLowerCase() == 'enviada').length;

  int get _fallidas =>
      _notificaciones.where((n) => n.estado.toLowerCase() == 'fallida').length;

  int get _tokensEnviados =>
      _notificaciones.fold(0, (sum, n) => sum + n.tokensEnviados);

  int get _tokensEncontrados =>
      _notificaciones.fold(0, (sum, n) => sum + n.tokensEncontrados);

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 900;
    final filtradas = _filtradas;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.90),
        foregroundColor: Colors.white,
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _isLoading ? null : _cargarNotificaciones,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Enviar notificación',
            onPressed: _isSending ? null : _enviarNotificacion,
            icon: const Icon(Icons.send_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF38BDF8),
        foregroundColor: Colors.black,
        elevation: 10,
        onPressed: _isSending ? null : _enviarNotificacion,
        icon: _isSending
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.black,
                ),
              )
            : const Icon(Icons.notifications_active_rounded),
        label: Text(
          _isSending ? 'Enviando...' : 'Enviar aviso',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
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
                    const Color(0xFF38BDF8).withOpacity(0.24),
                    const Color(0xFF020617).withOpacity(0.92),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: Colors.black,
              backgroundColor: const Color(0xFF38BDF8),
              onRefresh: _cargarNotificaciones,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  isWide ? 24 : 16,
                  16,
                  isWide ? 24 : 16,
                  96,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderNotificaciones(
                      total: _notificaciones.length,
                      enviadas: _enviadas,
                      fallidas: _fallidas,
                    ),
                    const SizedBox(height: 22),
                    const _SectionTitle(
                      title: 'Centro de avisos',
                      subtitle:
                          'Envía push reales desde el panel admin y consulta el historial.',
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        _MetricCard(
                          title: 'Notificaciones',
                          value: _notificaciones.length.toString(),
                          subtitle: 'Historial guardado',
                          icon: Icons.notifications_active_rounded,
                          glowColor: const Color(0xFF38BDF8),
                        ),
                        _MetricCard(
                          title: 'Enviadas',
                          value: _enviadas.toString(),
                          subtitle: 'Push enviados',
                          icon: Icons.check_circle_rounded,
                          glowColor: const Color(0xFF22C55E),
                        ),
                        _MetricCard(
                          title: 'Fallidas',
                          value: _fallidas.toString(),
                          subtitle: 'Sin tokens o con error',
                          icon: Icons.error_rounded,
                          glowColor: const Color(0xFFEF4444),
                        ),
                        _MetricCard(
                          title: 'Tokens',
                          value: '$_tokensEnviados/$_tokensEncontrados',
                          subtitle: 'Enviados / encontrados',
                          icon: Icons.phone_android_rounded,
                          glowColor: const Color(0xFFA855F7),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final bool twoColumns = constraints.maxWidth >= 1000;

                        if (twoColumns) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _ComposerPanel(
                                  tituloController: _tituloController,
                                  mensajeController: _mensajeController,
                                  destinatario: _destinatario,
                                  perfilDestino: _perfilDestino,
                                  perfiles: _perfiles,
                                  isSending: _isSending,
                                  onDestinatarioChanged: (value) {
                                    setState(() {
                                      _destinatario = value;
                                      if (_destinatario != 'Profesionales') {
                                        _perfilDestino = 'Todos';
                                      }
                                    });
                                  },
                                  onPerfilChanged: (value) {
                                    setState(() {
                                      _perfilDestino = value;
                                    });
                                  },
                                  onEnviar: _enviarNotificacion,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildHistorialPanel(filtradas),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            _ComposerPanel(
                              tituloController: _tituloController,
                              mensajeController: _mensajeController,
                              destinatario: _destinatario,
                              perfilDestino: _perfilDestino,
                              perfiles: _perfiles,
                              isSending: _isSending,
                              onDestinatarioChanged: (value) {
                                setState(() {
                                  _destinatario = value;
                                  if (_destinatario != 'Profesionales') {
                                    _perfilDestino = 'Todos';
                                  }
                                });
                              },
                              onPerfilChanged: (value) {
                                setState(() {
                                  _perfilDestino = value;
                                });
                              },
                              onEnviar: _enviarNotificacion,
                            ),
                            const SizedBox(height: 26),
                            _buildHistorialPanel(filtradas),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialPanel(List<_NotificacionAdmin> filtradas) {
    final bool isWide = MediaQuery.of(context).size.width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Historial',
          subtitle: 'Búsqueda y filtros de notificaciones enviadas.',
        ),
        const SizedBox(height: 14),
        _SearchFilterPanel(
          controller: _searchController,
          filtroTipo: _filtroTipo,
          onFiltroChanged: (value) {
            setState(() => _filtroTipo = value);
            _cargarNotificaciones();
          },
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const _LoadingPanel()
        else if (_error != null)
          _ErrorPanel(
            message: _error!,
            onRetry: _cargarNotificaciones,
          )
        else
          _buildList(filtradas, isWide: isWide),
      ],
    );
  }

  Widget _buildList(
    List<_NotificacionAdmin> filtradas, {
    required bool isWide,
  }) {
    if (filtradas.isEmpty) return const _EmptyPanel();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtradas.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 2 : 1,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: isWide ? 2.05 : 1.30,
      ),
      itemBuilder: (_, index) {
        final notificacion = filtradas[index];

        return _NotificationCard(
          notificacion: notificacion,
          onTap: () => _mostrarDetalle(notificacion),
          onReenviar: () => _reenviarNotificacion(notificacion),
        );
      },
    );
  }

  Future<void> _enviarNotificacion() async {
    final titulo = _tituloController.text.trim();
    final mensaje = _mensajeController.text.trim();

    if (titulo.isEmpty) {
      _mostrarSnack('Escribe el título de la notificación.', isError: true);
      return;
    }

    if (mensaje.isEmpty) {
      _mostrarSnack('Escribe el mensaje de la notificación.', isError: true);
      return;
    }

    setState(() => _isSending = true);

    try {
      final result = await ApiServiceProfesionales.enviarNotificacionAdmin(
        titulo: titulo,
        mensaje: mensaje,
        destinatario: _destinatario,
        perfil: _destinatario == 'Profesionales' ? _perfilDestino : null,
      );

      if (!mounted) return;

      _tituloController.clear();
      _mensajeController.clear();

      await _cargarNotificaciones();

      final success = result['success'] == true;
      final resultado = result['resultado'];
      final tokensEncontrados = resultado is Map
          ? (resultado['tokens_encontrados'] ?? 0).toString()
          : '0';
      final tokensEnviados = resultado is Map
          ? (resultado['tokens_enviados'] ?? 0).toString()
          : '0';

      _mostrarResultadoEnvio(
        success: success,
        titulo: success ? 'Notificación enviada' : 'Notificación registrada',
        mensaje: result['mensaje']?.toString() ??
            'La notificación fue procesada por el servidor.',
        tokensEncontrados: tokensEncontrados,
        tokensEnviados: tokensEnviados,
      );
    } catch (e) {
      if (!mounted) return;

      _mostrarSnack(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _reenviarNotificacion(_NotificacionAdmin n) async {
    setState(() => _isSending = true);

    try {
      final result = await ApiServiceProfesionales.enviarNotificacionAdmin(
        titulo: n.titulo,
        mensaje: n.mensaje,
        destinatario: n.destinatario,
        perfil: n.perfil.isNotEmpty ? n.perfil : null,
      );

      if (!mounted) return;

      await _cargarNotificaciones();

      final success = result['success'] == true;
      final resultado = result['resultado'];
      final tokensEncontrados = resultado is Map
          ? (resultado['tokens_encontrados'] ?? 0).toString()
          : '0';
      final tokensEnviados = resultado is Map
          ? (resultado['tokens_enviados'] ?? 0).toString()
          : '0';

      _mostrarResultadoEnvio(
        success: success,
        titulo: success ? 'Reenviada correctamente' : 'Reenvío registrado',
        mensaje: result['mensaje']?.toString() ??
            'La notificación fue procesada por el servidor.',
        tokensEncontrados: tokensEncontrados,
        tokensEnviados: tokensEnviados,
      );
    } catch (e) {
      if (!mounted) return;

      _mostrarSnack(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _mostrarResultadoEnvio({
    required bool success,
    required String titulo,
    required String mensaje,
    required String tokensEncontrados,
    required String tokensEnviados,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _PremiumBottomSheet(
          title: titulo,
          icon: success ? Icons.check_circle_rounded : Icons.info_rounded,
          glowColor:
              success ? const Color(0xFF22C55E) : const Color(0xFFFACC15),
          child: Column(
            children: [
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              _InfoTile(
                icon: Icons.search_rounded,
                title: 'Tokens encontrados',
                value: tokensEncontrados,
                color: const Color(0xFF38BDF8),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.send_rounded,
                title: 'Tokens enviados',
                value: tokensEnviados,
                color: const Color(0xFF22C55E),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDetalle(_NotificacionAdmin n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _PremiumBottomSheet(
          title: n.titulo,
          icon: n.icono,
          glowColor: _destinatarioColor(n.destinatario),
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.message_rounded,
                title: 'Mensaje',
                value: n.mensaje,
                color: const Color(0xFF38BDF8),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.group_rounded,
                title: 'Destinatario',
                value: n.destinatario,
                color: const Color(0xFFA855F7),
              ),
              if (n.perfil.isNotEmpty) ...[
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.badge_rounded,
                  title: 'Perfil',
                  value: n.perfil,
                  color: const Color(0xFFFACC15),
                ),
              ],
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.check_circle_rounded,
                title: 'Estado',
                value: n.estadoLegible,
                color: _estadoColor(n.estado),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.phone_android_rounded,
                title: 'Tokens',
                value:
                    'Encontrados: ${n.tokensEncontrados} | Enviados: ${n.tokensEnviados} | Fallidos: ${n.tokensFallidos}',
                color: const Color(0xFF06B6D4),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.calendar_month_rounded,
                title: 'Fecha',
                value: n.fecha,
                color: const Color(0xFF22C55E),
              ),
              if (n.error.isNotEmpty) ...[
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.error_rounded,
                  title: 'Error',
                  value: n.error,
                  color: const Color(0xFFEF4444),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _mostrarSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _HeaderNotificaciones extends StatelessWidget {
  final int total;
  final int enviadas;
  final int fallidas;

  const _HeaderNotificaciones({
    required this.total,
    required this.enviadas,
    required this.fallidas,
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
            color: const Color(0xFF38BDF8).withOpacity(0.16),
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
                  total: total,
                  enviadas: enviadas,
                  fallidas: fallidas,
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
                  total: total,
                  enviadas: enviadas,
                  fallidas: fallidas,
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
            Color(0xFF38BDF8),
            Color(0xFF2563EB),
            Color(0xFF1E40AF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withOpacity(0.30),
            blurRadius: 28,
          ),
        ],
      ),
      child: const Icon(
        Icons.notifications_active_rounded,
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
          'Centro de notificaciones',
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
          'Envía avisos push a clientes, profesionales, auditores o todo el sistema.',
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
  final int total;
  final int enviadas;
  final int fallidas;

  const _HeaderCounters({
    required this.total,
    required this.enviadas,
    required this.fallidas,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _SmallCounter(
          label: 'Total',
          value: total.toString(),
          icon: Icons.notifications_rounded,
          color: const Color(0xFF38BDF8),
        ),
        _SmallCounter(
          label: 'Enviadas',
          value: enviadas.toString(),
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF22C55E),
        ),
        _SmallCounter(
          label: 'Fallidas',
          value: fallidas.toString(),
          icon: Icons.error_rounded,
          color: const Color(0xFFEF4444),
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

class _ComposerPanel extends StatelessWidget {
  final TextEditingController tituloController;
  final TextEditingController mensajeController;
  final String destinatario;
  final String perfilDestino;
  final List<String> perfiles;
  final bool isSending;
  final ValueChanged<String> onDestinatarioChanged;
  final ValueChanged<String> onPerfilChanged;
  final VoidCallback onEnviar;

  const _ComposerPanel({
    required this.tituloController,
    required this.mensajeController,
    required this.destinatario,
    required this.perfilDestino,
    required this.perfiles,
    required this.isSending,
    required this.onDestinatarioChanged,
    required this.onPerfilChanged,
    required this.onEnviar,
  });

  @override
  Widget build(BuildContext context) {
    return _DarkPanel(
      title: 'Crear notificación',
      icon: Icons.edit_notifications_rounded,
      glowColor: const Color(0xFF38BDF8),
      child: Column(
        children: [
          _PremiumTextField(
            controller: tituloController,
            label: 'Título del aviso',
            icon: Icons.title_rounded,
            color: const Color(0xFF38BDF8),
          ),
          const SizedBox(height: 14),
          _PremiumDropdown(
            value: destinatario,
            label: 'Destinatario',
            icon: Icons.group_rounded,
            color: const Color(0xFFA855F7),
            items: const [
              'Todos',
              'Clientes',
              'Profesionales',
              'Auditores',
              'Admin',
            ],
            onChanged: onDestinatarioChanged,
          ),
          if (destinatario == 'Profesionales') ...[
            const SizedBox(height: 14),
            _PremiumDropdown(
              value: perfilDestino,
              label: 'Perfil profesional',
              icon: Icons.badge_rounded,
              color: const Color(0xFFFACC15),
              items: perfiles,
              onChanged: onPerfilChanged,
            ),
          ],
          const SizedBox(height: 14),
          _PremiumTextField(
            controller: mensajeController,
            label: 'Mensaje',
            icon: Icons.message_rounded,
            color: const Color(0xFF22C55E),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          const _FutureInfo(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: isSending ? null : onEnviar,
              icon: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                isSending ? 'Enviando...' : 'Enviar notificación',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FutureInfo extends StatelessWidget {
  const _FutureInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF38BDF8).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF38BDF8).withOpacity(0.20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_rounded,
            color: Color(0xFF38BDF8),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Esta pantalla ya envía push reales. Si no hay tokens FCM guardados, se registra como fallida en el historial.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: 12.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final _NotificacionAdmin notificacion;
  final VoidCallback onTap;
  final VoidCallback onReenviar;

  const _NotificationCard({
    required this.notificacion,
    required this.onTap,
    required this.onReenviar,
  });

  @override
  Widget build(BuildContext context) {
    final color = _destinatarioColor(notificacion.destinatario);
    final estadoColor = _estadoColor(notificacion.estado);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.065),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.11)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.11),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CircleIcon(icon: notificacion.icono, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NameBlock(
                      title: notificacion.titulo,
                      subtitle: notificacion.destinatario,
                    ),
                  ),
                  _EstadoBadge(
                    estado: notificacion.estadoLegible,
                    color: estadoColor,
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                notificacion.mensaje,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.58),
                  height: 1.35,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniChip(
                    icon: Icons.search_rounded,
                    label: 'Tokens: ${notificacion.tokensEncontrados}',
                    color: const Color(0xFF38BDF8),
                  ),
                  _MiniChip(
                    icon: Icons.send_rounded,
                    label: 'Enviados: ${notificacion.tokensEnviados}',
                    color: const Color(0xFF22C55E),
                  ),
                  if (notificacion.tokensFallidos > 0)
                    _MiniChip(
                      icon: Icons.error_rounded,
                      label: 'Fallidos: ${notificacion.tokensFallidos}',
                      color: const Color(0xFFEF4444),
                    ),
                ],
              ),
              Divider(color: Colors.white.withOpacity(0.10), height: 22),
              Row(
                children: [
                  Expanded(
                    child: _MiniInfo(
                      icon: Icons.calendar_month_rounded,
                      text: notificacion.fecha,
                    ),
                  ),
                  _ActionButton(
                    icon: Icons.send_rounded,
                    color: const Color(0xFF38BDF8),
                    onTap: onReenviar,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchFilterPanel extends StatelessWidget {
  final TextEditingController controller;
  final String filtroTipo;
  final ValueChanged<String> onFiltroChanged;

  const _SearchFilterPanel({
    required this.controller,
    required this.filtroTipo,
    required this.onFiltroChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 720;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(child: _buildSearch()),
                const SizedBox(width: 12),
                SizedBox(width: 235, child: _buildDropdown()),
              ],
            )
          : Column(
              children: [
                _buildSearch(),
                const SizedBox(height: 12),
                _buildDropdown(),
              ],
            ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      cursorColor: const Color(0xFF38BDF8),
      decoration: InputDecoration(
        hintText: 'Buscar notificación por título, mensaje o destinatario...',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.42),
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFF38BDF8),
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(19)),
          borderSide: BorderSide(
            color: Color(0xFF38BDF8),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: filtroTipo,
      dropdownColor: const Color(0xFF020617),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      iconEnabledColor: const Color(0xFF38BDF8),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.tune_rounded,
          color: Color(0xFF38BDF8),
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Todos', child: Text('Todos')),
        DropdownMenuItem(value: 'Clientes', child: Text('Clientes')),
        DropdownMenuItem(value: 'Profesionales', child: Text('Profesionales')),
        DropdownMenuItem(value: 'Auditores', child: Text('Auditores')),
        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
      ],
      onChanged: (value) {
        if (value != null) onFiltroChanged(value);
      },
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color color;
  final int maxLines;

  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.color,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      cursorColor: color,
      decoration: _premiumInputDecoration(
        label: label,
        icon: icon,
        color: color,
      ),
    );
  }
}

class _PremiumDropdown extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _PremiumDropdown({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF020617),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      iconEnabledColor: color,
      decoration: _premiumInputDecoration(
        label: label,
        icon: icon,
        color: color,
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

InputDecoration _premiumInputDecoration({
  required String label,
  required IconData icon,
  required Color color,
}) {
  return InputDecoration(
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
  );
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
                Color(0xFF38BDF8),
                Color(0xFF2563EB),
              ],
            ),
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withOpacity(0.35),
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color glowColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmall = MediaQuery.of(context).size.width < 500;

    return Container(
      width: isSmall ? (MediaQuery.of(context).size.width - 46) / 2 : 250,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.065),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.12),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GlowIcon(icon: icon, glowColor: glowColor),
          const SizedBox(height: 13),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE2E8F0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.52),
            ),
          ),
        ],
      ),
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

class _EstadoBadge extends StatelessWidget {
  final String estado;
  final Color color;

  const _EstadoBadge({
    required this.estado,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _CircleIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.65), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.30), blurRadius: 18),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 27),
      ),
    );
  }
}

class _NameBlock extends StatelessWidget {
  final String title;
  final String subtitle;

  const _NameBlock({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(0.56),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.50), size: 17),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.62),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.11),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
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
        child: SingleChildScrollView(
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
                    foregroundColor:
                        glowColor == const Color(0xFFFACC15) ||
                                glowColor == const Color(0xFF38BDF8)
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
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.8,
                    fontWeight: FontWeight.w900,
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

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: const CircularProgressIndicator(
        color: Color(0xFF38BDF8),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_rounded,
            color: Color(0xFFEF4444),
            size: 52,
          ),
          const SizedBox(height: 12),
          const Text(
            'No se pudo cargar el historial',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'Reintentar',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.manage_search_rounded,
            color: Color(0xFF38BDF8),
            size: 52,
          ),
          const SizedBox(height: 12),
          const Text(
            'No hay notificaciones para mostrar',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Intenta cambiar el filtro o la búsqueda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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

Color _estadoColor(String estado) {
  final e = estado.toLowerCase();

  if (e.contains('enviada')) return const Color(0xFF22C55E);
  if (e.contains('fallida')) return const Color(0xFFEF4444);
  if (e.contains('programada')) return const Color(0xFFFACC15);

  return const Color(0xFF38BDF8);
}

Color _destinatarioColor(String destinatario) {
  final d = destinatario.toLowerCase();

  if (d.contains('cliente')) return const Color(0xFF22C55E);
  if (d.contains('profesional')) return const Color(0xFF38BDF8);
  if (d.contains('auditor')) return const Color(0xFFA855F7);
  if (d.contains('admin')) return const Color(0xFFFACC15);

  return const Color(0xFF06B6D4);
}

class _MovingParticlesPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _MovingParticlesPainter({required this.progress})
      : particles = List.generate(80, (index) {
          final random = Random(index * 881);
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

class _NotificacionAdmin {
  final int id;
  final String titulo;
  final String mensaje;
  final String destinatario;
  final String perfil;
  final String estado;
  final int tokensEncontrados;
  final int tokensEnviados;
  final int tokensFallidos;
  final String error;
  final String fecha;
  final IconData icono;

  const _NotificacionAdmin({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.destinatario,
    required this.perfil,
    required this.estado,
    required this.tokensEncontrados,
    required this.tokensEnviados,
    required this.tokensFallidos,
    required this.error,
    required this.fecha,
    required this.icono,
  });

  factory _NotificacionAdmin.fromJson(Map<String, dynamic> json) {
    final destinatario = _toString(json['destinatario'], fallback: 'Todos');

    return _NotificacionAdmin(
      id: _toInt(json['id']),
      titulo: _toString(json['titulo']),
      mensaje: _toString(json['mensaje']),
      destinatario: destinatario,
      perfil: _toString(json['perfil']),
      estado: _toString(json['estado'], fallback: 'fallida'),
      tokensEncontrados: _toInt(json['tokens_encontrados']),
      tokensEnviados: _toInt(json['tokens_enviados']),
      tokensFallidos: _toInt(json['tokens_fallidos']),
      error: _toString(json['error']),
      fecha: _formatFecha(json['fecha_envio']),
      icono: _iconoDestinatario(destinatario),
    );
  }

  String get estadoLegible {
    final e = estado.toLowerCase();

    if (e == 'enviada') return 'Enviada';
    if (e == 'fallida') return 'Fallida';
    if (e == 'programada') return 'Programada';

    return estado.isEmpty ? 'Sin estado' : estado;
  }

  static IconData _iconoDestinatario(String destinatario) {
    final d = destinatario.toLowerCase();

    if (d.contains('cliente')) return Icons.people_alt_rounded;
    if (d.contains('profesional')) return Icons.badge_rounded;
    if (d.contains('auditor')) return Icons.verified_user_rounded;
    if (d.contains('admin')) return Icons.admin_panel_settings_rounded;

    return Icons.notifications_active_rounded;
  }

  static String _formatFecha(dynamic value) {
    final raw = _toString(value);

    if (raw.isEmpty) return 'Sin fecha';

    final date = DateTime.tryParse(raw);

    if (date == null) return raw;

    final local = date.toLocal();

    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }

  static String _toString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') return fallback;

    return text;
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;

    if (value is int) return value;

    return int.tryParse(value.toString()) ?? fallback;
  }
}