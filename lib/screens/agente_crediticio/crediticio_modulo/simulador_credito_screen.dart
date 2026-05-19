import 'package:flutter/material.dart';

import '../api_service_crediticio.dart';

class SimuladorCreditoScreen extends StatefulWidget {
  final int agenteId;

  const SimuladorCreditoScreen({
    super.key,
    required this.agenteId,
  });

  @override
  State<SimuladorCreditoScreen> createState() => _SimuladorCreditoScreenState();
}

class _SimuladorCreditoScreenState extends State<SimuladorCreditoScreen> {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _engancheController = TextEditingController();
  final TextEditingController _tasaController = TextEditingController();
  final TextEditingController _plazoController = TextEditingController();
  final TextEditingController _ingresoController = TextEditingController();

  Map<String, dynamic>? _resultado;

  @override
  void initState() {
    super.initState();

    _montoController.text = '500000';
    _engancheController.text = '50000';
    _tasaController.text = '12';
    _plazoController.text = '60';
    _ingresoController.text = '25000';

    _calcular();
  }

  @override
  void dispose() {
    _montoController.dispose();
    _engancheController.dispose();
    _tasaController.dispose();
    _plazoController.dispose();
    _ingresoController.dispose();
    super.dispose();
  }

  double _doubleValue(TextEditingController controller) {
    return double.tryParse(
          controller.text.replaceAll(',', '').trim(),
        ) ??
        0;
  }

  int _intValue(TextEditingController controller) {
    return int.tryParse(
          controller.text.replaceAll(',', '').trim(),
        ) ??
        0;
  }

  String _money(dynamic value) {
    final raw = double.tryParse('${value ?? 0}') ?? 0;
    return raw.toStringAsFixed(2);
  }

  String _percent(dynamic value) {
    final raw = double.tryParse('${value ?? 0}') ?? 0;
    return raw.toStringAsFixed(1);
  }

  Color _riesgoColor(String riesgo) {
    switch (riesgo.toLowerCase()) {
      case 'bajo':
        return const Color(0xFF15803D);
      case 'medio':
        return const Color(0xFFB7791F);
      case 'alto':
        return const Color(0xFFB91C1C);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _calcular() {
    final result = ApiServiceCrediticio.simularCredito(
      monto: _doubleValue(_montoController),
      enganche: _doubleValue(_engancheController),
      tasaAnual: _doubleValue(_tasaController),
      plazoMeses: _intValue(_plazoController),
      ingresoMensual: _doubleValue(_ingresoController),
    );

    setState(() {
      _resultado = result;
    });
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String suffix = '',
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      onChanged: (_) => _calcular(),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _resultCard({
    required String title,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.97),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withOpacity(.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: (color ?? const Color(0xFFD4AF37)).withOpacity(.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color ?? const Color(0xFF7C5E00),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color ?? const Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenido() {
    final resultado = _resultado ?? {};

    final riesgo = '${resultado['nivel_riesgo'] ?? 'Sin cálculo'}';
    final riesgoColor = _riesgoColor(riesgo);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.97),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.black.withOpacity(.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            children: [
              _input(
                controller: _montoController,
                label: 'Monto del crédito',
                icon: Icons.request_quote_outlined,
                suffix: 'MXN',
              ),
              const SizedBox(height: 12),
              _input(
                controller: _engancheController,
                label: 'Enganche',
                icon: Icons.savings_outlined,
                suffix: 'MXN',
              ),
              const SizedBox(height: 12),
              _input(
                controller: _tasaController,
                label: 'Tasa anual',
                icon: Icons.percent_outlined,
                suffix: '%',
              ),
              const SizedBox(height: 12),
              _input(
                controller: _plazoController,
                label: 'Plazo',
                icon: Icons.calendar_month_outlined,
                suffix: 'meses',
              ),
              const SizedBox(height: 12),
              _input(
                controller: _ingresoController,
                label: 'Ingreso mensual del cliente',
                icon: Icons.payments_outlined,
                suffix: 'MXN',
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _calcular,
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Calcular'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Resultado estimado',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        _resultCard(
          title: 'Capital a financiar',
          value: '\$${_money(resultado['capital'])} MXN',
          icon: Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(height: 12),
        _resultCard(
          title: 'Pago mensual aproximado',
          value: '\$${_money(resultado['pago_mensual'])} MXN',
          icon: Icons.payments_outlined,
        ),
        const SizedBox(height: 12),
        _resultCard(
          title: 'Total estimado a pagar',
          value: '\$${_money(resultado['total_pagar'])} MXN',
          icon: Icons.receipt_long_outlined,
        ),
        const SizedBox(height: 12),
        _resultCard(
          title: 'Intereses estimados',
          value: '\$${_money(resultado['intereses_estimados'])} MXN',
          icon: Icons.trending_up_outlined,
        ),
        const SizedBox(height: 12),
        _resultCard(
          title: 'Porcentaje del ingreso',
          value: '${_percent(resultado['porcentaje_ingreso'])}%',
          icon: Icons.pie_chart_outline,
        ),
        const SizedBox(height: 12),
        _resultCard(
          title: 'Nivel de riesgo estimado',
          value: riesgo,
          icon: Icons.warning_amber_rounded,
          color: riesgoColor,
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(.35),
            ),
          ),
          child: const Text(
            'Este simulador es solo una estimación. La aprobación real depende de documentos, historial crediticio, ingresos comprobables y políticas de la institución.',
            style: TextStyle(
              color: Color(0xFF7C5E00),
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        title: const Text(
          'Simulador de crédito',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: .045,
              child: Image.asset(
                'assets/iconos/mazo-libro.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                decoration: const BoxDecoration(
                  color: Color(0xFF111827),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calculadora crediticia',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Calcula pagos aproximados, total estimado y nivel de riesgo.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _contenido()),
            ],
          ),
        ],
      ),
    );
  }
}