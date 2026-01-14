import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Importa tu nuevo contenedor modular
import 'cliente_panels/panel_cliente_ui.dart';

class PanelCliente extends StatefulWidget {
  const PanelCliente({Key? key}) : super(key: key);

  @override
  State<PanelCliente> createState() => _PanelClienteState();
}

class _PanelClienteState extends State<PanelCliente> {
  String nombreUsuario = '';
  int idUsuario = 0;
  List<Map<String, dynamic>> listaCasos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    nombreUsuario = prefs.getString('nombre') ?? 'Usuario';
    idUsuario = prefs.getInt('id') ?? 0;

    debugPrint('ID del cliente cargado: $idUsuario');

    await cargarCasos();
  }

  Future<void> cargarCasos() async {
    final url = Uri.parse('https://corporativolegaldigital.com/api/panel-cliente.php');
    try {
      final respuesta = await http.post(url, body: {
        'id_cliente': idUsuario.toString(),
      });

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        if (datos is Map &&
            datos['status'] == 'success' &&
            datos['casos'] != null &&
            datos['casos'] is List) {
          listaCasos = List<Map<String, dynamic>>.from(datos['casos']);
        } else {
          listaCasos = [];
        }
      } else {
        listaCasos = [];
      }
    } catch (e) {
      debugPrint('Error al cargar casos: $e');
      listaCasos = [];
    }

    if (mounted) {
      setState(() {
        cargando = false;
      });

      // 🚀 Redirige al nuevo PanelClienteUI
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PanelClienteUI(
            nombreUsuario: nombreUsuario,
            listaCasos: listaCasos,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mientras carga datos, muestra un loader
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}