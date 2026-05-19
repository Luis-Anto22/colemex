import 'package:flutter/material.dart';

import '../api_service_perito.dart';
import 'cadena_custodia_screen.dart';
import 'dictamenes_periciales_screen.dart';
import 'evidencias_criminalisticas_screen.dart';
import 'reporte_fotografico_screen.dart';

class DetalleCasoPeritoScreen extends StatefulWidget {
  final int peritoId;
  final int casoId;

  const DetalleCasoPeritoScreen({
    super.key,
    required this.peritoId,
    required this.casoId,
  });

  @override
  State<DetalleCasoPeritoScreen> createState() =>
      _DetalleCasoPeritoScreenState();
}

class _DetalleCasoPeritoScreenState extends State<DetalleCasoPeritoScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  void _cargarDetalle() {
    _future = ApiServicePerito.getDetalleCaso(
      casoId: widget.casoId,
    );
  }

  Future<void> _recargar() async {
    setState(_cargarDetalle);
    await _future;
  }

  String _texto(
    Map<String, dynamic> item,
    List<String> keys, {
    String defecto = '-',
  }) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return defecto;
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _cambiarEstado(String estado) async {
    try {
      await ApiServicePerito.cambiarEstadoCaso(
        casoId: widget.casoId,
        estado: estado,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estado actualizado correctamente'),
        ),
      );

      await _recargar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar estado: $e'),
        ),
      );
    }
  }

  Widget _actionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _detalleCard(Map<String, dynamic> caso) {
    final gold = Theme.of(context).primaryColor;

    final titulo = _texto(
      caso,
      [
        'titulo',
        'nombre_caso',
        'tipo_caso',
        'tipo_peritaje',
        'asunto',
      ],
      defecto: 'Caso pericial #${widget.casoId}',
    );

    final cliente = _texto(
      caso,
      [
        'cliente_nombre',
        'nombre_cliente',
        'cliente',
        'nombre',
      ],
    );

    final estado = _texto(
      caso,
      [
        'estado',
        'estado_caso',
        'estatus',
      ],
    );

    final prioridad = _texto(
      caso,
      [
        'prioridad',
        'nivel_prioridad',
      ],
    );

    final ubicacion = _texto(
      caso,
      [
        'ubicacion',
        'direccion',
        'lugar_hechos',
        'lugar',
      ],
    );

    final fecha = _texto(
      caso,
      [
        'fecha_asignacion',
        'fecha_registro',
        'created_at',
        'fecha',
      ],
    );

    final descripcion = _texto(
      caso,
      [
        'descripcion',
        'descripcion_caso',
        'observaciones',
        'detalles',
      ],
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: gold.withOpacity(.15),
                  child: Icon(
                    Icons.science_outlined,
                    color: gold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _info('Cliente', cliente),
            _info('Estado', estado),
            _info('Prioridad', prioridad),
            _info('Ubicación', ubicacion),
            _info('Fecha', fecha),
            _info('Descripción', descripcion),
          ],
        ),
      ),
    );
  }

  void _abrirEvidencias() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EvidenciasCriminalisticasScreen(
          peritoId: widget.peritoId,
          casoId: widget.casoId,
        ),
      ),
    );
  }

  void _abrirCadenaCustodia() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CadenaCustodiaScreen(
          peritoId: widget.peritoId,
          casoId: widget.casoId,
        ),
      ),
    );
  }

  void _abrirDictamenes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DictamenesPericialesScreen(
          peritoId: widget.peritoId,
          casoId: widget.casoId,
        ),
      ),
    );
  }

  void _abrirReporteFotografico() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReporteFotograficoScreen(
          peritoId: widget.peritoId,
          casoId: widget.casoId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del caso'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Cambiar estado',
            onSelected: _cambiarEstado,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'pendiente',
                child: Text('Pendiente'),
              ),
              PopupMenuItem(
                value: 'en_revision',
                child: Text('En revisión'),
              ),
              PopupMenuItem(
                value: 'en_inspeccion',
                child: Text('En inspección'),
              ),
              PopupMenuItem(
                value: 'dictamen_en_proceso',
                child: Text('Dictamen en proceso'),
              ),
              PopupMenuItem(
                value: 'cerrado',
                child: Text('Cerrado'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _recargar,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 52,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Error al cargar detalle:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            final caso = snapshot.data ?? {};

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _detalleCard(caso),
                const SizedBox(height: 16),

                const Text(
                  'Herramientas del caso',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),

                _actionButton(
                  icon: Icons.camera_alt_outlined,
                  text: 'Evidencias criminalísticas',
                  onTap: _abrirEvidencias,
                ),
                _actionButton(
                  icon: Icons.account_tree_outlined,
                  text: 'Cadena de custodia',
                  onTap: _abrirCadenaCustodia,
                ),
                _actionButton(
                  icon: Icons.description_outlined,
                  text: 'Dictámenes periciales',
                  onTap: _abrirDictamenes,
                ),
                _actionButton(
                  icon: Icons.photo_library_outlined,
                  text: 'Reporte fotográfico',
                  onTap: _abrirReporteFotografico,
                ),

                const SizedBox(height: 12),
                const Text(
                  'Puedes cambiar el estado del caso desde el menú superior derecho.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}