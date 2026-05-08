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
  double pagado = 0;
  double pendiente = 0;

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
        mensaje = 'ID no válido';
      });
      return;
    }

    try {
      final data = await api.getIngresos(profesionalId);

      if (!mounted) return;

      setState(() {
        total = _toDouble(data['total']);
        pagado = _toDouble(data['pagado']);
        pendiente = _toDouble(data['pendiente']);
        items = data['items'] is List ? data['items'] as List<dynamic> : [];
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

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String _money(dynamic value) {
    final amount = _toDouble(value);
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _texto(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _fecha(dynamic value) {
    final text = _texto(value, 'Fecha no disponible');
    if (text.length >= 16) {
      return text.replaceFirst('T', ' ').substring(0, 16);
    }
    return text;
  }

  void _verDetalle(Map<String, dynamic> item) {
    final concepto = _texto(item['concepto'], 'Ingreso');
    final monto = _money(item['monto']);
    final fecha = _fecha(item['fecha']);
    final profesional = _texto(item['profesional_id'], 'No disponible');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        final gold = Theme.of(context).primaryColor;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, color: gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        concepto,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _detalleLinea(Icons.attach_money, 'Monto', monto),
                _detalleLinea(Icons.calendar_today_outlined, 'Fecha', fecha),
                _detalleLinea(Icons.badge_outlined, 'Profesional ID', profesional),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detalleLinea(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumenCard({
    required IconData icon,
    required String title,
    required double amount,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _money(amount),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ingresoCard(Map<String, dynamic> item) {
    final gold = Theme.of(context).primaryColor;
    final concepto = _texto(item['concepto'], 'Ingreso');
    final monto = _toDouble(item['monto']);
    final fecha = _fecha(item['fecha']);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _verDetalle(item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.receipt_long, color: gold),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      concepto,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Fecha: $fecha',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _money(monto),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresos / comisiones'),
        actions: [
          IconButton(
            onPressed: _cargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Icon(Icons.attach_money, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text(
              'Ingresos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Resumen de pagos, comisiones y facturación.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Icon(Icons.account_balance_wallet, color: gold),
                title: const Text(
                  'Total acumulado',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Ingresos registrados para este profesional'),
                trailing: Text(
                  _money(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _resumenCard(
                  icon: Icons.check_circle_outline,
                  title: 'Pagado',
                  amount: pagado,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _resumenCard(
                  icon: Icons.schedule,
                  title: 'Pendiente',
                  amount: pendiente,
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (cargando)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    mensaje.isEmpty ? 'Sin ingresos registrados.' : mensaje,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Movimientos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...items.map((item) {
                final map = Map<String, dynamic>.from(item as Map);
                return _ingresoCard(map);
              }),
            ],
          ],
        ),
      ),
    );
  }
}