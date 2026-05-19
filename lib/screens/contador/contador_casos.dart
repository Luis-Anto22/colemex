import 'package:flutter/material.dart';
import 'contador_detalle.dart';
import 'api_service_contador.dart';

class ContadorCasos extends StatefulWidget {
  final int idContador;

  const ContadorCasos({super.key, required this.idContador});

  @override
  State<ContadorCasos> createState() => _ContadorCasosState();
}

class _ContadorCasosState extends State<ContadorCasos> {
  bool _isLoading = true;
  bool _creando = false;
  String? _error;

  List<dynamic> _casos = [];
  List<dynamic> _clientesSolicitantes = [];

  Map<String, dynamic>? _clienteSeleccionado;

  final TextEditingController _buscarClienteController =
      TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCasos();
    _fetchClientesSolicitantes();
  }

  @override
  void dispose() {
    _buscarClienteController.dispose();
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _fetchCasos() async {
    try {
      final data = await ApiServiceContador.obtenerCasos(widget.idContador);

      if (!mounted) return;

      setState(() {
        _casos = data;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchClientesSolicitantes() async {
    try {
      final data = await ApiServiceContador.obtenerClientesSolicitantes();

      if (!mounted) return;

      setState(() {
        _clientesSolicitantes = data;
      });
    } catch (e) {
      debugPrint("Error clientes solicitantes: $e");
    }
  }

  String _clienteTexto(Map<String, dynamic> c) {
    final nombre = c["nombre"]?.toString() ?? "Sin nombre";
    final correo = c["correo"]?.toString() ?? "";
    return correo.isEmpty ? nombre : "$nombre • $correo";
  }

  Future<void> _abrirNuevoCaso() async {
    _clienteSeleccionado = null;
    _buscarClienteController.clear();
    _tituloController.clear();
    _descripcionController.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nuevo caso contable',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Autocomplete<Map<String, dynamic>>(
                      displayStringForOption: _clienteTexto,
                      optionsBuilder: (TextEditingValue value) {
                        final query = value.text.toLowerCase().trim();

                        if (query.isEmpty) {
                          return _clientesSolicitantes
                              .map((e) => Map<String, dynamic>.from(e));
                        }

                        return _clientesSolicitantes
                            .map((e) => Map<String, dynamic>.from(e))
                            .where((cliente) {
                          final nombre =
                              cliente["nombre"]?.toString().toLowerCase() ?? "";
                          final correo =
                              cliente["correo"]?.toString().toLowerCase() ?? "";
                          final telefono =
                              cliente["telefono"]?.toString().toLowerCase() ?? "";

                          return nombre.contains(query) ||
                              correo.contains(query) ||
                              telefono.contains(query);
                        });
                      },
                      onSelected: (cliente) {
                        setModalState(() {
                          _clienteSeleccionado = cliente;
                          _buscarClienteController.text = _clienteTexto(cliente);
                        });
                      },
                      fieldViewBuilder: (
                        context,
                        controller,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        controller.text = _buscarClienteController.text;

                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Buscar cliente por nombre',
                            hintText: 'Ej. Juan Pérez',
                            border: const OutlineInputBorder(),
                            suffixIcon: _clienteSeleccionado == null
                                ? const Icon(Icons.search)
                                : const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                          ),
                          onChanged: (value) {
                            _buscarClienteController.text = value;

                            if (_clienteSeleccionado != null &&
                                value != _clienteTexto(_clienteSeleccionado!)) {
                              setModalState(() {
                                _clienteSeleccionado = null;
                              });
                            }
                          },
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            color: Colors.white,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 32,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final cliente = options.elementAt(index);

                                  return ListTile(
                                    title: Text(
                                      cliente["nombre"]?.toString() ??
                                          "Sin nombre",
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                    subtitle: Text(
                                      cliente["correo"]?.toString() ??
                                          "Sin correo",
                                      style:
                                          const TextStyle(color: Colors.black54),
                                    ),
                                    onTap: () => onSelected(cliente),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    if (_clientesSolicitantes.isEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'No hay clientes que hayan solicitado contador todavía.',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 12),

                    TextField(
                      controller: _tituloController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        hintText: 'Ej. Declaración mensual SAT',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: _descripcionController,
                      style: const TextStyle(color: Colors.black),
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        hintText: 'Describe el trámite o solicitud contable',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _creando ? null : _guardarNuevoCaso,
                        icon: _creando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(_creando ? 'Guardando...' : 'Crear caso'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _guardarNuevoCaso() async {
    final clienteId =
        int.tryParse(_clienteSeleccionado?["id"]?.toString() ?? "0") ?? 0;
    final titulo = _tituloController.text.trim();
    final descripcion = _descripcionController.text.trim();

    if (clienteId <= 0 || titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un cliente y agrega el título'),
        ),
      );
      return;
    }

    try {
      setState(() => _creando = true);

      final msg = await ApiServiceContador.crearCasoContable(
        contadorId: widget.idContador,
        clienteId: clienteId,
        titulo: titulo,
        descripcion: descripcion,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );

      await _fetchCasos();
      await _fetchClientesSolicitantes();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _creando = false);
      }
    }
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      case 'finalizado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _estadoIcon(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.schedule;
      case 'en proceso':
        return Icons.timelapse;
      case 'finalizado':
        return Icons.check_circle;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Casos contables"),
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNuevoCaso,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo caso'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("❌ Error: $_error"))
              : _casos.isEmpty
                  ? const Center(
                      child: Text(
                        "No tienes casos contables asignados.\nPresiona + Nuevo caso para crear uno.",
                        textAlign: TextAlign.center,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _fetchCasos();
                        await _fetchClientesSolicitantes();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _casos.length,
                        itemBuilder: (context, index) {
                          final caso =
                              Map<String, dynamic>.from(_casos[index]);
                          final estado =
                              caso["estado"]?.toString() ?? "pendiente";

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              leading: Icon(
                                _estadoIcon(estado),
                                color: _estadoColor(estado),
                                size: 34,
                              ),
                              title: Text(
                                caso["titulo"]?.toString() ?? "Sin título",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  "Cliente: ${caso["cliente_nombre"] ?? "N/A"}\n"
                                  "Estado: $estado\n"
                                  "Fecha: ${caso["fecha_creacion"] ?? "N/A"}",
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ContadorDetalle(
                                      idCaso: caso["id"],
                                      titulo:
                                          caso["titulo"]?.toString() ?? "",
                                      descripcion: caso["descripcion"]
                                              ?.toString() ??
                                          "",
                                      cliente: caso["cliente_nombre"]
                                              ?.toString() ??
                                          "",
                                      documento: "",
                                      estado: estado,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}