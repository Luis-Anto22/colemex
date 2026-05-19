import 'package:flutter/material.dart';

import 'api_service_inmobiliario.dart';

class ClientesInteresadosScreen extends StatefulWidget {
  final int agenteId;

  const ClientesInteresadosScreen({
    super.key,
    required this.agenteId,
  });

  @override
  State<ClientesInteresadosScreen> createState() =>
      _ClientesInteresadosScreenState();
}

class _ClientesInteresadosScreenState extends State<ClientesInteresadosScreen> {
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
    _futureProspectos = ApiServiceInmobiliario.getProspectos(
      agenteId: widget.agenteId,
    );
  }

  Future<void> _refrescar() async {
    setState(() {
      _cargarProspectos();
    });

    await _futureProspectos;
  }

  String _texto(dynamic valor, [String fallback = 'No especificado']) {
    final text = '${valor ?? ''}'.trim();

    if (text.isEmpty || text == 'null') {
      return fallback;
    }

    return text;
  }

  String _mensajeProspecto(Map<String, dynamic> prospecto) {
    return _texto(
      prospecto['mensaje'] ?? prospecto['comentarios'],
      'Sin comentarios',
    );
  }

  List<dynamic> _filtrarProspectos(List<dynamic> prospectos) {
    final busqueda = _busquedaController.text.trim().toLowerCase();

    return prospectos.where((item) {
      if (item is! Map) return false;

      final prospecto = Map<String, dynamic>.from(item);

      final nombre = _texto(prospecto['nombre'], '').toLowerCase();
      final telefono = _texto(prospecto['telefono'], '').toLowerCase();
      final correo = _texto(prospecto['correo'], '').toLowerCase();
      final interes = _texto(prospecto['nivel_interes'], '').toLowerCase();
      final mensaje = _mensajeProspecto(prospecto).toLowerCase();

      final inmueble = _texto(
        prospecto['inmueble'] ??
            prospecto['titulo_inmueble'] ??
            prospecto['propiedad'],
        '',
      ).toLowerCase();

      final ubicacion = _texto(
        prospecto['ubicacion_inmueble'] ?? prospecto['ubicacion'],
        '',
      ).toLowerCase();

      final coincideBusqueda = busqueda.isEmpty ||
          nombre.contains(busqueda) ||
          telefono.contains(busqueda) ||
          correo.contains(busqueda) ||
          mensaje.contains(busqueda) ||
          inmueble.contains(busqueda) ||
          ubicacion.contains(busqueda);

      final coincideInteres =
          _filtroInteres == 'todos' || interes == _filtroInteres;

      return coincideBusqueda && coincideInteres;
    }).toList();
  }

  Color _interesColor(String interes) {
    switch (interes.toLowerCase()) {
      case 'alto':
        return const Color(0xFF1B8F5A);
      case 'medio':
        return const Color(0xFFB7791F);
      case 'bajo':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF7C2D12);
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
      case 'visita_agendada':
        return 'Visita agendada';
      case 'descartado':
        return 'Descartado';
      case 'cerrado':
        return 'Cerrado';
      default:
        return estado.isEmpty ? 'Sin estado' : estado;
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
      selectedColor: const Color(0xFF7C2D12).withOpacity(.15),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected
            ? const Color(0xFF7C2D12).withOpacity(.45)
            : Colors.black.withOpacity(.08),
      ),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF7C2D12) : const Color(0xFF374151),
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _prospectoCard(Map<String, dynamic> prospecto) {
    final nombre = _texto(prospecto['nombre'], 'Cliente interesado');
    final telefono = _texto(prospecto['telefono'], 'Sin teléfono');
    final correo = _texto(prospecto['correo'], 'Sin correo');
    final nivelInteres = _texto(prospecto['nivel_interes'], 'Sin nivel');
    final mensaje = _mensajeProspecto(prospecto);
    final estado = _estadoLegible(_texto(prospecto['estado'], ''));

    final inmueble = _texto(
      prospecto['inmueble'] ??
          prospecto['titulo_inmueble'] ??
          prospecto['propiedad'],
      'Propiedad no especificada',
    );

    final ubicacion = _texto(
      prospecto['ubicacion_inmueble'] ?? prospecto['ubicacion'],
      '',
    );

    final precio = _texto(
      prospecto['precio_inmueble'] ?? prospecto['precio'],
      '',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.96),
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
                color: const Color(0xFF7C2D12).withOpacity(.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person_search_outlined,
                color: Color(0xFF7C2D12),
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
                    icon: Icons.home_work_outlined,
                    text: inmueble,
                  ),
                  if (ubicacion.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    _infoLine(
                      icon: Icons.location_on_outlined,
                      text: ubicacion,
                    ),
                  ],
                  if (precio.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    _infoLine(
                      icon: Icons.attach_money,
                      text: '\$$precio MXN',
                    ),
                  ],
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: Colors.black.withOpacity(.05),
                          ),
                        ),
                        child: Text(
                          'Estado: $estado',
                          style: const TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                ],
              ),
            ),
          ],
        ),
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
                color: const Color(0xFF7C2D12).withOpacity(.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search_outlined,
                size: 46,
                color: Color(0xFF7C2D12),
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
              'Cuando un cliente muestre interés en una propiedad, aparecerá aquí para darle seguimiento.',
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
              color: Color(0xFF7C2D12),
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
          color: const Color(0xFF7C2D12),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.96),
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
                            'Buscar por nombre, teléfono, correo, propiedad o mensaje...',
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
        backgroundColor: const Color(0xFF7C2D12),
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
                  color: Color(0xFF7C2D12),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prospectos inmobiliarios',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Consulta clientes interesados y da seguimiento a tus oportunidades.',
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