import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens principales
import 'screens/login_screen.dart';
import 'screens/panel_cliente.dart';
import 'screens/abogados/panel_abogado.dart';
import 'screens/abogados/crear_caso_screen.dart';
import 'screens/abogados/editar_caso_screen.dart';
import 'screens/abogados/ubicacion_despacho_screen.dart';
import 'screens/abogados/buscar_abogado_map_screen.dart';
import 'screens/registro_socio_screen.dart';
import 'screens/home_public_screen.dart';
import 'screens/registro_usuario_screen.dart';

// Screens admin
import 'screens/admin/panel_admin_home.dart';
import 'screens/admin/lista_profesionales_screen.dart';
import 'screens/admin/registrar_profesional_screen.dart';
import 'screens/admin/editar_profesional_screen.dart';
import 'screens/agente_crediticio/agente_panel.dart';

// Modelos
import 'screens/admin/profesional.dart';

// Psicólogos
import 'screens/psicologos/psicologos.dart';

// Agentes inmobiliarios
import 'screens/agente_imobiliario/agente_imobiliario.dart';

// Profesionales
import 'screens/contador/contador_panel.dart';
import 'screens/auditor/auditor_panel.dart';
import 'screens/investigador/investigador.dart';
import 'screens/perito_criminalistica/perito.dart';
import 'screens/ajustador/ajustador.dart';
import 'screens/valuador/valuador.dart';
import 'screens/asistencia_vial/asistencia_vial_panel.dart';
import 'widgets/app_brand_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool introVisto = prefs.getBool('introVisto') ?? false;
  final bool sesionActiva = prefs.getBool('sesion_activa') ?? false;
  final String token = prefs.getString('token') ?? '';
  final String perfil = prefs.getString('perfil') ?? '';
  final int id = prefs.getInt('id') ?? 0;

  runApp(
    MyApp(
      introVisto: introVisto,
      sesionActiva: sesionActiva,
      token: token,
      perfil: perfil,
      id: id,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool introVisto;
  final bool sesionActiva;
  final String token;
  final String perfil;
  final int id;

  const MyApp({
    super.key,
    required this.introVisto,
    required this.sesionActiva,
    required this.token,
    required this.perfil,
    required this.id,
  });

  String _rutaInicial() {
    if (!introVisto) {
      return '/home';
    }

    if (sesionActiva && token.isNotEmpty && perfil.isNotEmpty && id > 0) {
      switch (perfil) {
        case 'admin':
        case 'administrador':
          return '/panel-admin-home';

        case 'cliente':
          return '/panel-cliente';

        case 'abogado':
        case 'abogados':
          return '/panel-abogado';

        case 'psicologo':
        case 'psicologos':
          return '/panel-psicologos';

        case 'investigador':
        case 'investigadores':
          return '/panel-investigador';

        case 'valuador':
        case 'valuadores':
          return '/panel-valuador';

        case 'agente_inmobiliario':
        case 'agentes_inmobiliarios':
          return '/panel-inmuebles';

        case 'contadores':
          return '/panel-contador';

        case 'auditor':
        case 'auditores':
          return '/panel-auditor';

        case 'perito_en_criminalistica':
        case 'perito_criminalistica':
        case 'peritos_en_criminalistica':
        case 'peritos':
          return '/panel-perito';

        case 'ajustador':
        case 'ajustadores':
          return '/panel-ajustador';

        case 'agente_crediticio':
        case 'agentes_crediticios':
          return '/panel-agente';

        case 'asistencia_vial':
          return '/panel-asistencia-vial';

        default:
          return '/login';
      }
    }

    return '/login';
  }

  @override
  Widget build(BuildContext context) {
    final String initialRoute = _rutaInicial();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advocatus',
      builder: (context, child) {
        // Aplica el logo como fondo global tipo marca de agua
        // para mantener identidad visual consistente en toda la app.
        return AppBrandBackground(
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.indigo,
        ).copyWith(
          secondary: const Color(0xFFD4AF37),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/home': (context) => const HomePublicScreen(),
        '/login': (context) => const LoginScreen(),
        '/panel-cliente': (context) => const PanelCliente(),
        '/panel-abogado': (context) => const PanelAbogado(),
        '/panel-admin-home': (context) => const PanelAdminHome(),
        '/crear-caso': (context) => const CrearCasoScreen(),
        '/editar-caso': (context) => const EditarCasoScreen(),
        '/buscar-abogado': (context) => const BuscarAbogadoMapScreen(),
        '/registro-socio': (context) => const RegistroSocioScreen(),
        '/registro-usuario': (context) => const RegistroUsuarioScreen(),

        '/lista-abogados': (context) => const ListaProfesionalesScreen(),
        '/registrar-abogado': (context) => const RegistrarProfesionalScreen(),
        '/editar-abogado': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Profesional) {
            return EditarProfesionalScreen(profesional: args);
          }
          return const Scaffold(
            body: Center(
              child: Text('❌ Argumentos inválidos para editar abogado'),
            ),
          );
        },

        '/lista-profesionales': (context) => const ListaProfesionalesScreen(),
        '/registrar-profesional': (context) => const RegistrarProfesionalScreen(),
        '/editar-profesional': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Profesional) {
            return EditarProfesionalScreen(profesional: args);
          }
          return const Scaffold(
            body: Center(
              child: Text('❌ Argumentos inválidos para editar profesional'),
            ),
          );
        },

        '/panel-psicologos': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int) return PanelPsicologos(psicologoId: args);
          return const Scaffold(
            body: Center(
              child: Text('❌ Argumentos inválidos para panel psicólogos'),
            ),
          );
        },

        '/panel-investigador': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int) {
            return PanelInvestigadorScreen(investigadorId: args);
          }
          return const Scaffold(
            body: Center(
              child: Text('❌ Argumentos inválidos para panel investigador'),
            ),
          );
        },

        '/panel-valuador': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int) {
            return PanelValuadorScreen(valuadorId: args);
          }
          return const Scaffold(
            body: Center(
              child: Text('❌ Argumentos inválidos para panel valuador'),
            ),
          );
        },

        '/panel-inmuebles': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int) return PanelAgentesInmobiliarios(agenteId: args);
          return const Scaffold(
            body: Center(
              child: Text('❌ Argumentos inválidos para panel inmobiliarios'),
            ),
          );
        },

        '/panel-contador': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int && args > 0) {
            return ContadorPanel(idContador: args);
          }
          return const ContadorPanel();
        },

        '/panel-auditor': (context) => const AuditorPanel(),

        '/panel-agente': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int && args > 0) {
            return AgentePanel(idAgente: args);
          }
          return const AgentePanel();
        },

        '/panel-perito': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int && args > 0) {
            return PanelPeritoScreen(peritoId: args);
          }
          return const Scaffold(
            body: Center(
              child: Text('❌ Argumentos inválidos para panel perito'),
            ),
          );
        },

        '/panel-ajustador': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int && args > 0) {
            return PanelAjustadorScreen(ajustadorId: args);
          }
          return const Scaffold(
            body: Center(
              child: Text('❌ Argumentos inválidos para panel ajustador'),
            ),
          );
        },

        '/panel-asistencia-vial': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int && args > 0) {
            return PanelAsistenciaVial(asistenciaId: args);
          }
          return const Scaffold(
            body: Center(
              child: Text('❌ Argumentos inválidos para panel asistencia vial'),
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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/panel-cliente':
            final args = settings.arguments;
            if (args is int) {
              return MaterialPageRoute(
                builder: (_) => const PanelCliente(),
                settings: settings,
              );
            }
            return MaterialPageRoute(
              builder: (_) => const PanelCliente(),
              settings: settings,
            );

          case '/panel-abogado':
            final args = settings.arguments;
            if (args is int) {
              return MaterialPageRoute(
                builder: (_) => const PanelAbogado(),
                settings: settings,
              );
            }
            return MaterialPageRoute(
              builder: (_) => const PanelAbogado(),
              settings: settings,
            );

          default:
            return null;
        }
      },
    );
  }
}
