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

// Screens admin
import 'screens/admin/panel_admin_home.dart';
import 'screens/admin/lista_abogados_screen.dart';
import 'screens/admin/registrar_abogado_screen.dart';
import 'screens/admin/editar_abogado_screen.dart';
import 'screens/admin/estadisticas_general_screen.dart';
import 'screens/agente_crediticio/agente_panel.dart';

// Modelo
import 'screens/admin/abogado.dart';

// ✅ Portales profesionales
import 'screens/contador/contador_panel.dart';
import 'screens/auditor/auditor_panel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final stats = await ApiService.obtenerEstadisticas();
    debugPrint("📊 Estadísticas iniciales: $stats");
  } catch (e) {
    debugPrint("❌ Error al obtener estadísticas: $e");
  }

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.indigo,
        ).copyWith(
          secondary: const Color(0xFFD4AF37),
        ),
      ),
      initialRoute: '/panel-agente',
      routes: {
        '/home': (context) => const HomePublicScreen(),
        '/login': (context) => const LoginScreen(),
        '/panel-cliente': (context) => const PanelCliente(),
        '/panel-abogado': (context) => const PanelAbogado(),
        '/panel-admin': (context) => const PanelAdmin(),
        '/panel-admin-home': (context) => const PanelAdminHome(),
        '/crear-caso': (context) => const CrearCasoScreen(),
        '/editar-caso': (context) => const EditarCasoScreen(),
        '/subir-documento': (context) => const SubirArchivoScreen(),
        '/buscar-abogado': (context) => const BuscarAbogadoMapScreen(),
        '/registro-socio': (context) => const RegistroSocioScreen(),
        '/registro-usuario': (context) => const RegistroUsuarioScreen(),
        '/estadisticas': (context) => const EstadisticasGeneralScreen(),
        '/lista-abogados': (context) => const ListaAbogadosScreen(),
        '/registrar-abogado': (context) => const RegistrarAbogadoScreen(),
        '/panel-auditor': (context) => const AuditorPanel(),

        // ✅ Panel contador con argumentos
        '/panel-contador': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int && args > 0) {
            return ContadorPanel(idContador: args);
          }
          // Si no hay ID, mostramos el panel vacío con mensajes amigables
          return const ContadorPanel();
        },

        // ✅ Rutas con argumentos
        '/editar-abogado': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Abogado) {
            return EditarAbogadoScreen(abogado: args);
          }
          return const Scaffold(
            body: Center(child: Text('❌ Argumentos inválidos para editar abogado')),
          );
        },

        // ✅ Panel agente crediticio
        '/panel-agente': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int && args > 0) {
            return AgentePanel(idAgente: args);
          }
          return const AgentePanel();
        },

        '/ubicacion-despacho': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic> && args['id'] is int) {
            return UbicacionDespachoScreen(idAbogado: args['id'] as int);
          }
          return const Scaffold(
            body: Center(child: Text('❌ Argumentos inválidos para ubicación del despacho')),
          );
        },
      },
    );
  }
}