import 'package:flutter/material.dart';

class UiHelpers {
  /// Encabezado de sección con título y subtítulo opcional
  static Widget sectionHeader(BuildContext context, String title, {String? subtitle}) {
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

  /// Contenedor tipo tarjeta con borde y fondo translúcido
  static Widget card(BuildContext context, {required Widget child}) {
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

  /// Tile con ícono, título, subtítulo y acción al presionar
  static Widget tile(
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

  /// Botón de acción rápida con ícono y etiqueta
  static Widget quickAction(
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

  /// Chip para seleccionar estado profesional (Disponible, Ocupado, Fuera de servicio)
  static Widget estadoChip(
    BuildContext context,
    String label,
    String estadoActual,
    void Function(String) onChange,
  ) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final active = estadoActual == label;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: active ? Colors.black : Colors.white,
        ),
      ),
      selected: active,
      onSelected: (selected) {
        if (selected) onChange(label);
      },
      selectedColor: gold,
      backgroundColor: Colors.white.withOpacity(.06),
      shape: StadiumBorder(
        side: BorderSide(color: gold.withOpacity(.22)),
      ),
    );
  }
}