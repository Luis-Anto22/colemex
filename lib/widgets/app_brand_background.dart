import 'package:flutter/material.dart';

class AppBrandBackground extends StatelessWidget {
  final Widget child;

  const AppBrandBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoTint = isDark ? Colors.white : const Color(0xFF0B2545);

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        IgnorePointer(
          // Marca de agua global del logo: visible en todas las pantallas sin
          // bloquear interaccion ni competir con el contenido principal.
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final centerSize = (width * 0.5).clamp(180.0, 360.0);
              final cornerSize = (width * 0.28).clamp(110.0, 220.0);

              Widget logo(double size, double opacity) {
                return Opacity(
                  opacity: opacity,
                  child: ColorFiltered(
                    // Unifica el color del logo para que se perciba
                    // consistentemente sobre pantallas claras y oscuras.
                    colorFilter: ColorFilter.mode(
                      logoTint.withValues(alpha: 0.45),
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/iconos/logo.png',
                      width: size,
                      height: size,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  Positioned(
                    left: (width - centerSize) / 2,
                    top: (height - centerSize) / 2,
                    child: logo(centerSize, 0.12),
                  ),
                  Positioned(
                    top: -16,
                    right: -16,
                    child: logo(cornerSize, 0.08),
                  ),
                  Positioned(
                    left: -18,
                    bottom: -14,
                    child: logo(cornerSize * 0.92, 0.07),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
