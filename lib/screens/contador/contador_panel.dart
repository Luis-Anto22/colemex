import 'package:flutter/material.dart';
import 'contador_dashboard.dart';
import 'contador_casos.dart';
import 'contador_perfil.dart';
import 'api_service_contador.dart'; // Servicio de contador
import '../common/ui_helpers.dart'; // Helpers compartidos

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
      final data = await ApiServiceContador.obtenerPerfil(id);

      if (data["success"] == true) {
        setState(() {
          _activo = data["activo"] == 1;
          _verificado = data["verificado"] == 1;
          _rating = data["rating"] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data["mensaje"] ?? "No se pudo cargar el perfil";
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
      // 🔹 Aquí podrías conectar a tu API real de notificaciones
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
    final gold = const Color(0xFFD4AF37);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error != null) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: Text("❌ Error", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // 🔹 Fondo oscuro
      appBar: AppBar(
        title: const Text('Panel de Contadores'),
        backgroundColor: gold,
        elevation: 6,
        actions: [
          // ⭐ Calificación dinámica
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              );
            }),
          ),
          const SizedBox(width: 16),

          // 🔘 Switch Activo/Desactivo
          Row(
            children: [
              const Text("Activo", style: TextStyle(color: Colors.white)),
              Switch(
                value: _activo,
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                onChanged: (value) async {
                  setState(() {
                    _activo = value;
                  });
                  _toast(value
                      ? "Contador activado: recibirá casos y aparecerá en el mapa"
                      : "Contador desactivado: no recibirá casos ni aparecerá en el mapa");
                },
              ),
            ],
          ),
          const SizedBox(width: 16),

          // ✅ Verificación
          Icon(
            _verificado ? Icons.verified : Icons.error,
            color: _verificado ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 8),

          // 🔔 Notificaciones con badge
          Stack(
            children: [
              const Icon(Icons.notifications, color: Colors.white),
              if (_notificaciones > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '$_notificaciones',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionHeader(context, "Acciones rápidas"),
            const SizedBox(height: 16),

            // 🔹 Primera fila
            Row(
              children: [
                Expanded(
                  child: card(context,
                    color: const Color(0xFF1E1E1E), // 🔹 Tarjeta oscura
                    child: tile(context,
                      icon: Icons.dashboard,
                      title: "Dashboard",
                      subtitle: "Resumen general",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContadorDashboard(
                              idContador: widget.idContador ?? 0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: card(context,
                    color: const Color(0xFF1E1E1E),
                    child: tile(context,
                      icon: Icons.folder,
                      title: "Casos",
                      subtitle: "Gestión de casos",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContadorCasos(
                              idContador: widget.idContador ?? 0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 Segunda fila
            Row(
              children: [
                Expanded(
                  child: card(context,
                    color: const Color(0xFF1E1E1E),
                    child: tile(context,
                      icon: Icons.description,
                      title: "Documentos",
                      subtitle: "Tickets y archivos",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContadorDashboard(
                              idContador: widget.idContador ?? 0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: card(context,
                    color: const Color(0xFF1E1E1E),
                    child: tile(context,
                      icon: Icons.person,
                      title: "Perfil",
                      subtitle: "Información personal",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContadorPerfil(
                              idContador: widget.idContador ?? 0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}