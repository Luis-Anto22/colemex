import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/panel_cliente.dart';
import 'screens/panel_abogado.dart';
import 'screens/panel_admin.dart';
import 'screens/crear_caso_screen.dart';
import 'screens/editar_caso_screen.dart';
import 'screens/subir_archivo_screen.dart';
import 'screens/ubicacion_despacho_screen.dart';
import 'screens/buscar_abogado_map_screen.dart';
import 'screens/registro_socio_screen.dart';
import 'screens/home_public_screen.dart'; // 👈 Pantalla de bienvenida
import 'screens/registro_usuario_screen.dart'; // 👈 Pantalla de registro usuario

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePublicScreen(),
        '/login': (context) => const LoginScreen(),
        '/panel-cliente': (context) => const PanelCliente(),
        '/panel-abogado': (context) => const PanelAbogado(),
        '/panel-admin': (context) => const PanelAdmin(),
        '/crear-caso': (context) => const CrearCasoScreen(),
        '/editar-caso': (context) => const EditarCasoScreen(),
        '/subir-documento': (context) => const SubirArchivoScreen(),
        '/buscar-abogado': (context) => const BuscarAbogadoMapScreen(),
        '/registro-socio': (context) => const RegistroSocioScreen(),
        '/registro-usuario': (context) => const RegistroUsuarioScreen(), // ✅ Ruta agregada
        '/ubicacion-despacho': (context) {
          final route = ModalRoute.of(context);
          final args = route?.settings.arguments;
          if (args is Map<String, dynamic> && args.containsKey('id') && args['id'] is int) {
            return UbicacionDespachoScreen(idAbogado: args['id'] as int);
          }
          return const Scaffold(
            body: Center(
              child: Text(
                '❌ Argumentos inválidos para ubicación del despacho',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      },
    );
  }
}