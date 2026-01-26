import 'package:flutter/material.dart';
import 'api_service_contador.dart'; // Importa tu servicio de contador

class ContadorPerfil extends StatefulWidget {
  final int idContador;

  const ContadorPerfil({super.key, required this.idContador});

  @override
  State<ContadorPerfil> createState() => _ContadorPerfilState();
}

class _ContadorPerfilState extends State<ContadorPerfil> {
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _perfil;

  bool _activo = true;
  bool _verificado = false;
  int _rating = 0;

  @override
  void initState() {
    super.initState();

    if (widget.idContador > 0) {
      _fetchPerfil();
    } else {
      setState(() {
        _isLoading = false;
        _perfil = null;
      });
    }
  }

  Future<void> _fetchPerfil() async {
    try {
      final data = await ApiServiceContador.obtenerPerfil(widget.idContador);

      if (data["success"] == true && data["perfil"] != null) {
        final perfil = data["perfil"];
        setState(() {
          _perfil = perfil;
          _activo = perfil["activo"] == 1;
          _verificado = perfil["verificado"] == 1;
          _rating = perfil["rating"] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data["mensaje"] ?? "No hay datos disponibles";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil del Contador"),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("❌ $_error"))
              : widget.idContador == 0
                  ? Center(
                      child: Text(
                        "Aún no hay contadores registrados.\nCuando se agregue uno, verás aquí su perfil.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    )
                  : (_perfil == null || _perfil!.isEmpty)
                      ? Center(
                          child: Text(
                            "Este contador aún no tiene información de perfil disponible.",
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        )
                      : Padding(
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
                                  // ✅ CircleAvatar sin backgroundImage
                                  const Center(
                                    child: CircleAvatar(
                                      radius: 50,
                                      child: Icon(Icons.person, size: 50),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  Text(
                                    _perfil?["nombre"] ?? "Sin nombre",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      const Icon(Icons.email, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(_perfil?["correo"] ?? "Sin correo"),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      const Icon(Icons.work, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text("Especialidad: ${_perfil?["especialidad"] ?? "N/A"}"),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      const Icon(Icons.location_city, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text("Ciudad: ${_perfil?["ciudad"] ?? "N/A"}"),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber),
                                      const SizedBox(width: 8),
                                      Text("Calificación: $_rating / 5"),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Estado:"),
                                      Switch(
                                        value: _activo,
                                        activeColor: Colors.green,
                                        inactiveThumbColor: Colors.red,
                                        onChanged: (value) {
                                          setState(() {
                                            _activo = value;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(value
                                                  ? "Contador activado: recibirá casos y aparecerá en el mapa"
                                                  : "Contador desactivado: no recibirá casos ni aparecerá en el mapa"),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  Row(
                                    children: [
                                      Icon(
                                        _verificado ? Icons.verified : Icons.error,
                                        color: _verificado ? Colors.green : Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(_verificado
                                          ? "Verificado como prestador honorable"
                                          : "Pendiente de verificación"),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  Center(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFD4AF37),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Función de editar perfil en desarrollo"),
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