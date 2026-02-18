import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_client.dart';
import '../../../services/common_api.dart';

class PerfilVerificadoScreen extends StatefulWidget {
  const PerfilVerificadoScreen({super.key});

  @override
  State<PerfilVerificadoScreen> createState() => _PerfilVerificadoScreenState();
}

class _PerfilVerificadoScreenState extends State<PerfilVerificadoScreen> {
  final CommonApi api = CommonApi(ApiClient());
  bool cargando = true;
  String mensaje = '';
  Map<String, dynamic> perfil = {};
  List<dynamic> documentos = [];
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
        mensaje = 'ID no valido';
      });
      return;
    }

    try {
      final data = await api.getPerfil(profesionalId);
      if (!mounted) return;
      setState(() {
        perfil = (data['perfil'] as Map<String, dynamic>? ?? {});
        documentos = (data['documentos'] as List<dynamic>? ?? []);
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

  bool _docOk(String tipo) {
    final verificado = (perfil['verificado'] ?? 0).toString() == '1';
    if (verificado) return true;
    for (final d in documentos) {
      final m = d as Map<String, dynamic>;
      if ((m['tipo'] ?? '').toString() == tipo) {
        return (m['estado'] ?? '').toString() == 'validado';
      }
    }
    return false;
  }

  String _docEstado(String tipo) {
    for (final d in documentos) {
      final m = d as Map<String, dynamic>;
      if ((m['tipo'] ?? '').toString() == tipo) {
        return (m['estado'] ?? '').toString();
      }
    }
    return 'pendiente';
  }

  String _estadoLabel(String estado) {
    switch (estado) {
      case 'validado':
        return 'Validado';
      case 'rechazado':
        return 'Rechazado';
      default:
        return 'Pendiente';
    }
  }

  Future<void> _subirDocumento() async {
    if (profesionalId <= 0) return;

    String tipo = 'foto_rostro';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Subir documento'),
        content: DropdownButtonFormField<String>(
          initialValue: tipo,
          items: const [
            DropdownMenuItem(value: 'foto_rostro', child: Text('Foto del rostro')),
            DropdownMenuItem(value: 'ine_pasaporte', child: Text('INE o pasaporte')),
            DropdownMenuItem(
                value: 'comprobante_domicilio',
                child: Text('Comprobante de domicilio')),
            DropdownMenuItem(
                value: 'cedula_certificado', child: Text('Cedula o certificado')),
          ],
          onChanged: (v) => tipo = v ?? 'foto_rostro',
          decoration: const InputDecoration(labelText: 'Tipo de documento'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final picked = await FilePicker.platform.pickFiles();
    if (picked == null || picked.files.isEmpty) return;
    final path = picked.files.single.path;
    if (path == null) return;

    try {
      await api.subirDocumentoPerfil(
        profesionalId: profesionalId,
        tipo: tipo,
        file: File(path),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento subido')),
      );
      await _cargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
            Text(
              mensaje.isNotEmpty
                  ? mensaje
                  : '${perfil['nombre'] ?? ''} - ${perfil['correo'] ?? ''}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _item('Foto de rostro', _docOk('foto_rostro'),
                _estadoLabel(_docEstado('foto_rostro'))),
            _item('INE o pasaporte', _docOk('ine_pasaporte'),
                _estadoLabel(_docEstado('ine_pasaporte'))),
            _item(
                'Comprobante de domicilio',
                _docOk('comprobante_domicilio'),
                _estadoLabel(_docEstado('comprobante_domicilio'))),
            _item('Cedula o certificado', _docOk('cedula_certificado'),
                _estadoLabel(_docEstado('cedula_certificado'))),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _subirDocumento,
                icon: const Icon(Icons.upload_file),
                label: const Text('Subir documentos'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _item(String title, bool ok, String estado) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        ok ? Icons.check_circle : Icons.cancel,
        color: ok ? Colors.green : Colors.red,
      ),
      title: Text(title),
      subtitle: Text(ok ? 'Completado' : estado),
    );
  }
}
