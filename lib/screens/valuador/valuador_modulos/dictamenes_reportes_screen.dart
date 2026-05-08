import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:advocatus/services/api_services/api_client.dart';
import 'package:advocatus/services/api_services/valuador_api.dart';

class DictamenesReportesScreen extends StatefulWidget {
  final int valuadorId;

  const DictamenesReportesScreen({
    super.key,
    required this.valuadorId,
  });

  @override
  State<DictamenesReportesScreen> createState() =>
      _DictamenesReportesScreenState();
}

class _DictamenesReportesScreenState extends State<DictamenesReportesScreen> {
  late final ValuadorApi api;

  final TextEditingController descripcionController = TextEditingController();

  bool cargando = false;
  bool subiendo = false;

  int? casoSeleccionadoId;
  Map<String, dynamic>? casoSeleccionado;

  List<dynamic> casos = [];
  List<dynamic> reportes = [];

  PlatformFile? archivoSeleccionado;
  String? nombreArchivo;

  @override
  void initState() {
    super.initState();
    api = ValuadorApi(ApiClient());
    cargarCasos();
  }

  @override
  void dispose() {
    descripcionController.dispose();
    super.dispose();
  }

  Future<void> cargarCasos() async {
    setState(() => cargando = true);

    try {
      final data = await api.getAvaluos(widget.valuadorId);

      if (!mounted) return;

      setState(() {
        casos = data;
      });

      if (casos.isNotEmpty) {
        final primerCaso = Map<String, dynamic>.from(casos.first as Map);
        final id = primerCaso['caso_id'] ?? primerCaso['id'];

        casoSeleccionado = primerCaso;
        casoSeleccionadoId = int.tryParse(id.toString());

        if (casoSeleccionadoId != null) {
          await cargarReportes();
        }
      }
    } catch (e) {
      mostrarMensaje('Error al cargar casos: $e', esError: true);
    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  Future<void> cargarReportes() async {
    if (casoSeleccionadoId == null) return;

    setState(() => cargando = true);

    try {
      final data = await api.getReportes(casoSeleccionadoId!);

      if (!mounted) return;

      setState(() {
        reportes = data;
      });
    } catch (e) {
      mostrarMensaje('Error al cargar reportes: $e', esError: true);
    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  Future<void> mostrarSelectorCaso() async {
    if (casos.isEmpty) {
      mostrarMensaje('No hay casos disponibles', esError: true);
      return;
    }

    final seleccionado = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Selecciona un caso',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: casos.length,
                  itemBuilder: (context, index) {
                    final caso = Map<String, dynamic>.from(casos[index] as Map);
                    final id = caso['caso_id'] ?? caso['id'];
                    final cliente = obtenerNombreCliente(caso);
                    final servicio = obtenerServicioCaso(caso);

                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFEFF6FF),
                        child: Icon(
                          Icons.assignment_rounded,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      title: Text(
                        cliente,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Caso #$id · $servicio'),
                      onTap: () => Navigator.pop(context, caso),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (seleccionado != null) {
      final id = seleccionado['caso_id'] ?? seleccionado['id'];

      setState(() {
        casoSeleccionado = seleccionado;
        casoSeleccionadoId = int.tryParse(id.toString());
        reportes = [];
        archivoSeleccionado = null;
        nombreArchivo = null;
        descripcionController.clear();
      });

      await cargarReportes();
    }
  }

  Future<void> seleccionarArchivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp', 'doc', 'docx'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final archivo = result.files.single;

    if (archivo.bytes == null &&
        (archivo.path == null || archivo.path!.isEmpty)) {
      mostrarMensaje('No se pudo leer el archivo seleccionado', esError: true);
      return;
    }

    setState(() {
      archivoSeleccionado = archivo;
      nombreArchivo = archivo.name;
    });
  }

  Future<void> subirReporte() async {
    if (casoSeleccionadoId == null) {
      mostrarMensaje('Selecciona un caso primero', esError: true);
      return;
    }

    if (archivoSeleccionado == null) {
      mostrarMensaje('Selecciona un archivo primero', esError: true);
      return;
    }

    setState(() => subiendo = true);

    try {
      await api.subirReporte(
        casoId: casoSeleccionadoId!,
        valuadorId: widget.valuadorId,
        file: archivoSeleccionado!,
        descripcion: descripcionController.text.trim(),
      );

      descripcionController.clear();

      if (!mounted) return;

      setState(() {
        archivoSeleccionado = null;
        nombreArchivo = null;
      });

      mostrarMensaje('Reporte subido correctamente');
      await cargarReportes();
    } catch (e) {
      mostrarMensaje('Error al subir reporte: $e', esError: true);
    } finally {
      if (mounted) {
        setState(() => subiendo = false);
      }
    }
  }

  Future<void> abrirReporte(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      mostrarMensaje('URL inválida', esError: true);
      return;
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      mostrarMensaje('No se pudo abrir el reporte', esError: true);
    }
  }

  void mostrarMensaje(String mensaje, {bool esError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  String obtenerNombreCliente(Map<String, dynamic> caso) {
    final cliente = caso['cliente'];

    if (cliente is Map) {
      return (cliente['nombre'] ??
              cliente['nombre_completo'] ??
              'Cliente sin nombre')
          .toString();
    }

    return (caso['cliente_nombre'] ??
            caso['nombre_cliente'] ??
            caso['nombre'] ??
            cliente ??
            'Cliente sin nombre')
        .toString();
  }

  String obtenerServicioCaso(Map<String, dynamic> caso) {
    return (caso['servicio'] ??
            caso['titulo'] ??
            caso['tipo_servicio'] ??
            'Solicitud de valuación')
        .toString();
  }

  String obtenerNombreArchivo(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
      return 'Reporte';
    } catch (_) {
      return 'Reporte';
    }
  }

  IconData iconoPorArchivo(String archivo) {
    final lower = archivo.toLowerCase();

    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;

    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp')) {
      return Icons.image_rounded;
    }

    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return Icons.description_rounded;
    }

    return Icons.insert_drive_file_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final clienteActual =
        casoSeleccionado == null ? null : obtenerNombreCliente(casoSeleccionado!);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Dictámenes / Reportes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: cargarReportes,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: cargarReportes,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _headerCard(clienteActual),
            const SizedBox(height: 18),
            _selectorCasoCard(),
            const SizedBox(height: 18),
            _uploadCard(),
            const SizedBox(height: 22),
            _tituloSeccion(),
            const SizedBox(height: 12),
            if (cargando)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (reportes.isEmpty)
              _emptyState()
            else
              ...reportes.map((reporte) => _reporteCard(reporte)),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(String? clienteActual) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.assignment_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestión documental',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  casoSeleccionadoId == null
                      ? 'Selecciona un caso para continuar'
                      : '$clienteActual · Caso #$casoSeleccionadoId',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectorCasoCard() {
    final texto = casoSeleccionado == null
        ? 'Seleccionar caso'
        : obtenerNombreCliente(casoSeleccionado!);

    return GestureDetector(
      onTap: mostrarSelectorCaso,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.folder_copy_rounded, color: Color(0xFF2563EB)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  Widget _uploadCard() {
    final bloqueado = casoSeleccionadoId == null;

    return Opacity(
      opacity: bloqueado ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subir nuevo reporte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: bloqueado || subiendo ? null : seleccionarArchivo,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: archivoSeleccionado == null
                        ? Colors.grey.shade300
                        : const Color(0xFF2563EB),
                    width: 1.3,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      archivoSeleccionado == null
                          ? Icons.upload_file_rounded
                          : Icons.check_circle_rounded,
                      color: archivoSeleccionado == null
                          ? Colors.grey.shade700
                          : const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        nombreArchivo ?? 'Seleccionar PDF, imagen o documento',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: archivoSeleccionado == null
                              ? Colors.grey.shade700
                              : const Color(0xFF111827),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: descripcionController,
              enabled: !bloqueado && !subiendo,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Descripción del reporte...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: bloqueado || subiendo ? null : subirReporte,
                icon: subiendo
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_rounded),
                label: Text(
                  subiendo ? 'Subiendo...' : 'Subir reporte',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tituloSeccion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Reportes cargados',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '${reportes.length} archivo(s)',
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(
            casoSeleccionadoId == null
                ? Icons.touch_app_rounded
                : Icons.folder_open_rounded,
            size: 58,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            casoSeleccionadoId == null
                ? 'Selecciona un caso'
                : 'Aún no hay reportes',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            casoSeleccionadoId == null
                ? 'Elige un cliente/caso para cargar sus dictámenes.'
                : 'Cuando subas un dictamen o reporte aparecerá aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _reporteCard(dynamic reporte) {
    final map = Map<String, dynamic>.from(reporte as Map);

    final archivo = (map['archivo_url'] ??
            map['archivo'] ??
            map['url'] ??
            map['ruta'] ??
            '')
        .toString();

    final descripcion = (map['descripcion'] ?? '').toString();

    final fecha = (map['creado_en'] ??
            map['created_at'] ??
            map['fecha'] ??
            '')
        .toString();

    final nombre = obtenerNombreArchivo(archivo);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              iconoPorArchivo(nombre),
              color: const Color(0xFF2563EB),
              size: 30,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                if (descripcion.isNotEmpty)
                  Text(
                    descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13.5,
                    ),
                  ),
                if (descripcion.isNotEmpty) const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        fecha.isEmpty ? 'Sin fecha' : fecha,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: archivo.isEmpty ? null : () => abrirReporte(archivo),
            icon: const Icon(Icons.open_in_new_rounded),
            color: const Color(0xFF2563EB),
            tooltip: 'Abrir reporte',
          ),
        ],
      ),
    );
  }
}