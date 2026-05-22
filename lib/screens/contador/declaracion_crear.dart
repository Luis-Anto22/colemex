import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeclaracionCrear extends StatefulWidget {
  final int idContador;

  const DeclaracionCrear({
    super.key,
    required this.idContador,
  });

  @override
  State<DeclaracionCrear> createState() =>
      _DeclaracionCrearState();
}

class _DeclaracionCrearState
    extends State<DeclaracionCrear> {
  final _formKey = GlobalKey<FormState>();

  final _periodoController =
      TextEditingController();

  final _ejercicioController =
      TextEditingController();

  final _descripcionController =
      TextEditingController();

  final _montoController =
      TextEditingController();

  String _tipo = 'mensual';

  bool _loading = false;
  bool _loadingClientes = true;

  List<dynamic> _clientes = [];
  int? _clienteSeleccionadoId;

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/declaraciones";

  static const String _clientesUrl =
      "https://corporativolegaldigital.com/api/contador/clientes";

  final List<String> _tipos = const [
    'mensual',
    'anual',
    'iva',
    'isr',
    'retenciones',
    'opinion_cumplimiento',
    'pago_provisional',
  ];

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  @override
  void dispose() {
    _periodoController.dispose();
    _ejercicioController.dispose();
    _descripcionController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _cargarClientes() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$_clientesUrl?contador_id=${widget.idContador}",
        ),
        headers: {
          "Accept": "application/json",
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {
        setState(() {
          _clientes = data["data"] ?? [];
          _loadingClientes = false;
        });
      } else {
        setState(() => _loadingClientes = false);
      }
    } catch (_) {
      setState(() => _loadingClientes = false);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_clienteSeleccionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Selecciona un cliente/empresa",
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type":
              "application/json",
        },
        body: json.encode({
          "contador_id":
              widget.idContador,
          "cliente_id":
              _clienteSeleccionadoId,
          "tipo": _tipo,
          "periodo":
              _periodoController.text
                  .trim(),
          "ejercicio":
              int.tryParse(
                _ejercicioController.text
                    .trim(),
              ) ??
              2026,
          "descripcion":
              _descripcionController.text
                  .trim(),
          "monto":
              double.tryParse(
                _montoController.text
                    .trim(),
              ) ??
              0,
          "estado": "pendiente",
        }),
      );

      final data = json.decode(
        response.body,
      );

      if ((response.statusCode ==
                  200 ||
              response.statusCode ==
                  201) &&
          data["success"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              "Declaración creada correctamente",
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        throw Exception(
          data["message"] ??
              "No se pudo crear la declaración",
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    TextInputType? type,
    int maxLines = 1,
    bool required = true,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
            bottom: 14,
          ),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        validator:
            required
                ? (v) {
                  if (v == null ||
                      v.trim().isEmpty) {
                    return "Campo requerido";
                  }
                  return null;
                }
                : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
                  14,
                ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold =
        Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nueva declaración SAT",
        ),
        backgroundColor: gold,
        foregroundColor:
            Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
              const EdgeInsets.all(
                16,
              ),
          children: [
            if (_loadingClientes)
              const Padding(
                padding:
                    EdgeInsets.only(
                      bottom: 14,
                    ),
                child: Center(
                  child:
                      CircularProgressIndicator(),
                ),
              )
            else
              Padding(
                padding:
                    const EdgeInsets.only(
                      bottom: 14,
                    ),
                child:
                    DropdownButtonFormField<
                      int
                    >(
                      value:
                          _clienteSeleccionadoId,
                      isExpanded: true,
                      decoration:
                          InputDecoration(
                            labelText:
                                "Cliente / empresa",
                            border:
                                OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                        14,
                                      ),
                                ),
                          ),
                      items:
                          _clientes.map<
                            DropdownMenuItem<
                              int
                            >
                          >((cliente) {
                            final c =
                                Map<String, dynamic>.from(
                                  cliente,
                                );

                            return DropdownMenuItem<
                              int
                            >(
                              value:
                                  int.tryParse(
                                    c["id"].toString(),
                                  ),
                              child: Text(
                                "${c["nombre"] ?? "Sin nombre"}"
                                "${c["correo"] != null ? " • ${c["correo"]}" : ""}",
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (
                        value,
                      ) {
                        setState(
                          () =>
                              _clienteSeleccionadoId =
                                  value,
                        );
                      },
                      validator: (
                        value,
                      ) {
                        if (value ==
                            null) {
                          return "Selecciona un cliente/empresa";
                        }
                        return null;
                      },
                    ),
              ),

            Padding(
              padding:
                  const EdgeInsets.only(
                    bottom: 14,
                  ),
              child:
                  DropdownButtonFormField<
                    String
                  >(
                    value: _tipo,
                    decoration:
                        InputDecoration(
                          labelText:
                              "Tipo de declaración",
                          border:
                              OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                      14,
                                    ),
                              ),
                        ),
                    items:
                        _tipos.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(
                              tipo,
                            ),
                          );
                        }).toList(),
                    onChanged: (
                      value,
                    ) {
                      if (value !=
                          null) {
                        setState(
                          () =>
                              _tipo =
                                  value,
                        );
                      }
                    },
                  ),
            ),

            _input(
              _periodoController,
              "Periodo",
              type:
                  TextInputType.text,
            ),

            _input(
              _ejercicioController,
              "Ejercicio",
              type:
                  TextInputType.number,
            ),

            _input(
              _montoController,
              "Monto",
              type:
                  TextInputType.number,
              required: false,
            ),

            _input(
              _descripcionController,
              "Descripción",
              maxLines: 3,
              required: false,
            ),

            const SizedBox(
              height: 10,
            ),

            ElevatedButton.icon(
              onPressed:
                  _loading
                      ? null
                      : _guardar,
              icon:
                  _loading
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                              strokeWidth:
                                  2,
                            ),
                      )
                      : const Icon(
                        Icons.save,
                      ),
              label: Text(
                _loading
                    ? "Guardando..."
                    : "Guardar declaración",
              ),
            ),
          ],
        ),
      ),
    );
  }
}