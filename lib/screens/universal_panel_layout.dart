
import 'package:flutter/material.dart';

class UniversalPanelLayout extends StatefulWidget {
  final String titulo;
  final List<Widget> children;
  final List<Widget>? accionesAppBar;

  const UniversalPanelLayout({
    super.key,
    required this.titulo,
    required this.children,
    this.accionesAppBar,
  });

  @override
  State<UniversalPanelLayout> createState() => _UniversalPanelLayoutState();
}

class _UniversalPanelLayoutState extends State<UniversalPanelLayout> {
  String estado = "Disponible";

  // ---------------- UI HELPERS ----------------

  Widget sectionHeader(BuildContext context, String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              letterSpacing: .2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withOpacity(.70),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget card(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(.06),
        border: Border.all(color: gold.withOpacity(.18)),
      ),
      child: child,
    );
  }

  Widget tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(.05),
          border: Border.all(color: gold.withOpacity(.14)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: gold.withOpacity(.10),
                border: Border.all(color: gold.withOpacity(.18)),
              ),
              child: Icon(icon, color: gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.2,
                      color: Colors.white.withOpacity(.72),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(.60)),
          ],
        ),
      ),
    );
  }

  Widget quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(.05),
            border: Border.all(color: gold.withOpacity(.14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: gold),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget estadoChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final active = estado == label;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: active ? Colors.black : Colors.white,
        ),
      ),
      selected: active,
      onSelected: (_) => setState(() => estado = label),
      selectedColor: gold,
      backgroundColor: Colors.white.withOpacity(.06),
      shape: StadiumBorder(
        side: BorderSide(color: gold.withOpacity(.22)),
      ),
    );
  }

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? theme.primaryColor;

    final shadow = [
      BoxShadow(
        color: Colors.black.withOpacity(.25),
        blurRadius: 22,
        offset: const Offset(0, 10),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
        title: Text(widget.titulo),
        actions: widget.accionesAppBar,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/iconos/mazo-libro.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(.62)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Theme(
                    data: theme.copyWith(
                      textTheme: theme.textTheme.apply(
                        bodyColor: Colors.white,
                        displayColor: Colors.white,
                      ),
                      iconTheme: theme.iconTheme.copyWith(color: Colors.white),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: gold.withOpacity(.18)),
                        color: const Color(0xFF12161C).withOpacity(.82),
                        boxShadow: shadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // HERO
                          card(
                            context,
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: gold.withOpacity(.12),
                                    border: Border.all(color: gold.withOpacity(.20)),
                                  ),
                                  child: Icon(Icons.work_outline, color: gold),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Portal profesional',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Avalúos • Dictámenes • Reportes',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: gold.withOpacity(.22)),
                                    color: Colors.white.withOpacity(.04),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.circle, size: 10, color: gold),
                                      const SizedBox(width: 8),
                                      Text(
                                        estado,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                                                    // ESTADO PROFESIONAL
                          sectionHeader(
                            context,
                            "Estado profesional",
                            subtitle: "Define tu disponibilidad para recibir solicitudes.",
                          ),
                          card(
                            context,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                estadoChip(context, "Disponible"),
                                estadoChip(context, "Ocupado"),
                                estadoChip(context, "Fuera de servicio"),
                              ],
                            ),
                          ),
                          sectionHeader(
                            context,
                            "Base común",
                            subtitle: "Módulos obligatorios para todos los socios.",
                          ),
                          ...widget.children,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}