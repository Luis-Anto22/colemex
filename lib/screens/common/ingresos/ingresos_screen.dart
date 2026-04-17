import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/common_api.dart';

class IngresosScreen extends StatefulWidget {
  const IngresosScreen({super.key});

  @override
  State<IngresosScreen> createState() => _IngresosScreenState();
}

class _IngresosScreenState extends State<IngresosScreen> {
  final CommonApi api = CommonApi(ApiClient());
  bool cargando = true;
  String mensaje = '';
  double total = 0;
  List<dynamic> items = [];
  int profesionalId = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    profesionalId = prefs.getInt('id') ?? 0;
    if (profesionalId <= 0) {
      setState(() {
        cargando = false;
        mensaje = 'ID no valido';
      });
      return;
    }

    try {
      final data = await api.getIngresos(profesionalId);
      if (!mounted) return;
      setState(() {
        total = double.tryParse((data['total'] ?? 0).toString()) ?? 0;
        items = (data['items'] as List<dynamic>? ?? []);
        cargando = false;
        mensaje = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        cargando = false;
        mensaje = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresos / comisiones'),
        actions: [
          IconButton(onPressed: _cargar, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.attach_money, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text(
              'Ingresos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'Resumen de pagos, comisiones y facturacion.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.account_balance_wallet, color: gold),
                title: const Text('Total acumulado'),
                subtitle: Text('\$${total.toStringAsFixed(2)}'),
              ),
            ),
            const SizedBox(height: 10),
            if (cargando)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (items.isEmpty)
              Expanded(
                child: Center(
                  child: Text(mensaje.isEmpty ? 'Sin ingresos.' : mensaje),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final m = items[i] as Map<String, dynamic>;
                    final monto =
                        double.tryParse((m['monto'] ?? 0).toString()) ?? 0;
                    final comision =
                        double.tryParse((m['comision'] ?? 0).toString()) ?? 0;
                    return ListTile(
                      leading: Icon(Icons.receipt_long, color: gold),
                      title: Text((m['concepto'] ?? 'Ingreso').toString()),
                      subtitle: Text((m['fecha'] ?? '').toString()),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${monto.toStringAsFixed(2)}'),
                          Text(
                            'Comision: \$${comision.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
