import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CfdiDetalle extends StatefulWidget {
  final int cfdiId;

  const CfdiDetalle({
    super.key,
    required this.cfdiId,
  });

  @override
  State<CfdiDetalle> createState() => _CfdiDetalleState();
}

class _CfdiDetalleState extends State<CfdiDetalle> {
  bool _loading = true;
  bool _subiendo = false;
  Map<String, dynamic>? _cfdi;

  PlatformFile? _xmlFile;
  PlatformFile? _pdfFile;

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/cfdi";

  @override
  void initState() {
    super.initState();
    _fetchDetalle();
  }

  Future<void> _fetchDetalle() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/${widget.cfdiId}"),
        headers: {"Accept": "application/json"},
      );

      final data = json.decode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          _cfdi = Map<String, dynamic>.from(data["data"]);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _seleccionarArchivo(String tipo) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: tipo == 'xml' ? ['xml'] : ['pdf'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      if (tipo == 'xml') {
        _xmlFile = result.files.single;
      } else {
        _pdfFile = result.files.single;
      }
    });
  }

  Future<void> _subirArchivos() async {
    if (_xmlFile == null && _pdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona un XML o PDF")),
      );
      return;
    }

    setState(() => _subiendo = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$_baseUrl/${widget.cfdiId}/archivos"),
      );

      request.headers["Accept"] = "application/json";

      if (_xmlFile != null) {
        if (_xmlFile!.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'xml',
              _xmlFile!.bytes!,
              filename: _xmlFile!.name,
            ),
          );
        } else if (_xmlFile!.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'xml',
              _xmlFile!.path!,
              filename: _xmlFile!.name,
            ),
          );
        }
      }

      if (_pdfFile != null) {
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
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["success"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Archivos subidos")),
        );

        setState(() {
          _xmlFile = null;
          _pdfFile = null;
        });

        await _fetchDetalle();
      } else {
        throw Exception(data["message"] ?? "No se pudieron subir archivos");
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

  Future<void> _abrirUrl(String? url) async {
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

  Widget _archivoButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle CFDI"),
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cfdi == null
              ? const Center(child: Text("CFDI no encontrado"))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _info("Razón social", _cfdi!["razon_social"] ?? "N/A"),
                    _info("RFC", _cfdi!["rfc_cliente"] ?? "N/A"),
                    _info("Concepto", _cfdi!["concepto"] ?? "N/A"),
                    _info("Subtotal", "\$${_cfdi!["subtotal"] ?? "0"}"),
                    _info("IVA", "\$${_cfdi!["iva"] ?? "0"}"),
                    _info("Total", "\$${_cfdi!["total"] ?? "0"}"),
                    _info("Estado", _cfdi!["estado"] ?? "N/A"),
                    _info("UUID", _cfdi!["uuid"] ?? "Sin UUID"),
                    const Divider(height: 32),
                    const Text(
                      "Archivos fiscales",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _archivoButton(
                      label: _xmlFile == null
                          ? "Seleccionar XML"
                          : "XML: ${_xmlFile!.name}",
                      icon: Icons.code,
                      onPressed: () => _seleccionarArchivo('xml'),
                    ),
                    const SizedBox(height: 8),
                    _archivoButton(
                      label: _pdfFile == null
                          ? "Seleccionar PDF"
                          : "PDF: ${_pdfFile!.name}",
                      icon: Icons.picture_as_pdf,
                      onPressed: () => _seleccionarArchivo('pdf'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _subiendo ? null : _subirArchivos,
                        icon: _subiendo
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(
                          _subiendo ? "Subiendo..." : "Subir XML/PDF",
                        ),
                      ),
                    ),
                    const Divider(height: 32),
                    if ((_cfdi!["xml_url"] ?? "").toString().isNotEmpty)
                      _archivoButton(
                        label: "Abrir XML",
                        icon: Icons.code,
                        onPressed: () => _abrirUrl(_cfdi!["xml_url"]),
                      ),
                    if ((_cfdi!["pdf_url"] ?? "").toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _archivoButton(
                        label: "Abrir / imprimir PDF",
                        icon: Icons.print,
                        onPressed: () => _abrirUrl(_cfdi!["pdf_url"]),
                      ),
                    ],
                  ],
                ),
    );
  }
}