import 'package:flutter/material.dart';

class PerfilVerificadoScreen extends StatelessWidget {
  const PerfilVerificadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil profesional verificado')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.verified_user_outlined, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text(
              'Completa y verifica tu perfil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Aquí puedes mostrar el estado de verificación y solicitar validación de documentos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            _item('Foto de rostro', true),
            _item('Identificación oficial', false),
            _item('Comprobante de domicilio', false),
            _item('Cédula / Certificación', false),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🧩 Subida de documentos pendiente de conectar')),
                  );
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Subir documentos'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _item(String title, bool ok) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(ok ? Icons.check_circle : Icons.cancel,
          color: ok ? Colors.green : Colors.red),
      title: Text(title),
      subtitle: Text(ok ? 'Completado' : 'Pendiente'),
    );
  }
}
