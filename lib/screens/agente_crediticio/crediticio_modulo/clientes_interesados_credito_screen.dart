import 'package:flutter/material.dart';

import '../api_service_crediticio.dart';

class ClientesInteresadosCreditoScreen extends StatefulWidget {
  final int agenteId;

  const ClientesInteresadosCreditoScreen({
    super.key,
    required this.agenteId,
  });

  @override
  State<ClientesInteresadosCreditoScreen> createState() =>
      _ClientesInteresadosCreditoScreenState();
}

class _ClientesInteresadosCreditoScreenState
    extends State<ClientesInteresadosCreditoScreen> {
  late Future<List<dynamic>> _futureProspectos;

  final TextEditingController _busquedaController = TextEditingController();

  String _filtroInteres = 'todos';

  @override
  void initState() {
    super.initState();
    _cargarProspectos();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _cargarProspectos() {
    _futureProspectos = ApiServiceCrediticio.getProspectos(
      agenteId: widget.agenteId,
    );
  }

  Future<void> _refrescar() async {
    setState(() {
      _cargarProspectos();
    });

    await _futureProspectos;
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

  List<dynamic> _filtrarProspectos(List<dynamic> prospectos) {
    final buscar = _busquedaController.text.trim().toLowerCase();

    return prospectos.where((item) {
      if (item is! Map) return false;

      final prospecto = Map<String, dynamic>.from(item);

      final nombre = _texto(prospecto['nombre'], '').toLowerCase();
      final telefono = _texto(prospecto['telefono'], '').toLowerCase();
      final correo = _texto(prospecto['correo'], '').toLowerCase();
      final tipo = _texto(prospecto['tipo_credito'], '').toLowerCase();
      final mensaje = _texto(prospecto['mensaje'], '').toLowerCase();
      final interes = _texto(prospecto['nivel_interes'], '').toLowerCase();

      final coincideBusqueda = buscar.isEmpty ||
          nombre.contains(buscar) ||
          telefono.contains(buscar) ||
          correo.contains(buscar) ||
          tipo.contains(buscar) ||
          mensaje.contains(buscar);

      final coincideInteres =
          _filtroInteres == 'todos' || interes == _filtroInteres;

      return coincideBusqueda && coincideInteres;
    }).toList();
  }

  Color _interesColor(String interes) {
    switch (interes.toLowerCase()) {
      case 'alto':
        return const Color(0xFF15803D);
      case 'medio':
        return const Color(0xFFB7791F);
      case 'bajo':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF7C5E00);
    }
  }

  String _interesLegible(String interes) {
    switch (interes.toLowerCase()) {
      case 'alto':
        return 'Alto';
      case 'medio':
        return 'Medio';
      case 'bajo':
        return 'Bajo';
      default:
        return interes.isEmpty ? 'Sin nivel' : interes;
    }
  }

  String _estadoLegible(String estado) {
    switch (estado.toLowerCase()) {
      case 'nuevo':
        return 'Nuevo';
      case 'contactado':
        return 'Contactado';
      case 'en_seguimiento':
        return 'En seguimiento';
      case 'convertido':
        return 'Convertido';
      case 'descartado':
        return 'Descartado';
      default:
        return estado.isEmpty ? 'Sin estado' : estado;
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

  Future<void> _cambiarEstado(int id, String estado) async {
    try {
      await ApiServiceCrediticio.cambiarEstadoProspecto(
        prospectoId: id,
        estado: estado,
      );

      _mostrarMensaje('Estado actualizado');
      await _refrescar();
    } catch (e) {
      _mostrarMensaje('$e');
    }
  }

  Future<void> _cambiarInteres(int id, String interes) async {
    try {
      await ApiServiceCrediticio.cambiarInteresProspecto(
        prospectoId: id,
        nivelInteres: interes,
      );

      _mostrarMensaje('Nivel de interés actualizado');
      await _refrescar();
    } catch (e) {
      _mostrarMensaje('$e');
    }
  }

  Widget _chipFiltro({
    required String label,
    required String value,
  }) {
    final selected = _filtroInteres == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _filtroInteres = value;
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

  Widget _prospectoCard(Map<String, dynamic> prospecto) {
    final id = int.tryParse('${prospecto['id'] ?? 0}') ?? 0;

    final nombre = _texto(prospecto['nombre'], 'Cliente interesado');
    final telefono = _texto(prospecto['telefono'], 'Sin teléfono');
    final correo = _texto(prospecto['correo'], 'Sin correo');
    final tipoCredito = _texto(prospecto['tipo_credito'], 'Crédito');
    final monto = _money(prospecto['monto_aproximado']);
    final mensaje = _texto(prospecto['mensaje'], 'Sin mensaje');
    final nivelInteres = _texto(prospecto['nivel_interes'], 'medio');
    final estado = _texto(prospecto['estado'], 'nuevo');

    return Container(
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
                Icons.person_search_outlined,
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
                          nombre,
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
                          color: _interesColor(nivelInteres).withOpacity(.12),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          _interesLegible(nivelInteres),
                          style: TextStyle(
                            color: _interesColor(nivelInteres),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _infoLine(
                    icon: Icons.credit_card_outlined,
                    text: tipoCredito,
                  ),
                  const SizedBox(height: 5),
                  _infoLine(
                    icon: Icons.attach_money,
                    text: '\$$monto MXN',
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
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.black.withOpacity(.05),
                      ),
                    ),
                    child: Text(
                      mensaje,
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Estado: ${_estadoLegible(estado)}',
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: id > 0
                            ? () => _cambiarEstado(id, 'contactado')
                            : null,
                        child: const Text('Contactado'),
                      ),
                      OutlinedButton(
                        onPressed: id > 0
                            ? () => _cambiarEstado(id, 'en_seguimiento')
                            : null,
                        child: const Text('Seguimiento'),
                      ),
                      OutlinedButton(
                        onPressed: id > 0
                            ? () => _cambiarEstado(id, 'convertido')
                            : null,
                        child: const Text('Convertido'),
                      ),
                      OutlinedButton(
                        onPressed: id > 0
                            ? () => _cambiarInteres(id, 'alto')
                            : null,
                        child: const Text('Interés alto'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
                Icons.person_search_outlined,
                size: 46,
                color: Color(0xFF7C5E00),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aún no hay clientes interesados',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cuando un cliente muestre interés en un crédito, aparecerá aquí.',
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

  Widget _contenido() {
    return FutureBuilder<List<dynamic>>(
      future: _futureProspectos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFD4AF37),
            ),
          );
        }

        if (snapshot.hasError) {
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
                    'Error al cargar clientes interesados',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${snapshot.error}',
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

        final prospectos = snapshot.data ?? [];
        final filtrados = _filtrarProspectos(prospectos);

        if (prospectos.isEmpty) {
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
                            'Buscar por nombre, teléfono, correo, tipo o mensaje...',
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
                          _chipFiltro(label: 'Alto', value: 'alto'),
                          _chipFiltro(label: 'Medio', value: 'medio'),
                          _chipFiltro(label: 'Bajo', value: 'bajo'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${filtrados.length} clientes interesados',
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (filtrados.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'No hay clientes con esos filtros',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                ...filtrados.whereType<Map>().map((item) {
                  return _prospectoCard(
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
          'Clientes interesados',
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
                      'Prospectos crediticios',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Consulta clientes interesados y da seguimiento a oportunidades.',
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