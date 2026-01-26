import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SoporteScreen extends StatelessWidget {
  const SoporteScreen({super.key});

  Future<void> _abrir(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Soporte técnico')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(Icons.support_agent, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text('Soporte técnico COLEMEX',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text(
              '¿Problemas con tu cuenta, ubicación o archivos? Contáctanos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _abrir('mailto:soporte@colemex.com?subject=Soporte%20COLEMEX'),
                icon: const Icon(Icons.email),
                label: const Text('Enviar correo'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _abrir('tel:+5210000000000'),
                icon: const Icon(Icons.phone),
                label: const Text('Llamar'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _abrir('https://wa.me/520000000000?text=Hola%20necesito%20soporte%20COLEMEX'),
                icon: const Icon(Icons.chat),
                label: const Text('WhatsApp'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
