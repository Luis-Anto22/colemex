import 'package:flutter/material.dart';
import 'api_service_crediticio.dart';

class AgentePerfil extends StatefulWidget {
  final int? idAgente;

  const AgentePerfil({super.key, this.idAgente});

  @override
  State<AgentePerfil> createState() => _AgentePerfilState();
}

class _AgentePerfilState extends State<AgentePerfil> {
  Map<String, dynamic>? perfil;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      // ⚠️ Cuando tengas el endpoint perfil_agente, cámbialo aquí
      final data = await ApiServiceCrediticio.perfilAgente(widget.idAgente ?? 0);
      setState(() {
        perfil = data;
        cargando = false;
      });
    } catch (e) {
      debugPrint("❌ Error al cargar perfil: $e");
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = perfil?["nombre"] ?? "Agente desconocido";
    final correo = perfil?["correo"] ?? "correo@ejemplo.com";
    final especialidad = perfil?["especialidad"] ?? "Sin especialidad";
    final ciudad = perfil?["ciudad"] ?? "Ciudad no definida";
    final estado = perfil?["estado"] ?? "No disponible";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil del Agente Crediticio"),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto de perfil
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              const AssetImage("assets/iconos/logo.png"),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nombre
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Correo
                      Row(
                        children: [
                          const Icon(Icons.email, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(correo),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Especialidad
                      Row(
                        children: [
                          const Icon(Icons.work, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text("Especialidad: $especialidad"),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Ciudad
                      Row(
                        children: [
                          const Icon(Icons.location_city, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text("Ciudad: $ciudad"),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Estado
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: estado.toLowerCase() == "disponible"
                                ? Colors.green
                                : Colors.red,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text("Estado: $estado"),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ID del agente
                      if (widget.idAgente != null)
                        Center(
                          child: Text(
                            "ID del agente: ${widget.idAgente}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Botón de editar perfil
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Función de editar perfil en desarrollo"),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("Editar Perfil"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}