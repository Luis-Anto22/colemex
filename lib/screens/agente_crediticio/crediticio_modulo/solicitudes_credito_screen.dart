import 'package:flutter/material.dart';

import '../api_service_crediticio.dart';
import 'detalle_solicitud_credito_screen.dart';

class SolicitudesCreditoScreen extends StatefulWidget {
  final int agenteId;

  const SolicitudesCreditoScreen({
    super.key,
    required this.agenteId,
  });

  @override
  State<SolicitudesCreditoScreen> createState() =>
      _SolicitudesCreditoScreenState();
}

class _SolicitudesCreditoScreenState extends State<SolicitudesCreditoScreen> {
  late Future<List<dynamic>> _futureSolicitudes;

  final TextEditingController _busquedaController = TextEditingController();

  String _filtroEstado = 'todos';

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _cargarSolicitudes() {
    _futureSolicitudes = ApiServiceCrediticio.getSolicitudes(
      agenteId: widget.agenteId,
    );
  }

  Future<void> _refrescar() async {
    setState(() {
      _cargarSolicitudes();
    });

    await _futureSolicitudes;
  }

  String _texto(dynamic value, [String fallback = 'No especificado']) {
    final text = '${value ?? ''}'.trim();

    if (text.isEmpty || text == 'null') {
      return fallback;
    }

    return text;
  }

  String _money(dynamic value) {
    final raw = double.tryParse('${value ?? 0}') ?? 0;
    return raw.toStringAsFixed(2);
  }

  List<dynamic> _filtrarSolicitudes(List<dynamic> solicitudes) {
    final buscar = _busquedaController.text.trim().toLowerCase();

    return solicitudes.where((item) {
      if (item is! Map) return false;

      final solicitud = Map<String, dynamic>.from(item);

      final cliente = _texto(solicitud['cliente_nombre'], '').toLowerCase();
      final correo = _texto(solicitud['cliente_correo'], '').toLowerCase();
      final telefono = _texto(solicitud['cliente_telefono'], '').toLowerCase();
      final ocupacion = _texto(solicitud['ocupacion'], '').toLowerCase();
      final estado = _texto(solicitud['estado_credito'], '').toLowerCase();
      final historial =
          _texto(solicitud['historial_credito'], '').toLowerCase();
      final comentarios =
          _texto(solicitud['comentarios_agente'], '').toLowerCase();

      final coincideBusqueda = buscar.isEmpty ||
          cliente.contains(buscar) ||
          correo.contains(buscar) ||
          telefono.contains(buscar) ||
          ocupacion.contains(buscar) ||
          estado.contains(buscar) ||
          historial.contains(buscar) ||
          comentarios.contains(buscar);

      final coincideEstado =
          _filtroEstado == 'todos' || estado == _filtroEstado;

      return coincideBusqueda && coincideEstado;
    }).toList();
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobado':
        return const Color(0xFF15803D);
      case 'rechazado':
        return const Color(0xFFB91C1C);
      case 'en seguimiento':
      case 'en_seguimiento':
        return const Color(0xFFB7791F);
      case 'pendiente':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _estadoLegible(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'aprobado':
        return 'Aprobado';
      case 'rechazado':
        return 'Rechazado';
      case 'en seguimiento':
      case 'en_seguimiento':
        return 'En seguimiento';
      default:
        return estado.isEmpty ? 'Sin estado' : estado;
    }
  }

  Widget _chipFiltro({
    required String label,
    required String value,
  }) {
    final selected = _filtroEstado == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _filtroEstado = value;
        });
      },
      selectedColor: const Color(0xFFD4AF37).withOpacity(.18),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected
            ? const Color(0xFFD4AF37).withOpacity(.70)
            : Colors.black.withOpacity(.08),
      ),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF7C5E00) : const Color(0xFF374151),
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _infoLine({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniBox({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withOpacity(.05),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _solicitudCard(Map<String, dynamic> solicitud) {
    final id = int.tryParse('${solicitud['id'] ?? 0}') ?? 0;

    final cliente = _texto(solicitud['cliente_nombre'], 'Cliente');
    final correo = _texto(solicitud['cliente_correo'], 'Sin correo');
    final telefono = _texto(solicitud['cliente_telefono'], 'Sin teléfono');
    final ocupacion = _texto(solicitud['ocupacion'], 'Sin ocupación');
    final estado = _texto(solicitud['estado_credito'], 'pendiente');
    final ingreso = _money(solicitud['ingreso_mensual']);
    final monto = _money(solicitud['monto_solicitado']);
    final plazo = _texto(solicitud['plazo_meses'], '0');
    final documentosTotal = _texto(solicitud['documentos_total'], '0');
    final documentosAprobados = _texto(solicitud['documentos_aprobados'], '0');

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () async {
        if (id <= 0) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalleSolicitudCreditoScreen(
              agenteId: widget.agenteId,
              solicitudId: id,
            ),
          ),
        );

        if (mounted) {
          _refrescar();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.97),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.black.withOpacity(.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.07),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.request_quote_outlined,
                  color: Color(0xFF7C5E00),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cliente,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _estadoColor(estado).withOpacity(.12),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            _estadoLegible(estado),
                            style: TextStyle(
                              color: _estadoColor(estado),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _infoLine(
                      icon: Icons.work_outline,
                      text: ocupacion,
                    ),
                    const SizedBox(height: 5),
                    _infoLine(
                      icon: Icons.phone_outlined,
                      text: telefono,
                    ),
                    const SizedBox(height: 5),
                    _infoLine(
                      icon: Icons.email_outlined,
                      text: correo,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _miniBox(
                          title: 'Monto',
                          value: '\$$monto',
                        ),
                        _miniBox(
                          title: 'Ingreso',
                          value: '\$$ingreso',
                        ),
                        _miniBox(
                          title: 'Plazo',
                          value: '$plazo meses',
                        ),
                        _miniBox(
                          title: 'Docs',
                          value: '$documentosAprobados/$documentosTotal',
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

  Widget _estadoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 92,
              width: 92,
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.request_quote_outlined,
                size: 46,
                color: Color(0xFF7C5E00),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aún no hay solicitudes de crédito',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cuando un cliente solicite crédito, aparecerá aquí para su revisión.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 44,
            ),
            const SizedBox(height: 10),
            const Text(
              'Error al cargar solicitudes',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _refrescar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    return FutureBuilder<List<dynamic>>(
      future: _futureSolicitudes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFD4AF37),
            ),
          );
        }

        if (snapshot.hasError) {
          return _estadoError(snapshot.error!);
        }

        final solicitudes = snapshot.data ?? [];
        final filtradas = _filtrarSolicitudes(solicitudes);

        if (solicitudes.isEmpty) {
          return _estadoVacio();
        }

        return RefreshIndicator(
          onRefresh: _refrescar,
          color: const Color(0xFFD4AF37),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.97),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.black.withOpacity(.06),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _busquedaController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText:
                            'Buscar por cliente, teléfono, correo u ocupación...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chipFiltro(label: 'Todos', value: 'todos'),
                          _chipFiltro(label: 'Pendiente', value: 'pendiente'),
                          _chipFiltro(
                            label: 'Seguimiento',
                            value: 'en seguimiento',
                          ),
                          _chipFiltro(label: 'Aprobado', value: 'aprobado'),
                          _chipFiltro(label: 'Rechazado', value: 'rechazado'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${filtradas.length} solicitudes',
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (filtradas.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'No hay solicitudes con esos filtros',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                ...filtradas.whereType<Map>().map((item) {
                  return _solicitudCard(
                    Map<String, dynamic>.from(item),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        title: const Text(
          'Solicitudes de crédito',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refrescar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: .045,
              child: Image.asset(
                'assets/iconos/mazo-libro.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                decoration: const BoxDecoration(
                  color: Color(0xFF111827),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solicitudes asignadas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Revisa clientes, monto solicitado, documentos y estado del crédito.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _contenido()),
            ],
          ),
        ],
      ),
    );
  }
}