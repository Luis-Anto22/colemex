import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ClienteCfdiScreen extends StatefulWidget {
  final int clienteId;

  const ClienteCfdiScreen({
    super.key,
    required this.clienteId,
  });

  @override
  State<ClienteCfdiScreen> createState() => _ClienteCfdiScreenState();
}

class _ClienteCfdiScreenState extends State<ClienteCfdiScreen> {
  bool _loading = true;
  String? _error;

  List<dynamic> _cfdis = [];

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/clientes/cfdi";

  @override
  void initState() {
    super.initState();
    _fetchCfdis();
  }

  Future<void> _fetchCfdis() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$_baseUrl?cliente_id=${widget.clienteId}",
        ),
        headers: {
          "Accept": "application/json",
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {
        setState(() {
          _cfdis = data["data"] ?? [];
          _loading = false;
        });
      } else {
        setState(() {
          _error = data["message"] ?? "Error al cargar CFDI";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'emitido':
        return Colors.green;

      case 'cancelado':
        return Colors.red;

      case 'borrador':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  Future<void> _abrirArchivo(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
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
        title: const Text("Mis CFDI"),
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Text("❌ $_error"),
                )
              : _cfdis.isEmpty
                  ? const Center(
                      child: Text(
                        "No tienes CFDI disponibles.",
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: _cfdis.length,
                      itemBuilder: (context, index) {
                        final cfdi =
                            Map<String, dynamic>.from(
                          _cfdis[index],
                        );

                        final estado =
                            cfdi["estado"]?.toString() ??
                                "borrador";

                        return Card(
                          margin:
                              const EdgeInsets.only(bottom: 14),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          _estadoColor(
                                            estado,
                                          ).withOpacity(.12),
                                      child: Icon(
                                        Icons.receipt_long,
                                        color:
                                            _estadoColor(
                                          estado,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            cfdi["razon_social"] ??
                                                "Sin razón social",
                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 4),
                                          Text(
                                            "RFC: ${cfdi["rfc_cliente"] ?? "N/A"}",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                Text(
                                  "Concepto: ${cfdi["concepto"] ?? "N/A"}",
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "Total: \$${cfdi["total"] ?? "0.00"}",
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _estadoColor(
                                      estado,
                                    ).withOpacity(.12),
                                    borderRadius:
                                        BorderRadius.circular(
                                      999,
                                    ),
                                  ),
                                  child: Text(
                                    estado.toUpperCase(),
                                    style: TextStyle(
                                      color: _estadoColor(
                                        estado,
                                      ),
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                if ((cfdi["xml_url"] ?? "")
                                    .toString()
                                    .isNotEmpty)
                                  _archivoButton(
                                    label: "Abrir XML",
                                    icon: Icons.code,
                                    onPressed: () =>
                                        _abrirArchivo(
                                      cfdi["xml_url"],
                                    ),
                                  ),

                                if ((cfdi["pdf_url"] ?? "")
                                    .toString()
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 8),

                                  _archivoButton(
                                    label:
                                        "Abrir / imprimir PDF",
                                    icon: Icons.print,
                                    onPressed: () =>
                                        _abrirArchivo(
                                      cfdi["pdf_url"],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}