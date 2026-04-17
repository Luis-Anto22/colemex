import 'package:flutter/material.dart';

class ServicioSelector extends StatelessWidget {
  static const Color _primary = Color(0xFF0B2545);

  final List<String> servicios;
  final String? seleccionado;
  final ValueChanged<String> onSeleccionar;

  const ServicioSelector({
    super.key,
    required this.servicios,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  IconData _iconoPorServicio(String servicio) {
    switch (servicio) {
      case 'Abogados':
        return Icons.gavel_rounded;
      case 'Ajustadores':
        return Icons.health_and_safety_rounded;
      case 'Peritos en criminalistica':
        return Icons.fingerprint_rounded;
      case 'Valuadores':
        return Icons.home_work_rounded;
      case 'Investigadores':
        return Icons.search_rounded;
      case 'Psicologos':
        return Icons.psychology_rounded;
      case 'Agentes inmobiliarios':
        return Icons.apartment_rounded;
      case 'Contadores':
        return Icons.calculate_rounded;
      case 'Agentes crediticios':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final seleccionadoNormalizado = (seleccionado ?? '').trim();
    final tieneSeleccion = seleccionadoNormalizado.isNotEmpty &&
        servicios.contains(seleccionadoNormalizado);
    final serviciosVisibles = tieneSeleccion
        ? <String>[seleccionadoNormalizado]
        : servicios;

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final maxWidth = constraints.maxWidth;
        final columns = maxWidth >= 660 ? 4 : (maxWidth >= 330 ? 3 : 2);
        final tileWidth = (maxWidth - (spacing * (columns - 1))) / columns;
        final tileHeight =
            columns == 4 ? 90.0 : (columns == 3 ? 85.0 : 95.0);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: serviciosVisibles.map((servicio) {
            final selected = servicio == seleccionado;
            final icon = _iconoPorServicio(servicio);

            return SizedBox(
              width: tileWidth,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onSeleccionar(selected ? '' : servicio),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    constraints: BoxConstraints(
                      minHeight: tileHeight,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0E305A), Color(0xFF1B4E86)],
                            )
                          : null,
                      color: selected ? null : const Color(0xFFFAFCFF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF123A66)
                            : const Color(0xFFD3DFEE),
                        width: selected ? 1.2 : 1,
                      ),
                      boxShadow: [
                        if (selected)
                          BoxShadow(
                            color: _primary.withValues(alpha: 0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (selected)
                          const Positioned(
                            right: 0,
                            top: 0,
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: selected ? 34 : 36,
                              height: selected ? 34 : 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : const Color(0xFFEAF2FD),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                icon,
                                size: columns == 3 ? 19 : 20,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF2E3E52),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              servicio,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}