import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ✅ Como este archivo debe estar en la misma carpeta:
// lib/screens/agente_inmobiliario/pantalla_propiedades.dart
// lib/screens/agente_inmobiliario/api_service_inmobiliario.dart
// este import relativo evita el error de URI.
import 'api_service_inmobiliario.dart';

class PantallaPropiedades extends StatefulWidget {
  final int agenteId;

  const PantallaPropiedades({
    super.key,
    required this.agenteId,
  });

  @override
  State<PantallaPropiedades> createState() => _PantallaPropiedadesState();
}

class _PantallaPropiedadesState extends State<PantallaPropiedades> {
  late Future<List<dynamic>> _futureInmuebles;

  final TextEditingController _busquedaController = TextEditingController();

  String _filtroEstado = 'todos';
  String _filtroOperacion = 'todos';

  @override
  void initState() {
    super.initState();
    _cargarInmuebles();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _cargarInmuebles() {
    _futureInmuebles = ApiServiceInmobiliario.getInmuebles(
      agenteId: widget.agenteId,
    );
  }

  Future<void> _refrescar() async {
    setState(() {
      _cargarInmuebles();
    });
    await _futureInmuebles;
  }

  List<dynamic> _filtrarInmuebles(List<dynamic> inmuebles) {
    final busqueda = _busquedaController.text.trim().toLowerCase();

    return inmuebles.where((item) {
      if (item is! Map) return false;

      final inmueble = Map<String, dynamic>.from(item);

      final titulo = '${inmueble['titulo'] ?? ''}'.toLowerCase();
      final ubicacion = '${inmueble['ubicacion'] ?? ''}'.toLowerCase();
      final descripcion = '${inmueble['descripcion'] ?? ''}'.toLowerCase();
      final estado = '${inmueble['estado'] ?? ''}'.toLowerCase();
      final operacion = '${inmueble['tipo_operacion'] ?? ''}'.toLowerCase();

      final coincideBusqueda = busqueda.isEmpty ||
          titulo.contains(busqueda) ||
          ubicacion.contains(busqueda) ||
          descripcion.contains(busqueda);

      final coincideEstado = _filtroEstado == 'todos' ||
          estado == _filtroEstado.toLowerCase();

      final coincideOperacion = _filtroOperacion == 'todos' ||
          operacion == _filtroOperacion.toLowerCase();

      return coincideBusqueda && coincideEstado && coincideOperacion;
    }).toList();
  }

  String _moneda(dynamic valor) {
    final double numero = double.tryParse('$valor') ?? 0;
    return '\$${numero.toStringAsFixed(2)} MXN';
  }

  String _texto(dynamic valor, [String fallback = 'No especificado']) {
    final text = '${valor ?? ''}'.trim();
    if (text.isEmpty || text == 'null') return fallback;
    return text;
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'disponible':
        return const Color(0xFF1B8F5A);
      case 'en_proceso':
      case 'en proceso':
        return const Color(0xFFB7791F);
      case 'vendido':
        return const Color(0xFFB91C1C);
      case 'rentado':
        return const Color(0xFF4C1D95);
      default:
        return const Color(0xFF4B5563);
    }
  }

  String _estadoLegible(String estado) {
    switch (estado.toLowerCase()) {
      case 'disponible':
        return 'Disponible';
      case 'en_proceso':
        return 'En proceso';
      case 'vendido':
        return 'Vendido';
      case 'rentado':
        return 'Rentado';
      default:
        return estado.isEmpty ? 'Sin estado' : estado;
    }
  }

  String _operacionLegible(String operacion) {
    switch (operacion.toLowerCase()) {
      case 'venta':
        return 'Venta';
      case 'renta':
        return 'Renta';
      default:
        return operacion.isEmpty ? 'Operación' : operacion;
    }
  }

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      _mostrarSnack('URL inválida');
      return;
    }

    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!ok) {
      _mostrarSnack('No se pudo abrir el archivo');
    }
  }

  void _mostrarSnack(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _confirmar({
    required String titulo,
    required String mensaje,
    String textoAceptar = 'Aceptar',
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(textoAceptar),
            ),
          ],
        );
      },
    );

    return res == true;
  }

  Future<void> _eliminarInmueble(Map<String, dynamic> inmueble) async {
    final id = int.tryParse('${inmueble['id']}');

    if (id == null) {
      _mostrarSnack('No se encontró el ID del inmueble');
      return;
    }

    final confirmar = await _confirmar(
      titulo: 'Eliminar propiedad',
      mensaje: '¿Seguro que quieres eliminar esta propiedad?',
      textoAceptar: 'Eliminar',
    );

    if (!confirmar) return;

    try {
      await ApiServiceInmobiliario.eliminarInmueble(inmuebleId: id);

      _mostrarSnack('Propiedad eliminada correctamente');
      await _refrescar();
    } catch (e) {
      _mostrarSnack('Error al eliminar: $e');
    }
  }

  Future<void> _cambiarEstado(
    Map<String, dynamic> inmueble,
    String estado,
  ) async {
    final id = int.tryParse('${inmueble['id']}');

    if (id == null) {
      _mostrarSnack('No se encontró el ID del inmueble');
      return;
    }

    try {
      await ApiServiceInmobiliario.actualizarEstadoInmueble(
        inmuebleId: id,
        agenteId: widget.agenteId,
        estado: estado,
      );

      _mostrarSnack('Estado actualizado');
      await _refrescar();
    } catch (e) {
      _mostrarSnack('Error al actualizar estado: $e');
    }
  }

  Future<void> _abrirFormulario({Map<String, dynamic>? inmueble}) async {
    final bool editando = inmueble != null;

    final tituloController = TextEditingController(
      text: editando ? _texto(inmueble['titulo'], '') : '',
    );

    final ubicacionController = TextEditingController(
      text: editando ? _texto(inmueble['ubicacion'], '') : '',
    );

    final precioController = TextEditingController(
      text: editando ? _texto(inmueble['precio'], '') : '',
    );

    final descripcionController = TextEditingController(
      text: editando ? _texto(inmueble['descripcion'], '') : '',
    );

    final habitacionesController = TextEditingController(
      text: editando ? _texto(inmueble['habitaciones'], '') : '',
    );

    final banosController = TextEditingController(
      text: editando ? _texto(inmueble['banos'] ?? inmueble['baños'], '') : '',
    );

    final superficieController = TextEditingController(
      text: editando ? _texto(inmueble['superficie'], '') : '',
    );

    final estacionamientosController = TextEditingController(
      text: editando ? _texto(inmueble['estacionamientos'], '') : '',
    );

    String tipoInmueble = editando
        ? _texto(inmueble['tipo_inmueble'], 'departamento')
        : 'departamento';

    String tipoOperacion = editando
        ? _texto(inmueble['tipo_operacion'], 'venta')
        : 'venta';

    String estado = editando
        ? _texto(inmueble['estado'], 'disponible')
        : 'disponible';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> guardar() async {
              final titulo = tituloController.text.trim();
              final ubicacion = ubicacionController.text.trim();
              final precio = double.tryParse(
                    precioController.text.trim().replaceAll(',', ''),
                  ) ??
                  0;

              if (titulo.isEmpty) {
                _mostrarSnack('Escribe el título de la propiedad');
                return;
              }

              if (ubicacion.isEmpty) {
                _mostrarSnack('Escribe la ubicación');
                return;
              }

              if (precio <= 0) {
                _mostrarSnack('Escribe un precio válido');
                return;
              }

              final habitaciones = habitacionesController.text.trim();
              final banos = banosController.text.trim();
              final superficie = superficieController.text.trim();
              final estacionamientos = estacionamientosController.text.trim();
              final descripcionBase = descripcionController.text.trim();

              final descripcionCompleta = '''
$descripcionBase

--- Detalles de la propiedad ---
Habitaciones: ${habitaciones.isEmpty ? 'No especificado' : habitaciones}
Baños: ${banos.isEmpty ? 'No especificado' : banos}
Superficie: ${superficie.isEmpty ? 'No especificado' : superficie}
Estacionamientos: ${estacionamientos.isEmpty ? 'No especificado' : estacionamientos}
''';

              try {
                if (editando) {
                  final id = int.tryParse('${inmueble['id']}');

                  if (id == null) {
                    _mostrarSnack('No se encontró el ID del inmueble');
                    return;
                  }

                  await ApiServiceInmobiliario.actualizarInmueble(
                    inmuebleId: id,
                    agenteId: widget.agenteId,
                    titulo: titulo,
                    tipoInmueble: tipoInmueble,
                    tipoOperacion: tipoOperacion,
                    ubicacion: ubicacion,
                    precio: precio,
                    descripcion: descripcionCompleta,
                    estado: estado,
                  );

                  _mostrarSnack('Propiedad actualizada');
                } else {
                  await ApiServiceInmobiliario.registrarInmueble(
                    agenteId: widget.agenteId,
                    titulo: titulo,
                    tipoInmueble: tipoInmueble,
                    tipoOperacion: tipoOperacion,
                    ubicacion: ubicacion,
                    precio: precio,
                    descripcion: descripcionCompleta,
                    estado: estado,
                  );

                  _mostrarSnack('Propiedad registrada');
                }

                if (mounted) {
                  Navigator.pop(context);
                }

                await _refrescar();
              } catch (e) {
                _mostrarSnack('Error al guardar: $e');
              }
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.92,
              minChildSize: 0.55,
              maxChildSize: 0.96,
              builder: (_, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.only(
                            left: 18,
                            right: 18,
                            top: 18,
                            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                          ),
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7C2D12).withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.apartment_rounded,
                                    color: Color(0xFF7C2D12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    editando ? 'Editar propiedad' : 'Registrar propiedad',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            _campoTexto(
                              controller: tituloController,
                              label: 'Título comercial',
                              icon: Icons.title_rounded,
                              hint: 'Ej. Departamento moderno en renta',
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _dropdown(
                                    label: 'Tipo',
                                    icon: Icons.home_work_rounded,
                                    value: tipoInmueble,
                                    items: const {
                                      'departamento': 'Departamento',
                                      'casa': 'Casa',
                                      'terreno': 'Terreno',
                                      'local': 'Local',
                                      'oficina': 'Oficina',
                                      'bodega': 'Bodega',
                                    },
                                    onChanged: (value) {
                                      setModalState(() {
                                        tipoInmueble = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _dropdown(
                                    label: 'Operación',
                                    icon: Icons.swap_horiz_rounded,
                                    value: tipoOperacion,
                                    items: const {
                                      'venta': 'Venta',
                                      'renta': 'Renta',
                                    },
                                    onChanged: (value) {
                                      setModalState(() {
                                        tipoOperacion = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            _campoTexto(
                              controller: ubicacionController,
                              label: 'Ubicación',
                              icon: Icons.location_on_rounded,
                              hint: 'Colonia, municipio, estado',
                            ),
                            const SizedBox(height: 12),

                            _campoTexto(
                              controller: precioController,
                              label: 'Precio',
                              icon: Icons.attach_money_rounded,
                              keyboardType: TextInputType.number,
                              hint: 'Ej. 850000',
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _campoTexto(
                                    controller: habitacionesController,
                                    label: 'Cuartos',
                                    icon: Icons.bed_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _campoTexto(
                                    controller: banosController,
                                    label: 'Baños',
                                    icon: Icons.bathtub_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _campoTexto(
                                    controller: superficieController,
                                    label: 'Superficie',
                                    icon: Icons.square_foot_rounded,
                                    hint: 'Ej. 120 m²',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _campoTexto(
                                    controller: estacionamientosController,
                                    label: 'Estac.',
                                    icon: Icons.local_parking_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            _dropdown(
                              label: 'Estado de la propiedad',
                              icon: Icons.verified_rounded,
                              value: estado,
                              items: const {
                                'disponible': 'Disponible',
                                'en_proceso': 'En proceso',
                                'vendido': 'Vendido',
                                'rentado': 'Rentado',
                              },
                              onChanged: (value) {
                                setModalState(() {
                                  estado = value;
                                });
                              },
                            ),
                            const SizedBox(height: 12),

                            _campoTexto(
                              controller: descripcionController,
                              label: 'Descripción para clientes',
                              icon: Icons.description_rounded,
                              maxLines: 5,
                              hint: 'Describe beneficios, ubicación, servicios cercanos, seguridad, etc.',
                            ),
                            const SizedBox(height: 20),

                            SizedBox(
                              height: 52,
                              child: FilledButton.icon(
                                onPressed: guardar,
                                icon: const Icon(Icons.save_rounded),
                                label: Text(
                                  editando ? 'Guardar cambios' : 'Registrar propiedad',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF7C2D12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    tituloController.dispose();
    ubicacionController.dispose();
    precioController.dispose();
    descripcionController.dispose();
    habitacionesController.dispose();
    banosController.dispose();
    superficieController.dispose();
    estacionamientosController.dispose();
  }

  Future<void> _abrirArchivos(Map<String, dynamic> inmueble) async {
    final inmuebleId = int.tryParse('${inmueble['id']}');

    if (inmuebleId == null) {
      _mostrarSnack('No se encontró el ID del inmueble');
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _ArchivosInmuebleSheet(
          inmuebleId: inmuebleId,
          agenteId: widget.agenteId,
          tituloInmueble: _texto(inmueble['titulo'], 'Propiedad'),
          onSnack: _mostrarSnack,
          abrirUrl: _abrirUrl,
        );
      },
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF7C2D12),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
  }) {
    final safeValue = items.containsKey(value) ? value : items.keys.first;

    return DropdownButtonFormField<String>(
      // ✅ Se usa value en vez de initialValue para evitar errores en versiones Flutter donde initialValue no existe.
      value: safeValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.08),
          ),
        ),
      ),
      items: items.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }

  Widget _chipFiltro({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF7C2D12).withOpacity(0.15),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? const Color(0xFF7C2D12) : const Color(0xFF374151),
      ),
      side: BorderSide(
        color: selected
            ? const Color(0xFF7C2D12).withOpacity(0.4)
            : Colors.black.withOpacity(0.08),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _resumenItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 0, color: Colors.transparent),
          Icon(icon, size: 17, color: const Color(0xFF7C2D12)),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }


  int _entero(dynamic valor) {
    return int.tryParse('${valor ?? 0}') ?? 0;
  }

  double _decimal(dynamic valor) {
    return double.tryParse('${valor ?? 0}') ?? 0.0;
  }

  Future<void> _abrirCalificaciones(Map<String, dynamic> inmueble) async {
    final inmuebleId = int.tryParse('${inmueble['id']}');

    if (inmuebleId == null) {
      _mostrarSnack('No se encontró el ID del inmueble');
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.76,
          minChildSize: 0.45,
          maxChildSize: 0.94,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: FutureBuilder<List<dynamic>>(
                future: ApiServiceInmobiliario.getCalificacionesInmueble(
                  inmuebleId: inmuebleId,
                ),
                builder: (context, snapshot) {
                  final promedio = _decimal(inmueble['calificacion_promedio']);
                  final total = _entero(inmueble['total_calificaciones']);

                  return ListView(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C2D12).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.reviews_rounded,
                              color: Color(0xFF7C2D12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Opiniones de clientes',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _texto(inmueble['titulo'], 'Propiedad'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.06),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFF59E0B),
                              size: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${promedio.toStringAsFixed(1)} / 5',
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$total opiniones',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF7C2D12),
                            ),
                          ),
                        )
                      else if (snapshot.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text(
                              'Error al cargar opiniones: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFB91C1C),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        )
                      else if ((snapshot.data ?? []).isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text(
                              'Esta propiedad aún no tiene opiniones.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                      else
                        ...(snapshot.data ?? []).whereType<Map>().map((item) {
                          final cal = Map<String, dynamic>.from(item);

                          final estrellas = _entero(cal['calificacion']);
                          final comentario = _texto(cal['comentario'], '');
                          final fecha = _texto(
                            cal['created_at'] ?? cal['fecha'] ?? cal['fecha_registro'],
                            '',
                          );
                          final cliente = _texto(
                            cal['cliente'] is Map
                                ? cal['cliente']['nombre']
                                : cal['cliente_nombre'],
                            'Cliente',
                          );

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.06),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Color(0xFFFFEDD5),
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: Color(0xFF7C2D12),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cliente,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                          if (fecha.isNotEmpty)
                                            Text(
                                              fecha,
                                              style: const TextStyle(
                                                color: Color(0xFF6B7280),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < estrellas
                                              ? Icons.star_rounded
                                              : Icons.star_border_rounded,
                                          color: const Color(0xFFF59E0B),
                                          size: 18,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                if (comentario.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    comentario,
                                    style: const TextStyle(
                                      color: Color(0xFF475569),
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _propiedadCard(Map<String, dynamic> inmueble) {
    final titulo = _texto(inmueble['titulo'], 'Propiedad sin título');
    final ubicacion = _texto(inmueble['ubicacion'], 'Sin ubicación');
    final precio = _moneda(inmueble['precio']);
    final estado = _texto(inmueble['estado'], 'disponible');
    final operacion = _texto(inmueble['tipo_operacion'], 'venta');
    final tipo = _texto(inmueble['tipo_inmueble'], 'Propiedad');

    final habitaciones = _texto(inmueble['habitaciones'], '-');
    final banos = _texto(inmueble['banos'] ?? inmueble['baños'], '-');
    final superficie = _texto(inmueble['superficie'], '-');

    final calificacionPromedio = _decimal(inmueble['calificacion_promedio']);
    final totalCalificaciones = _entero(inmueble['total_calificaciones']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _abrirArchivos(inmueble),
        child: Column(
          children: [
            Container(
              height: 135,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF7C2D12),
                    Color(0xFF111827),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -22,
                    bottom: -30,
                    child: Icon(
                      Icons.apartment_rounded,
                      color: Colors.white.withOpacity(0.12),
                      size: 150,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.22),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.sell_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _operacionLegible(operacion),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _estadoColor(estado),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        _estadoLegible(estado),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      precio,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 17,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ubicacion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _resumenItem(
                        icon: Icons.home_work_rounded,
                        label: 'Tipo',
                        value: tipo,
                      ),
                      _resumenItem(
                        icon: Icons.bed_rounded,
                        label: 'Cuartos',
                        value: habitaciones,
                      ),
                      _resumenItem(
                        icon: Icons.bathtub_rounded,
                        label: 'Baños',
                        value: banos,
                      ),
                      _resumenItem(
                        icon: Icons.square_foot_rounded,
                        label: 'Sup.',
                        value: superficie,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${calificacionPromedio.toStringAsFixed(1)} ($totalCalificaciones)',
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _abrirCalificaciones(inmueble),
                        icon: const Icon(Icons.reviews_rounded, size: 18),
                        label: const Text('Opiniones'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF7C2D12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _abrirArchivos(inmueble),
                          icon: const Icon(Icons.photo_library_rounded),
                          label: const Text('Fotos/docs'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF7C2D12),
                            side: BorderSide(
                              color: const Color(0xFF7C2D12).withOpacity(0.28),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'editar') {
                            _abrirFormulario(inmueble: inmueble);
                          } else if (value == 'eliminar') {
                            _eliminarInmueble(inmueble);
                          } else {
                            _cambiarEstado(inmueble, value);
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'editar',
                            child: Text('Editar propiedad'),
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'disponible',
                            child: Text('Marcar disponible'),
                          ),
                          PopupMenuItem(
                            value: 'en_proceso',
                            child: Text('Marcar en proceso'),
                          ),
                          PopupMenuItem(
                            value: 'vendido',
                            child: Text('Marcar vendido'),
                          ),
                          PopupMenuItem(
                            value: 'rentado',
                            child: Text('Marcar rentado'),
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'eliminar',
                            child: Text('Eliminar'),
                          ),
                        ],
                        child: Container(
                          height: 42,
                          width: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.more_vert_rounded),
                        ),
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
                color: const Color(0xFF7C2D12).withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.apartment_rounded,
                size: 46,
                color: Color(0xFF7C2D12),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aún no hay propiedades',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Registra casas, departamentos o locales para mostrarlos después en el portal de clientes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Registrar propiedad'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C2D12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    return FutureBuilder<List<dynamic>>(
      future: _futureInmuebles,
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
                    'Error al cargar propiedades',
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

        final inmuebles = snapshot.data ?? [];
        final filtrados = _filtrarInmuebles(inmuebles);

        if (inmuebles.isEmpty) {
          return _estadoVacio();
        }

        return RefreshIndicator(
          onRefresh: _refrescar,
          color: const Color(0xFF7C2D12),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.06),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _busquedaController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar por título, ubicación o descripción...',
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
                          _chipFiltro(
                            label: 'Todos',
                            selected: _filtroEstado == 'todos',
                            onTap: () => setState(() => _filtroEstado = 'todos'),
                          ),
                          _chipFiltro(
                            label: 'Disponible',
                            selected: _filtroEstado == 'disponible',
                            onTap: () => setState(() => _filtroEstado = 'disponible'),
                          ),
                          _chipFiltro(
                            label: 'En proceso',
                            selected: _filtroEstado == 'en_proceso',
                            onTap: () => setState(() => _filtroEstado = 'en_proceso'),
                          ),
                          _chipFiltro(
                            label: 'Vendido',
                            selected: _filtroEstado == 'vendido',
                            onTap: () => setState(() => _filtroEstado = 'vendido'),
                          ),
                          _chipFiltro(
                            label: 'Rentado',
                            selected: _filtroEstado == 'rentado',
                            onTap: () => setState(() => _filtroEstado = 'rentado'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chipFiltro(
                            label: 'Venta y renta',
                            selected: _filtroOperacion == 'todos',
                            onTap: () => setState(() => _filtroOperacion = 'todos'),
                          ),
                          _chipFiltro(
                            label: 'Venta',
                            selected: _filtroOperacion == 'venta',
                            onTap: () => setState(() => _filtroOperacion = 'venta'),
                          ),
                          _chipFiltro(
                            label: 'Renta',
                            selected: _filtroOperacion == 'renta',
                            onTap: () => setState(() => _filtroOperacion = 'renta'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${filtrados.length} propiedades encontradas',
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
                      'No hay propiedades con esos filtros',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                ...filtrados.map((item) {
                  return _propiedadCard(
                    Map<String, dynamic>.from(item as Map),
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
        elevation: 0,
        backgroundColor: const Color(0xFF7C2D12),
        foregroundColor: Colors.white,
        title: const Text(
          'Propiedades',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: const Color(0xFF7C2D12),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nueva propiedad',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.045,
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
                      'Catálogo inmobiliario',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Administra las propiedades que después podrán ver los clientes.',
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

class _ArchivosInmuebleSheet extends StatefulWidget {
  final int inmuebleId;
  final int agenteId;
  final String tituloInmueble;
  final void Function(String mensaje) onSnack;
  final Future<void> Function(String url) abrirUrl;

  const _ArchivosInmuebleSheet({
    required this.inmuebleId,
    required this.agenteId,
    required this.tituloInmueble,
    required this.onSnack,
    required this.abrirUrl,
  });

  @override
  State<_ArchivosInmuebleSheet> createState() => _ArchivosInmuebleSheetState();
}

class _ArchivosInmuebleSheetState extends State<_ArchivosInmuebleSheet> {
  late Future<List<dynamic>> _futureArchivos;

  String _categoria = 'foto';
  bool _subiendo = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _futureArchivos = ApiServiceInmobiliario.getArchivosInmueble(
      inmuebleId: widget.inmuebleId,
      agenteId: widget.agenteId,
      categoria: _categoria,
    );
  }

  Future<void> _refrescar() async {
    setState(() {
      _cargar();
    });
    await _futureArchivos;
  }

  bool _esImagen(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  Future<void> _subirArchivo() async {
    try {
      setState(() {
        _subiendo = true;
      });

      final result = await FilePicker.platform.pickFiles(
        withData: true,
        type: _categoria == 'foto' ? FileType.image : FileType.custom,
        allowedExtensions: _categoria == 'foto'
            ? null
            : ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'webp'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _subiendo = false;
        });
        return;
      }

      final file = result.files.first;

      await ApiServiceInmobiliario.subirArchivoInmueble(
        inmuebleId: widget.inmuebleId,
        agenteId: widget.agenteId,
        file: file,
        categoria: _categoria,
        tipo: _categoria == 'foto' ? 'galeria' : 'documento_propiedad',
        descripcion: _categoria == 'foto'
            ? 'Foto de la propiedad'
            : 'Documento de la propiedad',
      );

      widget.onSnack(
        _categoria == 'foto'
            ? 'Foto subida correctamente'
            : 'Documento subido correctamente',
      );

      await _refrescar();
    } catch (e) {
      widget.onSnack('Error al subir archivo: $e');
    } finally {
      if (mounted) {
        setState(() {
          _subiendo = false;
        });
      }
    }
  }

  Future<void> _eliminarArchivo(Map<String, dynamic> archivo) async {
    final id = int.tryParse('${archivo['id']}');

    if (id == null) {
      widget.onSnack('No se encontró el ID del archivo');
      return;
    }

    try {
      await ApiServiceInmobiliario.eliminarArchivoInmueble(
        archivoId: id,
      );

      widget.onSnack('Archivo eliminado');
      await _refrescar();
    } catch (e) {
      widget.onSnack('Error al eliminar archivo: $e');
    }
  }

  Widget _archivoCard(Map<String, dynamic> archivo) {
    final url = '${archivo['archivo_url'] ?? ''}';
    final descripcion = '${archivo['descripcion'] ?? ''}'.trim();
    final tipo = '${archivo['tipo'] ?? 'general'}'.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(0.06),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: url.isEmpty ? null : () => widget.abrirUrl(url),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: url.isNotEmpty && _esImagen(url)
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.broken_image_rounded,
                            color: Color(0xFF6B7280),
                          );
                        },
                      )
                    : Icon(
                        _categoria == 'foto'
                            ? Icons.image_rounded
                            : Icons.description_rounded,
                        color: const Color(0xFF7C2D12),
                        size: 34,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      descripcion.isEmpty
                          ? (_categoria == 'foto'
                              ? 'Foto del inmueble'
                              : 'Documento del inmueble')
                          : descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tipo,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tocar para abrir',
                      style: TextStyle(
                        color: Color(0xFF7C2D12),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'abrir' && url.isNotEmpty) {
                    widget.abrirUrl(url);
                  }

                  if (value == 'eliminar') {
                    _eliminarArchivo(archivo);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'abrir',
                    child: Text('Abrir'),
                  ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: Text('Eliminar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoriaChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final selected = _categoria == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _categoria = value;
            _cargar();
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF7C2D12) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7C2D12)
                  : Colors.black.withOpacity(0.08),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : const Color(0xFF7C2D12),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF111827),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listaArchivos() {
    return FutureBuilder<List<dynamic>>(
      future: _futureArchivos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7C2D12),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Text(
                  'Error al cargar archivos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }

        final archivos = snapshot.data ?? [];

        if (archivos.isEmpty) {
          return Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _categoria == 'foto'
                          ? Icons.photo_library_rounded
                          : Icons.folder_open_rounded,
                      size: 54,
                      color: const Color(0xFF7C2D12),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _categoria == 'foto'
                          ? 'Aún no hay fotos'
                          : 'Aún no hay documentos',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _categoria == 'foto'
                          ? 'Sube fotos para que los clientes conozcan la propiedad.'
                          : 'Sube contratos, escrituras, planos o documentos importantes.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Expanded(
          child: RefreshIndicator(
            onRefresh: _refrescar,
            color: const Color(0xFF7C2D12),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: archivos.length,
              itemBuilder: (_, index) {
                final item = archivos[index];
                if (item is! Map) {
                  return const SizedBox.shrink();
                }
                return _archivoCard(
                  Map<String, dynamic>.from(item),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C2D12).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.folder_rounded,
                        color: Color(0xFF7C2D12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.tituloInmueble,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _categoriaChip(
                      label: 'Fotos',
                      value: 'foto',
                      icon: Icons.photo_library_rounded,
                    ),
                    const SizedBox(width: 10),
                    _categoriaChip(
                      label: 'Documentos',
                      value: 'documento',
                      icon: Icons.description_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _listaArchivos(),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _subiendo ? null : _subirArchivo,
                        icon: _subiendo
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _categoria == 'foto'
                                    ? Icons.add_photo_alternate_rounded
                                    : Icons.upload_file_rounded,
                              ),
                        label: Text(
                          _subiendo
                              ? 'Subiendo...'
                              : (_categoria == 'foto'
                                  ? 'Subir foto'
                                  : 'Subir documento'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF7C2D12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
