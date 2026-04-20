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

  String _iconoPorServicio(String servicio) {
    final s = servicio.trim().toLowerCase();

    switch (s) {
      case 'abogados':
        return 'assets/iconos/abogados.png';
      case 'ajustadores':
        return 'assets/iconos/ajustadores.png';
      case 'peritos en criminalistica':
        return 'assets/iconos/peritos_criminalistica.png';
      case 'valuadores':
        return 'assets/iconos/valuadores.png';
      case 'investigadores':
        return 'assets/iconos/investigadores.png';
      case 'psicologos':
        return 'assets/iconos/psicologos.png';
      case 'agentes inmobiliarios':
        return 'assets/iconos/agentes_inmobiliarios.png';
      case 'contadores':
        return 'assets/iconos/contadores.png';
      case 'agentes crediticios':
        return 'assets/iconos/agentes_crediticios.png';
      case 'asistencia vial':
        return 'assets/iconos/asistencia_vial.png';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final seleccionadoNormalizado = (seleccionado ?? '').trim();
    final tieneSeleccion = seleccionadoNormalizado.isNotEmpty &&
        servicios.contains(seleccionadoNormalizado);

    final serviciosVisibles =
        tieneSeleccion ? <String>[seleccionadoNormalizado] : servicios;

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final maxWidth = constraints.maxWidth;
        final columns = maxWidth >= 660 ? 4 : (maxWidth >= 330 ? 3 : 2);
        final tileWidth = (maxWidth - (spacing * (columns - 1))) / columns;
        final tileHeight = columns == 4 ? 92.0 : (columns == 3 ? 96.0 : 104.0);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: serviciosVisibles.map((servicio) {
            final selected = servicio == seleccionado;
            final iconoAsset = _iconoPorServicio(servicio);

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
                    constraints: BoxConstraints(minHeight: tileHeight),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
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
                            SizedBox(
                              width: selected ? 90 : 96,
                              height: selected ? 90 : 96,
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: iconoAsset.isEmpty
                                    ? Icon(
                                        Icons.miscellaneous_services_rounded,
                                        size: columns == 3 ? 30 : 34,
                                        color: selected
                                            ? Colors.white
                                            : const Color(0xFF2E3E52),
                                      )
                                    : Image.asset(
                                        iconoAsset,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.miscellaneous_services_rounded,
                                            size: columns == 3 ? 30 : 34,
                                            color: selected
                                                ? Colors.white
                                                : const Color(0xFF2E3E52),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            const SizedBox(height: 2),
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