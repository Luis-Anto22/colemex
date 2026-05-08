import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/common_api.dart';

class PerfilVerificadoScreen extends StatefulWidget {
  const PerfilVerificadoScreen({super.key});

  @override
  State<PerfilVerificadoScreen> createState() => _PerfilVerificadoScreenState();
}

class _PerfilVerificadoScreenState extends State<PerfilVerificadoScreen> {
  final CommonApi api = CommonApi(ApiClient());

  bool cargando = true;
  bool subiendo = false;

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
      if (!mounted) return;

      setState(() {
        cargando = false;
        mensaje = 'ID no válido';
      });
      return;
    }

    try {
      final data = await api.getPerfil(profesionalId);

      if (!mounted) return;

      final perfilRaw = data['perfil'];
      final documentosRaw = data['documentos'];

      Map<String, dynamic> perfilFinal = {};

      if (perfilRaw is Map) {
        perfilFinal = Map<String, dynamic>.from(perfilRaw);
      } else {
        perfilFinal = Map<String, dynamic>.from(data);

        if (perfilRaw != null) {
          perfilFinal['perfil'] = perfilRaw.toString();
        }
      }

      List<dynamic> documentosFinal = [];

      if (documentosRaw is List) {
        documentosFinal = documentosRaw;
      } else if (data['documentos_perfil'] is List) {
        documentosFinal = data['documentos_perfil'] as List<dynamic>;
      } else if (data['archivos'] is List) {
        documentosFinal = data['archivos'] as List<dynamic>;
      }

      setState(() {
        perfil = perfilFinal;
        documentos = documentosFinal;
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
      if (d is! Map) continue;

      final m = Map<String, dynamic>.from(d);

      if ((m['tipo'] ?? '').toString() == tipo) {
        return (m['estado'] ?? '').toString() == 'validado';
      }
    }

    return false;
  }

  String _docEstado(String tipo) {
    for (final d in documentos) {
      if (d is! Map) continue;

      final m = Map<String, dynamic>.from(d);

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
      case 'revision':
      case 'en_revision':
        return 'En revisión';
      default:
        return 'Pendiente';
    }
  }

  String _nombreProfesional() {
    return (perfil['nombre'] ??
            perfil['nombre_completo'] ??
            perfil['usuario']?['nombre'] ??
            '')
        .toString();
  }

  String _correoProfesional() {
    return (perfil['correo'] ??
            perfil['email'] ??
            perfil['usuario']?['correo'] ??
            '')
        .toString();
  }

  String _perfilProfesional() {
    return (perfil['perfil'] ??
            perfil['tipo_perfil'] ??
            perfil['rol'] ??
            '')
        .toString();
  }

  Future<void> _subirDocumento() async {
    if (profesionalId <= 0) return;

    String tipo = 'foto_rostro';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Subir documento'),
          content: DropdownButtonFormField<String>(
            initialValue: tipo,
            items: const [
              DropdownMenuItem(
                value: 'foto_rostro',
                child: Text('Foto del rostro'),
              ),
              DropdownMenuItem(
                value: 'ine_pasaporte',
                child: Text('INE o pasaporte'),
              ),
              DropdownMenuItem(
                value: 'comprobante_domicilio',
                child: Text('Comprobante de domicilio'),
              ),
              DropdownMenuItem(
                value: 'cedula_certificado',
                child: Text('Cédula o certificado'),
              ),
            ],
            onChanged: (v) => tipo = v ?? 'foto_rostro',
            decoration: const InputDecoration(
              labelText: 'Tipo de documento',
              border: OutlineInputBorder(),
            ),
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
        );
      },
    );

    if (ok != true) return;

    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      allowMultiple: false,
      withData: true,
    );

    if (picked == null || picked.files.isEmpty) return;

    final PlatformFile archivoSeleccionado = picked.files.single;

    if (archivoSeleccionado.bytes == null &&
        (archivoSeleccionado.path == null ||
            archivoSeleccionado.path!.isEmpty)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo leer el archivo seleccionado'),
        ),
      );
      return;
    }

    try {
      setState(() {
        subiendo = true;
      });

      await api.subirDocumentoPerfil(
        profesionalId: profesionalId,
        tipo: tipo,
        file: archivoSeleccionado,
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
    } finally {
      if (mounted) {
        setState(() {
          subiendo = false;
        });
      }
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

    final nombre = _nombreProfesional();
    final correo = _correoProfesional();
    final perfilTexto = _perfilProfesional();

    String encabezado = '';

    if (nombre.isNotEmpty && correo.isNotEmpty) {
      encabezado = '$nombre - $correo';
    } else if (nombre.isNotEmpty) {
      encabezado = nombre;
    } else if (correo.isNotEmpty) {
      encabezado = correo;
    } else if (perfilTexto.isNotEmpty) {
      encabezado = perfilTexto;
    } else {
      encabezado = 'Profesional #$profesionalId';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil profesional verificado'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 64,
              color: gold,
            ),
            const SizedBox(height: 12),
            const Text(
              'Completa y verifica tu perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              mensaje.isNotEmpty ? mensaje : encabezado,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _item(
              'Foto de rostro',
              _docOk('foto_rostro'),
              _estadoLabel(_docEstado('foto_rostro')),
            ),
            _item(
              'INE o pasaporte',
              _docOk('ine_pasaporte'),
              _estadoLabel(_docEstado('ine_pasaporte')),
            ),
            _item(
              'Comprobante de domicilio',
              _docOk('comprobante_domicilio'),
              _estadoLabel(_docEstado('comprobante_domicilio')),
            ),
            _item(
              'Cédula o certificado',
              _docOk('cedula_certificado'),
              _estadoLabel(_docEstado('cedula_certificado')),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: subiendo ? null : _subirDocumento,
                icon: subiendo
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(subiendo ? 'Subiendo...' : 'Subir documentos'),
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