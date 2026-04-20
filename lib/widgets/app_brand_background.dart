import 'package:flutter/material.dart';

class AppBrandBackground extends StatelessWidget {
  final Widget child;

  const AppBrandBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
                  child: Image.asset(
                    'assets/iconos/logo.png',
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                  ),
                );
              }

              return Stack(
                children: [
                  Positioned(
                    left: (width - centerSize) / 2,
                    top: (height - centerSize) / 2,
                    child: logo(centerSize, 0.18),
                  ),
                  Positioned(
                    top: -16,
                    right: -16,
                    child: logo(cornerSize, 0.11),
                  ),
                  Positioned(
                    left: -18,
                    bottom: -14,
                    child: logo(cornerSize * 0.92, 0.1),
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
