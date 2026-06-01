import 'package:flutter/material.dart';
import 'cliente_cfdi_screen.dart';
import '../../services/api_services/api_client.dart';

class PanelMisCasos extends StatefulWidget {
  final List<Map<String, dynamic>> listaCasos;
  final int clienteId;

  const PanelMisCasos({
    super.key,
    required this.listaCasos,
    required this.clienteId,
  });

  @override
  State<PanelMisCasos> createState() => _PanelMisCasosState();
}

class _PanelMisCasosState extends State<PanelMisCasos> {
  late List<Map<String, dynamic>> casos;
  final Set<int> seleccionados = {};
  final ApiClient api = ApiClient();
  bool modoSeleccion = false;

  @override
  void initState() {
    super.initState();
    casos = List<Map<String, dynamic>>.from(widget.listaCasos);
  }

  void _activarSeleccion() {
    setState(() {
      modoSeleccion = !modoSeleccion;
      seleccionados.clear();
    });
  }

  void _toggleSeleccion(int index) {
    setState(() {
      if (seleccionados.contains(index)) {
        seleccionados.remove(index);
      } else {
        seleccionados.add(index);
      }

      if (seleccionados.isEmpty) {
        modoSeleccion = false;
      }
    });
  }

  Future<void> _archivarCaso(int index) async {
  final caso = casos[index];
  final casoId = int.tryParse('${caso['id']}');

  if (casoId == null) return;

  final res = await api.archivarCasoCliente(
    casoId: casoId,
    clienteId: widget.clienteId,
  );

  if (res['success'] == true) {
    setState(() {
      casos.removeAt(index);
      seleccionados.clear();
      modoSeleccion = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Caso archivado')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message'] ?? 'No se pudo archivar')),
    );
  }
}

  Future<void> _eliminarCaso(int index) async {
  final caso = casos[index];
  final casoId = int.tryParse('${caso['id']}');

  if (casoId == null) return;

  final res = await api.eliminarCasoCliente(
    casoId: casoId,
    clienteId: widget.clienteId,
  );

  if (res['success'] == true) {
    setState(() {
      casos.removeAt(index);
      seleccionados.clear();
      modoSeleccion = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Caso eliminado')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message'] ?? 'No se pudo eliminar')),
    );
  }
}

  void _archivarSeleccionados() {
    final indices = seleccionados.toList()..sort((a, b) => b.compareTo(a));

    setState(() {
      for (final index in indices) {
        casos.removeAt(index);
      }
      seleccionados.clear();
      modoSeleccion = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Casos archivados')),
    );
  }

  void _eliminarSeleccionados() {
    final indices = seleccionados.toList()..sort((a, b) => b.compareTo(a));

    setState(() {
      for (final index in indices) {
        casos.removeAt(index);
      }
      seleccionados.clear();
      modoSeleccion = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Casos eliminados')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (casos.isEmpty) {
      return const Center(
        child: Text('No tienes casos registrados.'),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _activarSeleccion,
                icon: Icon(
                  modoSeleccion ? Icons.close : Icons.check_box_outlined,
                ),
                label: Text(modoSeleccion ? 'Cancelar' : 'Seleccionar'),
              ),
              const SizedBox(width: 8),
              if (modoSeleccion && seleccionados.isNotEmpty) ...[
                ElevatedButton.icon(
                  onPressed: _archivarSeleccionados,
                  icon: const Icon(Icons.archive),
                  label: const Text('Archivar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _eliminarSeleccionados,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text('Eliminar'),
                ),
              ],
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: casos.length,
            itemBuilder: (context, index) {
              final caso = casos[index];
              final servicio = (caso['servicio'] ?? '').toString();
              final esContador = servicio == 'Contadores';
              final seleccionado = seleccionados.contains(index);

              return Dismissible(
                key: ValueKey(caso['id'] ?? index),

                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  color: Colors.blue,
                  child: const Icon(
                    Icons.archive,
                    color: Colors.white,
                  ),
                ),

                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),

                confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      await _archivarCaso(index);
                    } else if (direction == DismissDirection.endToStart) {
                      await _eliminarCaso(index);
                    }
                    return false;
                  },

                child: Card(
                  margin: const EdgeInsets.all(8),
                  color: seleccionado ? Colors.blue.withOpacity(0.12) : null,
                  child: ListTile(
                    leading: modoSeleccion
                        ? Checkbox(
                            value: seleccionado,
                            onChanged: (_) => _toggleSeleccion(index),
                          )
                        : null,
                    title: Text(caso['titulo'] ?? 'Caso'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(caso['descripcion'] ?? ''),
                        if (esContador) ...[
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.receipt_long),
                            label: const Text('Documentos fiscales / CFDI'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ClienteCfdiScreen(
                                    clienteId: widget.clienteId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                    trailing: modoSeleccion
                        ? null
                        : const Icon(Icons.chevron_right),
                    onTap: () {
                      if (modoSeleccion) {
                        _toggleSeleccion(index);
                      }
                    },
                    onLongPress: () {
                      setState(() {
                        modoSeleccion = true;
                        seleccionados.add(index);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}