import 'package:flutter/material.dart';

class IngresosScreen extends StatelessWidget {
  const IngresosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Ingresos / comisiones')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.attach_money, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text('Ingresos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text('Resumen de pagos, comisiones y facturación.', textAlign: TextAlign.center),
            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: Icon(Icons.account_balance_wallet, color: gold),
                title: const Text('Saldo estimado'),
                subtitle: const Text('\$0.00 (demo)'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.receipt_long, color: gold),
                title: const Text('Último pago'),
                subtitle: const Text('Sin registros (demo)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
