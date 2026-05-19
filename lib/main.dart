import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/notification_service.dart';

// Screens principales
import 'screens/login_screen.dart';
import 'screens/panel_cliente.dart';
import 'screens/abogados/panel_abogado.dart';
import 'screens/registro_socio_screen.dart';
import 'screens/home_public_screen.dart';
import 'screens/registro_usuario_screen.dart';

// Screens admin
import 'screens/admin/panel_admin_home.dart';
import 'screens/admin/lista_profesionales_screen.dart';
import 'screens/admin/registrar_profesional_screen.dart';
import 'screens/admin/editar_profesional_screen.dart';

// Modelos
import 'screens/admin/profesional.dart';

// Psicólogos
import 'screens/psicologos/psicologos.dart';

// Agentes inmobiliarios
import 'screens/agente_imobiliario/agente_imobiliario.dart';

// Agente crediticio
import 'screens/agente_crediticio/agente_panel.dart';

// Profesionales
import 'screens/contador/contador_panel.dart';
import 'screens/auditor/auditor_panel.dart';
import 'screens/investigador/investigador.dart';
import 'screens/perito_criminalistica/perito.dart';
import 'screens/ajustadores/ajustador.dart';
import 'screens/valuador/valuador.dart';
import 'screens/asistencia_vial/asistencia_vial_panel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationService.init();

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

  String _normalizarPerfil(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(' ', '_');
  }

  String _rutaInicial() {
    if (!introVisto) {
      return '/home';
    }

    if (sesionActiva && token.isNotEmpty && perfil.isNotEmpty && id > 0) {
      final perfilNormalizado = _normalizarPerfil(perfil);

      switch (perfilNormalizado) {
        case 'admin':
        case 'administrador':
          return '/panel-admin-home';

        case 'cliente':
        case 'clientes':
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

        case 'contador':
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

  int _obtenerIdDesdeArgs(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is int && args > 0) {
      return args;
    }

    if (args is Map) {
      final rawId = args['id'] ??
          args['profesional_id'] ??
          args['usuario_id'] ??
          args['ajustadorId'] ??
          args['abogadoId'] ??
          args['agenteId'] ??
          args['agente_id'];

      final parsed = int.tryParse(rawId?.toString() ?? '');

      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }

    return id;
  }

  int _obtenerIdDesdeSettings(RouteSettings settings) {
    final args = settings.arguments;

    if (args is int && args > 0) {
      return args;
    }

    if (args is Map) {
      final rawId = args['id'] ??
          args['profesional_id'] ??
          args['usuario_id'] ??
          args['ajustadorId'] ??
          args['abogadoId'] ??
          args['agenteId'] ??
          args['agente_id'];

      final parsed = int.tryParse(rawId?.toString() ?? '');

      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }

    return id;
  }

  Widget _errorSinId(String panel) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error de sesión'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Text(
            '❌ No se pudo identificar el ID para $panel. Vuelve a iniciar sesión.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String initialRoute = _rutaInicial();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advocatus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.indigo,
        ).copyWith(
          secondary: const Color(0xFFD4AF37),
        ),
        primaryColor: const Color(0xFFD4AF37),
      ),
      initialRoute: initialRoute,
      routes: {
        '/home': (context) => const HomePublicScreen(),
        '/login': (context) => const LoginScreen(),
        '/panel-cliente': (context) => const PanelCliente(),
        '/panel-admin-home': (context) => const PanelAdminHome(),
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
        '/registrar-profesional': (context) =>
            const RegistrarProfesionalScreen(),

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
          final profesionalId = _obtenerIdDesdeArgs(context);

          if (profesionalId > 0) {
            return PanelPsicologos(psicologoId: profesionalId);
          }

          return _errorSinId('panel psicólogos');
        },

        '/panel-investigador': (context) {
          final profesionalId = _obtenerIdDesdeArgs(context);

          if (profesionalId > 0) {
            return PanelInvestigadorScreen(investigadorId: profesionalId);
          }

          return _errorSinId('panel investigador');
        },

        '/panel-valuador': (context) {
          final profesionalId = _obtenerIdDesdeArgs(context);

          if (profesionalId > 0) {
            return PanelValuadorScreen(valuadorId: profesionalId);
          }

          return _errorSinId('panel valuador');
        },

        '/panel-inmuebles': (context) {
          final profesionalId = _obtenerIdDesdeArgs(context);

          if (profesionalId > 0) {
            return PanelAgentesInmobiliarios(agenteId: profesionalId);
          }

          return _errorSinId('panel inmobiliarios');
        },

        '/panel-contador': (context) {
          final profesionalId = _obtenerIdDesdeArgs(context);

          if (profesionalId > 0) {
            return ContadorPanel(idContador: profesionalId);
          }

          return _errorSinId('panel contador');
        },

        '/panel-auditor': (context) => const AuditorPanel(),

        '/panel-agente': (context) {
          final profesionalId = _obtenerIdDesdeArgs(context);

          if (profesionalId > 0) {
            return PanelAgenteCrediticio(agenteId: profesionalId);
          }

          return _errorSinId('panel agente crediticio');
        },

        '/panel-perito': (context) {
          final profesionalId = _obtenerIdDesdeArgs(context);

          if (profesionalId > 0) {
            return PanelPeritoScreen(peritoId: profesionalId);
          }

          return _errorSinId('panel perito');
        },

        '/panel-ajustador': (context) {
          final profesionalId = _obtenerIdDesdeArgs(context);

          if (profesionalId > 0) {
            return PanelAjustadorScreen(ajustadorId: profesionalId);
          }

          return _errorSinId('panel ajustador');
        },

        '/panel-asistencia-vial': (context) {
          final profesionalId = _obtenerIdDesdeArgs(context);

          if (profesionalId > 0) {
            return PanelAsistenciaVial(asistenciaId: profesionalId);
          }

          return _errorSinId('panel asistencia vial');
        },
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/panel-cliente':
            return MaterialPageRoute(
              builder: (_) => const PanelCliente(),
              settings: settings,
            );

          case '/panel-abogado':
            final profesionalId = _obtenerIdDesdeSettings(settings);

            return MaterialPageRoute(
              builder: (_) {
                if (profesionalId > 0) {
                  return PanelAbogadoScreen(abogadoId: profesionalId);
                }

                return _errorSinId('panel abogado');
              },
              settings: settings,
            );

          default:
            return null;
        }
      },
    );
  }
}