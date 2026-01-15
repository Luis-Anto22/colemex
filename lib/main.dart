import 'package:colemex/screens/investigador/investigador.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Servicio de API
import 'api_service.dart';

// Screens principales
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
import 'screens/home_public_screen.dart';
import 'screens/registro_usuario_screen.dart';
import 'screens/valuador/valuador.dart';

// Screens admin
import 'screens/admin/panel_admin_home.dart';
import 'screens/admin/lista_abogados_screen.dart';
import 'screens/admin/registrar_abogado_screen.dart';
import 'screens/admin/editar_abogado_screen.dart';
import 'screens/admin/estadisticas_general_screen.dart';

// Modelo
import 'screens/admin/abogado.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Llamada a la API para usar la importación
  try {
    final stats = await ApiService.obtenerEstadisticas();
    debugPrint("📊 Estadísticas iniciales: $stats");
  } catch (e) {
    debugPrint("❌ Error al obtener estadísticas: $e");
  }

  // ✅ Verificamos si ya se mostró la introducción
  final prefs = await SharedPreferences.getInstance();
  final introVisto = prefs.getBool('introVisto') ?? false;

  runApp(MyApp(introVisto: introVisto));
}

class MyApp extends StatelessWidget {
  final bool introVisto;
  const MyApp({super.key, required this.introVisto});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'COLEMEX',
      theme: ThemeData(primarySwatch: Colors.indigo),

      // ✅ Si no ha visto la intro → HomePublicScreen, si ya la vio → LoginScreen
      home: introVisto ? const LoginScreen() : const HomePublicScreen(),

      routes: {
        '/home': (context) => const HomePublicScreen(),
        '/login': (context) => const LoginScreen(),
        '/panel-cliente': (context) => const PanelCliente(),
        '/panel-abogado': (context) => const PanelAbogado(),
        '/panel-admin': (context) => const PanelAdmin(),
        '/panel-admin-home': (context) => const PanelAdminHome(),
        '/panel-valuador': (context) => const PanelValuadorScreen(),
        '/panel-investigador': (context) => const PanelInvestigadorScreen(),
        '/crear-caso': (context) => const CrearCasoScreen(),
        '/editar-caso': (context) => const EditarCasoScreen(),
        '/subir-documento': (context) => const SubirArchivoScreen(),
        '/buscar-abogado': (context) => const BuscarAbogadoMapScreen(),
        '/registro-socio': (context) => const RegistroSocioScreen(),
        '/registro-usuario': (context) => const RegistroUsuarioScreen(),
        '/estadisticas': (context) => const EstadisticasGeneralScreen(),
        '/lista-abogados': (context) => const ListaAbogadosScreen(),
        '/registrar-abogado': (context) => const RegistrarAbogadoScreen(),
        '/editar-abogado': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Abogado) return EditarAbogadoScreen(abogado: args);
          return const Scaffold(
            body: Center(
              child: Text('❌ Argumentos inválidos para editar abogado'),
            ),
          );
        },
        '/ubicacion-despacho': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic> && args['id'] is int) {
            return UbicacionDespachoScreen(idAbogado: args['id'] as int);
          }
          return const Scaffold(
            body: Center(
              child: Text('❌ Argumentos inválidos para ubicación del despacho'),
            ),
          );
        },
      },
    );
  }
}