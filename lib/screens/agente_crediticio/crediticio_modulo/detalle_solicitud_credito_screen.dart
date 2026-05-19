import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api_service_crediticio.dart';

class DetalleSolicitudCreditoScreen extends StatefulWidget {
  final int agenteId;
  final int solicitudId;

  const DetalleSolicitudCreditoScreen({
    super.key,
    required this.agenteId,
    required this.solicitudId,
  });

  @override
  State<DetalleSolicitudCreditoScreen> createState() =>
      _DetalleSolicitudCreditoScreenState();
}

class _DetalleSolicitudCreditoScreenState
    extends State<DetalleSolicitudCreditoScreen> {
  late Future<Map<String, dynamic>> _futureDetalle;

  final TextEditingController _comentariosController = TextEditingController();
  final TextEditingController _historialController = TextEditingController();

  String _estadoSeleccionado = 'pendiente';
  bool _guardando = false;
  bool _controllersCargados = false;

  final List<String> _estadosCredito = const [
    'pendiente',
    'en seguimiento',
    'aprobado',
    'rechazado',
  ];

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  @override
  void dispose() {
    _comentariosController.dispose();
    _historialController.dispose();
    super.dispose();
  }

  void _cargarDetalle() {
    _controllersCargados = false;
    _futureDetalle = ApiServiceCrediticio.getDetalleSolicitud(
      solicitudId: widget.solicitudId,
    );
  }

  Future<void> _refrescar() async {
    setState(() {
      _cargarDetalle();
    });

    await _futureDetalle;
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
      case 'en_revision':
      case 'en revisión':
        return const Color(0xFF9333EA);
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
      case 'en_revision':
      case 'en revisión':
        return 'En revisión';
      default:
        return estado.isEmpty ? 'Sin estado' : estado;
    }
  }

  String _documentoLegible(String tipo) {
    switch (tipo) {
      case 'ine':
        return 'INE';
      case 'comprobante_domicilio':
        return 'Comprobante de domicilio';
      case 'comprobante_ingresos':
        return 'Comprobante de ingresos';
      case 'estado_cuenta':
        return 'Estado de cuenta';
      case 'rfc':
        return 'RFC';
      case 'curp':
        return 'CURP';
      case 'buro_credito':
        return 'Buró de crédito';
      case 'otro':
        return 'Otro documento';
      default:
        return tipo.isEmpty ? 'Documento' : tipo;
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _guardarEstado() async {
    setState(() {
      _guardando = true;
    });

    try {
      await ApiServiceCrediticio.cambiarEstadoSolicitud(
        solicitudId: widget.solicitudId,
        estadoCredito: _estadoSeleccionado,
        comentariosAgente: _comentariosController.text.trim(),
      );

      _mostrarMensaje('Estado actualizado correctamente');
      await _refrescar();
    } catch (e) {
      _mostrarMensaje('$e');
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  Future<void> _guardarComentarios() async {
    setState(() {
      _guardando = true;
    });

    try {
      await ApiServiceCrediticio.actualizarComentariosSolicitud(
        solicitudId: widget.solicitudId,
        comentariosAgente: _comentariosController.text.trim(),
        historialCredito: _historialController.text.trim(),
      );

      _mostrarMensaje('Comentarios actualizados correctamente');
      await _refrescar();
    } catch (e) {
      _mostrarMensaje('$e');
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  Future<void> _validarDocumento({
    required int documentoId,
    required String estado,
  }) async {
    try {
      await ApiServiceCrediticio.validarDocumento(
        documentoId: documentoId,
        estado: estado,
      );

      _mostrarMensaje('Documento actualizado correctamente');
      await _refrescar();
    } catch (e) {
      _mostrarMensaje('$e');
    }
  }

  Future<void> _copiarUrl(String url) async {
    await Clipboard.setData(
      ClipboardData(text: url),
    );

    _mostrarMensaje('URL copiada');
  }

  void _verDocumento(Map<String, dynamic> documento) {
    final url = _texto(documento['archivo_url'], '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Documento del cliente',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: SelectableText(
          url.isEmpty ? 'Sin URL de documento' : url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          if (url.isNotEmpty)
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _copiarUrl(url);
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copiar URL'),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.97),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black.withOpacity(.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _rowInfo(
    String label,
    String value, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF6B7280),
            ),
            const SizedBox(width: 7),
          ],
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 14,
                  height: 1.25,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeEstado(String estado) {
    return Container(
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
    );
  }

  Widget _documentoCard(Map<String, dynamic> documento) {
    final id = int.tryParse('${documento['id'] ?? 0}') ?? 0;
    final tipo = _texto(documento['tipo_documento'], 'otro');
    final estado = _texto(documento['estado'], 'pendiente');
    final nombre = _texto(documento['archivo_nombre'], 'Documento');
    final comentarios = _texto(documento['comentarios'], '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color: Color(0xFF7C5E00),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _documentoLegible(tipo),
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              _badgeEstado(estado),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            nombre,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (comentarios.isNotEmpty && comentarios != 'No especificado') ...[
            const SizedBox(height: 8),
            Text(
              comentarios,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _verDocumento(documento),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Ver URL'),
              ),
              FilledButton.icon(
                onPressed: id > 0
                    ? () => _validarDocumento(
                          documentoId: id,
                          estado: 'aprobado',
                        )
                    : null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Aprobar'),
              ),
              OutlinedButton.icon(
                onPressed: id > 0
                    ? () => _validarDocumento(
                          documentoId: id,
                          estado: 'rechazado',
                        )
                    : null,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Rechazar'),
              ),
              OutlinedButton.icon(
                onPressed: id > 0
                    ? () => _validarDocumento(
                          documentoId: id,
                          estado: 'en_revision',
                        )
                    : null,
                icon: const Icon(Icons.hourglass_top_rounded),
                label: const Text('Revisión'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerDetalle(Map<String, dynamic> solicitud) {
    final cliente = _texto(solicitud['cliente_nombre'], 'Cliente');
    final estado = _texto(solicitud['estado_credito'], 'pendiente');
    final monto = _money(solicitud['monto_solicitado']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expediente crediticio',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            cliente,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _badgeEstado(estado),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Monto solicitado: \$$monto MXN',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contenido(Map<String, dynamic> data) {
    final solicitudRaw = data['solicitud'];
    final documentosRaw = data['documentos'];

    final solicitud = solicitudRaw is Map
        ? Map<String, dynamic>.from(solicitudRaw)
        : <String, dynamic>{};

    final documentos = documentosRaw is List ? documentosRaw : <dynamic>[];

    if (!_controllersCargados) {
      final estadoActual = _texto(solicitud['estado_credito'], 'pendiente');

      if (_estadosCredito.contains(estadoActual)) {
        _estadoSeleccionado = estadoActual;
      } else {
        _estadoSeleccionado = 'pendiente';
      }

      _comentariosController.text = _texto(solicitud['comentarios_agente'], '');
      _historialController.text = _texto(solicitud['historial_credito'], '');
      _controllersCargados = true;
    }

    final cliente = _texto(solicitud['cliente_nombre'], 'Cliente');
    final correo = _texto(solicitud['cliente_correo'], 'Sin correo');
    final telefono = _texto(solicitud['cliente_telefono'], 'Sin teléfono');
    final ciudad = _texto(solicitud['cliente_ciudad'], 'Sin ciudad');
    final ocupacion = _texto(solicitud['ocupacion'], 'Sin ocupación');
    final ingreso = _money(solicitud['ingreso_mensual']);
    final frecuencia = _texto(solicitud['ingreso_frecuencia'], 'No especificada');
    final monto = _money(solicitud['monto_solicitado']);
    final plazo = _texto(solicitud['plazo_meses'], '0');
    final fecha = _texto(solicitud['fecha_registro'], 'Sin fecha');

    return RefreshIndicator(
      onRefresh: _refrescar,
      color: const Color(0xFFD4AF37),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
        children: [
          _sectionTitle('Cliente'),
          _infoCard(
            title: 'Datos del cliente',
            children: [
              _rowInfo('Nombre', cliente, icon: Icons.person_outline),
              _rowInfo('Teléfono', telefono, icon: Icons.phone_outlined),
              _rowInfo('Correo', correo, icon: Icons.email_outlined),
              _rowInfo('Ciudad', ciudad, icon: Icons.location_city_outlined),
              _rowInfo('Fecha registro', fecha, icon: Icons.event_outlined),
            ],
          ),
          _sectionTitle('Datos del crédito'),
          _infoCard(
            title: 'Información financiera',
            children: [
              _rowInfo('Ocupación', ocupacion, icon: Icons.work_outline),
              _rowInfo(
                'Ingreso mensual',
                '\$$ingreso MXN',
                icon: Icons.payments_outlined,
              ),
              _rowInfo(
                'Frecuencia de ingreso',
                frecuencia,
                icon: Icons.calendar_month_outlined,
              ),
              _rowInfo(
                'Monto solicitado',
                '\$$monto MXN',
                icon: Icons.request_quote_outlined,
              ),
              _rowInfo(
                'Plazo',
                '$plazo meses',
                icon: Icons.schedule_outlined,
              ),
            ],
          ),
          _sectionTitle('Estado y observaciones'),
          _infoCard(
            title: 'Gestión de solicitud',
            children: [
              DropdownButtonFormField<String>(
                value: _estadoSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Estado del crédito',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'pendiente',
                    child: Text('Pendiente'),
                  ),
                  DropdownMenuItem(
                    value: 'en seguimiento',
                    child: Text('En seguimiento'),
                  ),
                  DropdownMenuItem(
                    value: 'aprobado',
                    child: Text('Aprobado'),
                  ),
                  DropdownMenuItem(
                    value: 'rechazado',
                    child: Text('Rechazado'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _estadoSeleccionado = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _comentariosController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Comentarios del agente',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _historialController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Historial crediticio / observaciones',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _guardando ? null : _guardarEstado,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        _guardando ? 'Guardando...' : 'Guardar estado',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _guardando ? null : _guardarComentarios,
                      icon: const Icon(Icons.notes_outlined),
                      label: const Text('Guardar notas'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          _sectionTitle('Documentos del cliente'),
          _infoCard(
            title: '${documentos.length} documentos cargados',
            children: [
              if (documentos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'El cliente aún no ha cargado documentos.',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                ...documentos.whereType<Map>().map((item) {
                  return _documentoCard(
                    Map<String, dynamic>.from(item),
                  );
                }),
            ],
          ),
        ],
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
              'Error al cargar detalle',
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

  Widget _cargando() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFD4AF37),
      ),
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
          'Detalle de solicitud',
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureDetalle,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _cargando();
          }

          if (snapshot.hasError) {
            return _estadoError(snapshot.error!);
          }

          final data = snapshot.data ?? {};
          final solicitudRaw = data['solicitud'];
          final solicitud = solicitudRaw is Map
              ? Map<String, dynamic>.from(solicitudRaw)
              : <String, dynamic>{};

          return Stack(
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
                  _headerDetalle(solicitud),
                  Expanded(
                    child: _contenido(data),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}