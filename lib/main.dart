import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Servicios de API
import 'api_service.dart'; // login/estadísticas generales
import 'screens/admin/api_service_profesionales.dart'; // CRUD de profesionales

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
import 'screens/admin/lista_profesionales_screen.dart';
import 'screens/admin/registrar_profesional_screen.dart';
import 'screens/admin/editar_profesional_screen.dart';
import 'screens/admin/estadisticas_general_screen.dart';
import 'screens/agente_crediticio/agente_panel.dart';

// Modelos
import 'screens/admin/abogado.dart';
import 'screens/admin/profesional.dart';

// 👩‍⚕️ Panel psicólogos
import 'screens/psicologos/psicologos.dart';

// 🏠 Panel agentes inmobiliarios
import 'screens/agente_imobiliario/agente_imobiliario.dart';

// ✅ Portales profesionales
import 'screens/contador/contador_panel.dart';
import 'screens/auditor/auditor_panel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Estadísticas generales
    final stats = await ApiService.obtenerEstadisticas();
    debugPrint("📊 Estadísticas iniciales: $stats");

    // Profesionales
    final profesionales = await ApiServiceProfesionales.obtenerProfesionales();
    debugPrint("👥 Profesionales iniciales: ${profesionales.length}");
  } catch (e) {
    debugPrint("❌ Error al obtener datos iniciales: $e");
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
      initialRoute: introVisto ? '/login' : '/home',
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

        // ✅ Abogados
        '/lista-abogados': (context) => const ListaAbogadosScreen(),
        '/registrar-abogado': (context) => const RegistrarAbogadoScreen(),
        '/editar-abogado': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Abogado) return EditarAbogadoScreen(abogado: args);
          return const Scaffold(
            body: Center(child: Text('❌ Argumentos inválidos para editar abogado')),
          );
        },

        // ✅ Profesionales
        '/lista-profesionales': (context) => const ListaProfesionalesScreen(),
        '/registrar-profesional': (context) => const RegistrarProfesionalScreen(),
        '/editar-profesional': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Profesional) {
            return EditarProfesionalScreen(profesional: args);
          }
          return const Scaffold(
            body: Center(child: Text('❌ Argumentos inválidos para editar profesional')),
          );
        },

        // 👩‍⚕️ Psicólogos
        '/panel-psicologos': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int) return PanelPsicologos(psicologoId: args);
          return const Scaffold(
            body: Center(child: Text('❌ Argumentos inválidos para panel psicólogos')),
          );
        },

        // 🏠 Agentes inmobiliarios
        '/panel-inmuebles': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int) return PanelAgentesInmobiliarios(agenteId: args);
          return const Scaffold(
            body: Center(child: Text('❌ Argumentos inválidos para panel inmobiliarios')),
          );
        },

        // ✅ Panel contador
        '/panel-contador': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int && args > 0) {
            return ContadorPanel(idContador: args);
          }
          return const ContadorPanel();
        },

        // ✅ Panel auditor
        '/panel-auditor': (context) => const AuditorPanel(),

        // ✅ Panel agente crediticio
        '/panel-agente': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int && args > 0) {
            return AgentePanel(idAgente: args);
          }
          return const AgentePanel();
        },

        // ✅ Ubicación despacho
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