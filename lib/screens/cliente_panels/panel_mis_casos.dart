import 'package:flutter/material.dart';

class PanelMisCasos extends StatelessWidget {
  final List<Map<String, dynamic>> listaCasos;

  const PanelMisCasos({super.key, required this.listaCasos});

  @override
  Widget build(BuildContext context) {
    if (listaCasos.isEmpty) {
      return const Center(
        child: Text('No tienes casos registrados.'),
      );
    }

    return ListView.builder(
      itemCount: listaCasos.length,
      itemBuilder: (context, index) {
        final caso = listaCasos[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(caso['titulo'] ?? 'Caso'),
            subtitle: Text(caso['descripcion'] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () {
                // Aquí puedes abrir el documento con tu función abrirDocumento
              },
            ),
          ),
        );
      },
    );
  }
}