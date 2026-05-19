import 'package:flutter/material.dart';
import 'cliente_cfdi_screen.dart';

class PanelMisCasos extends StatelessWidget {
  final List<Map<String, dynamic>> listaCasos;
  final int clienteId;

  const PanelMisCasos({
    super.key,
    required this.listaCasos,
    required this.clienteId,
  });

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
        final servicio = (caso['servicio'] ?? '').toString();

        final esContador = servicio == 'Contadores';

        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
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
                            clienteId: clienteId,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}