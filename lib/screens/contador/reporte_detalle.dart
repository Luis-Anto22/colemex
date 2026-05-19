import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ReporteDetalle extends StatefulWidget {
  final int reporteId;

  const ReporteDetalle({super.key, required this.reporteId});

  @override
  State<ReporteDetalle> createState() => _ReporteDetalleState();
}

class _ReporteDetalleState extends State<ReporteDetalle> {
  bool _loading = true;
  bool _subiendo = false;
  bool _actualizando = false;

  Map<String, dynamic>? _reporte;
  PlatformFile? _pdfFile;

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/reportes";

  final List<String> _estados = const [
    'borrador',
    'generado',
    'enviado',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDetalle();
  }

  Future<void> _fetchDetalle() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/${widget.reporteId}"),
        headers: {"Accept": "application/json"},
      );

      final data = json.decode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          _reporte = Map<String, dynamic>.from(data["data"]);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _seleccionarPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _pdfFile = result.files.single;
    });
  }

  Future<void> _subirPdf() async {
    if (_pdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona un PDF")),
      );
      return;
    }

    setState(() => _subiendo = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$_baseUrl/${widget.reporteId}/pdf"),
      );

      request.headers["Accept"] = "application/json";

      if (_pdfFile!.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'pdf',
            _pdfFile!.bytes!,
            filename: _pdfFile!.name,
          ),
        );
      } else if (_pdfFile!.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'pdf',
            _pdfFile!.path!,
            filename: _pdfFile!.name,
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "PDF subido")),
        );

        setState(() => _pdfFile = null);

        await _fetchDetalle();
      } else {
        throw Exception(data["message"] ?? "No se pudo subir PDF");
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  Future<void> _actualizarEstado(String estado) async {
    setState(() => _actualizando = true);

    try {
      final response = await http.put(
        Uri.parse("$_baseUrl/${widget.reporteId}/estado"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode({"estado": estado}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Estado actualizado")),
        );

        await _fetchDetalle();
      } else {
        throw Exception(data["message"] ?? "No se pudo actualizar estado");
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _actualizando = false);
    }
  }

  Future<void> _abrirArchivo(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle reporte"),
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reporte == null
              ? const Center(child: Text("Reporte no encontrado"))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _info("Cliente", _reporte!["cliente_nombre"] ?? "N/A"),
                    _info("Título", _reporte!["titulo"] ?? "N/A"),
                    _info("Periodo", _reporte!["periodo"] ?? "N/A"),
                    _info("Ingresos", "\$${_reporte!["ingresos"] ?? "0"}"),
                    _info("Egresos", "\$${_reporte!["egresos"] ?? "0"}"),
                    _info("Utilidad", "\$${_reporte!["utilidad"] ?? "0"}"),
                    _info("Estado", _reporte!["estado"] ?? "N/A"),
                    _info(
                      "Observaciones",
                      _reporte!["observaciones"] ?? "Sin observaciones",
                    ),
                    const Divider(height: 32),
                    const Text(
                      "Cambiar estado",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _estados.contains(_reporte!["estado"])
                          ? _reporte!["estado"]
                          : 'borrador',
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Estado",
                      ),
                      items: _estados.map((estado) {
                        return DropdownMenuItem(
                          value: estado,
                          child: Text(estado),
                        );
                      }).toList(),
                      onChanged: _actualizando
                          ? null
                          : (value) {
                              if (value != null) {
                                _actualizarEstado(value);
                              }
                            },
                    ),
                    const Divider(height: 32),
                    const Text(
                      "PDF del reporte",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _seleccionarPdf,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: Text(
                          _pdfFile == null
                              ? "Seleccionar PDF"
                              : "PDF: ${_pdfFile!.name}",
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _subiendo ? null : _subirPdf,
                        icon: _subiendo
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(_subiendo ? "Subiendo..." : "Subir PDF"),
                      ),
                    ),
                    if ((_reporte!["pdf_url"] ?? "").toString().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _abrirArchivo(_reporte!["pdf_url"]),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text("Abrir / imprimir PDF"),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}