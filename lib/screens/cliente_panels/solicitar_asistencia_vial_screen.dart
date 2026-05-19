import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services/api_client.dart';
import '../../services/api_services/asistencia_vial_api.dart';

class SolicitarAsistenciaVialScreen extends StatefulWidget {
  const SolicitarAsistenciaVialScreen({super.key});

  @override
  State<SolicitarAsistenciaVialScreen> createState() =>
      _SolicitarAsistenciaVialScreenState();
}

class _SolicitarAsistenciaVialScreenState
    extends State<SolicitarAsistenciaVialScreen> {
  final AsistenciaVialApi api = AsistenciaVialApi(ApiClient());

  final marcaCtrl = TextEditingController();
  final modeloCtrl = TextEditingController();
  final anioCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final placasCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();

  bool cargando = true;
  bool enviando = false;
  String mensaje = '';

  int clienteId = 0;
  int? tipoAuxilioId;

  List<dynamic> tipos = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    marcaCtrl.dispose();
    modeloCtrl.dispose();
    anioCtrl.dispose();
    colorCtrl.dispose();
    placasCtrl.dispose();
    descripcionCtrl.dispose();
    direccionCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    clienteId = prefs.getInt('id') ?? 0;

    if (clienteId <= 0) {
      setState(() {
        cargando = false;
        mensaje = 'ID de cliente no válido';
      });
      return;
    }

    try {
      final data = await api.getTiposAuxilio();

      if (!mounted) return;

      setState(() {
        tipos = data;
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

  String _txt(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<void> _solicitar() async {
    if (tipoAuxilioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un tipo de auxilio')),
      );
      return;
    }

    setState(() => enviando = true);

    try {
      await api.crearSolicitud(
        clienteId: clienteId,
        tipoAuxilioId: tipoAuxilioId!,
        vehiculoMarca: marcaCtrl.text.trim(),
        vehiculoModelo: modeloCtrl.text.trim(),
        vehiculoAnio: anioCtrl.text.trim(),
        vehiculoColor: colorCtrl.text.trim(),
        placas: placasCtrl.text.trim(),
        descripcion: descripcionCtrl.text.trim(),
        direccion: direccionCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada correctamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() => enviando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar asistencia vial'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : mensaje.isNotEmpty
              ? Center(child: Text(mensaje))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Icon(Icons.car_repair, size: 64, color: gold),
                    const SizedBox(height: 12),
                    const Text(
                      'Asistencia vial',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecciona el auxilio que necesitas y registra los datos del vehículo.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),

                    DropdownButtonFormField<int>(
                      initialValue: tipoAuxilioId,
                      decoration: _dec('Tipo de auxilio', Icons.build),
                      items: tipos.map<DropdownMenuItem<int>>((item) {
                        final map = Map<String, dynamic>.from(item as Map);
                        final id = _toInt(map['id']);
                        final nombre = _txt(map['nombre'], 'Auxilio');

                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => tipoAuxilioId = value);
                      },
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: marcaCtrl,
                      decoration: _dec('Marca', Icons.directions_car),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: modeloCtrl,
                      decoration: _dec('Modelo', Icons.car_rental),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: anioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _dec('Año', Icons.calendar_month),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: colorCtrl,
                      decoration: _dec('Color', Icons.color_lens),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: placasCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _dec('Placas', Icons.pin),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: direccionCtrl,
                      maxLines: 2,
                      decoration: _dec('Ubicación o referencia', Icons.location_on),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: descripcionCtrl,
                      maxLines: 3,
                      decoration: _dec('Descripción del problema', Icons.notes),
                    ),

                    const SizedBox(height: 22),

                    ElevatedButton.icon(
                      onPressed: enviando ? null : _solicitar,
                      icon: enviando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: Text(enviando ? 'Enviando...' : 'Solicitar servicio'),
                    ),
                  ],
                ),
    );
  }
}