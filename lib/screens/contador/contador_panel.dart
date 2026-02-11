import 'package:flutter/material.dart';
import 'contador_dashboard.dart';
import 'contador_casos.dart';
import 'contador_perfil.dart';
import 'api_service_contador.dart'; // Servicio de contador
import '../ui_helpers.dart'; // Helpers compartidos
import '../universal_panel_layout.dart';
import '../universal_menu.dart';
import '../universal_location_button.dart';
import '../localizacion.dart';

class ContadorPanel extends StatefulWidget {
  final int? idContador; // 👈 opcional

  const ContadorPanel({super.key, this.idContador});

  @override
  State<ContadorPanel> createState() => _ContadorPanelState();
}

class _ContadorPanelState extends State<ContadorPanel> {
  bool _activo = true;
  bool _verificado = false;
  int _rating = 0;
  int _notificaciones = 0;

  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _perfil; // 👈 aquí guardamos el perfil completo

  @override
  void initState() {
    super.initState();

    if (widget.idContador != null && widget.idContador! > 0) {
      _fetchPerfil(widget.idContador!);
      _fetchNotificaciones(widget.idContador!);
    } else {
      _isLoading = false;
    }
  }

  Future<void> _fetchPerfil(int id) async {
    try {
      final perfil = await ApiServiceContador.obtenerPerfil(id);

      if (perfil.isNotEmpty) {
        setState(() {
          _perfil = perfil;
          _activo = perfil["estado"] == "disponible";
          _verificado = perfil["verificado"] == 1;
          _rating = perfil["rating"] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "No se pudo cargar el perfil";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error al obtener perfil: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNotificaciones(int id) async {
    try {
      setState(() {
        _notificaciones = 3; // Ejemplo de prueba
      });
    } catch (e) {
      setState(() {
        _error = "Error al obtener notificaciones: $e";
      });
    }
  }

  void _toast(String msg) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Text(
            "❌ Error: $_error",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return UniversalPanelLayout(
      titulo: "Portal • Contador",
      accionesAppBar: [
        IconButton(
          tooltip: 'Configuración',
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Aquí puedes abrir pantalla de configuración
          },
        ),
        UniversalMenu(
          onSelected: (value) {
            if (value == 'cerrar') {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
        ),
      ],
      children: [
        // 👤 Encabezado con perfil
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.blueGrey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(_perfil?["nombre"] ?? "Contador"),
          subtitle: Text(_activo ? "Disponible" : "No disponible"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ⭐ Rating
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Icon(
                _verificado ? Icons.verified : Icons.error,
                color: _verificado ? Colors.greenAccent : Colors.redAccent,
              ),
            ],
          ),
        ),
        const Divider(),

        // 🔹 Acciones rápidas
        UiHelpers.sectionHeader(context, "Acciones rápidas"),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: Row(
            children: [
              UiHelpers.quickAction(
                context,
                icon: Icons.dashboard,
                label: "Dashboard",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContadorDashboard(idContador: widget.idContador ?? 0),
                  ),
                ),
              ),
              UiHelpers.quickAction(
                context,
                icon: Icons.folder,
                label: "Casos",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContadorCasos(idContador: widget.idContador ?? 0),
                  ),
                ),
              ),
              UiHelpers.quickAction(
                context,
                icon: Icons.description,
                label: "Documentos",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContadorDashboard(idContador: widget.idContador ?? 0),
                  ),
                ),
              ),
              UiHelpers.quickAction(
                context,
                icon: Icons.person,
                label: "Perfil",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContadorPerfil(idContador: widget.idContador ?? 0),
                  ),
                ),
              ),
              UiHelpers.quickAction(
                context,
                icon: Icons.location_on_outlined,
                label: "Ubicación",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LocalizacionPanel(
                      idProfesional: widget.idContador ?? 0,
                      perfil: "Contadores",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        // 🔹 Sección base común
        UiHelpers.sectionHeader(context, "Base común", subtitle: "Módulos obligatorios"),
        UiHelpers.tile(
          context,
          icon: Icons.attach_money,
          title: "Ingresos",
          subtitle: "Comisiones acumuladas",
          onTap: () {
            // Aquí abrir pantalla de ingresos
          },
        ),
        const SizedBox(height: 12),
        UiHelpers.tile(
          context,
          icon: Icons.notifications,
          title: "Notificaciones",
          subtitle: "Avisos y alertas ($_notificaciones)",
          onTap: () {
            _toast("Tienes $_notificaciones notificaciones pendientes");
          },
        ),

        const SizedBox(height: 20),
        if (_perfil?["latitud"] != null && _perfil?["longitud"] != null)
          UniversalLocationButton(
            idProfesional: widget.idContador ?? 0,
            lat: _perfil!["latitud"],
            lng: _perfil!["longitud"],
          ),

        const SizedBox(height: 20),
        Text(
          'Tip: Mantén tu perfil y estado actualizados para recibir más casos.',
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.65)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}