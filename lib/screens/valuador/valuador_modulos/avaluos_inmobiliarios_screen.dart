import 'package:flutter/material.dart';
import '../../../services/api_client.dart';
import '../../../services/valuador_api.dart';

class AvaluosInmobiliariosScreen extends StatefulWidget {
  const AvaluosInmobiliariosScreen({super.key});

  @override
  State<AvaluosInmobiliariosScreen> createState() =>
      _AvaluosInmobiliariosScreenState();
}

class _AvaluosInmobiliariosScreenState
    extends State<AvaluosInmobiliariosScreen> {
  final int valuadorId = 1; // TODO: real
  late final ValuadorApi api;
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    api = ValuadorApi(ApiClient());
    future = api.getAvaluos(valuadorId);
  }

  Future<void> _reload() async {
    setState(() {
      future = api.getAvaluos(valuadorId);
    });
  }

  Future<void> _editar(Map<String, dynamic> item) async {
    final casoId = int.parse(item['caso_id'].toString());
    String estado = (item['estado'] ?? 'en proceso').toString();
    final valorCtrl =
        TextEditingController(text: (item['valor_estimado'] ?? '').toString());
    final notasCtrl =
        TextEditingController(text: (item['notas'] ?? '').toString());

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Avalúo caso #$casoId'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: estado,
              items: const [
                DropdownMenuItem(
                    value: 'en proceso', child: Text('En proceso')),
                DropdownMenuItem(
                    value: 'finalizado', child: Text('Finalizado')),
                DropdownMenuItem(
                    value: 'cancelado', child: Text('Cancelado')),
              ],
              onChanged: (v) => estado = v ?? 'en proceso',
              decoration: const InputDecoration(labelText: 'Estado'),
            ),
            TextField(
              controller: valorCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Valor estimado'),
            ),
            TextField(
              controller: notasCtrl,
              decoration: const InputDecoration(labelText: 'Notas'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final valor =
          double.tryParse(valorCtrl.text.trim().replaceAll(',', ' '));
      await api.guardarAvaluo(
        valuadorId: valuadorId,
        casoId: casoId,
        estado: estado,
        valorEstimado: valor,
        notas: notasCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Avalúo guardado')));
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avalúos inmobiliarios'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No hay avalúos aún.'));
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final a = items[i] as Map<String, dynamic>;
                final casoId = a['caso_id'];

                return Card(
                  child: ListTile(
                    title: Text(
                        'Caso #$casoId • ${(a['titulo'] ?? 'Sin título').toString()}'),
                    subtitle: Text(
                        'Estado: ${(a['estado'] ?? '').toString()} • Valor: ${(a['valor_estimado'] ?? '—').toString()}'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editar(a),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
