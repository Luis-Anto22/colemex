import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PanelAdmin extends StatefulWidget {
  const PanelAdmin({Key? key}) : super(key: key);

  @override
  State<PanelAdmin> createState() => _PanelAdminState();
}

class _PanelAdminState extends State<PanelAdmin> {
  String nombre = '';
  bool validando = true;
  bool cargandoAbogados = true;
  String mensajeError = '';
  List<Map<String, dynamic>> abogados = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }
    Future<void> cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final nombreGuardado = prefs.getString('nombre') ?? '';
    final perfilGuardado = prefs.getString('perfil') ?? '';

    if (perfilGuardado.toLowerCase() != 'admin') {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      nombre = nombreGuardado;
      validando = false;
    });

    await cargarAbogados();
  }

  Future<void> cargarAbogados() async {
    final url = Uri.parse('https://corporativolegaldigital.com/api/listar-abogados.php');

    try {
      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body.trim());
        final lista = datos['abogados'];

        if (lista is List && lista.isNotEmpty) {
          setState(() {
            abogados = List<Map<String, dynamic>>.from(lista);
            cargandoAbogados = false;
          });
        } else {
          setState(() {
            mensajeError = 'No hay abogados registrados.';
            cargandoAbogados = false;
          });
        }
      } else {
        setState(() {
          mensajeError = '❌ Error en el servidor: ${respuesta.statusCode}';
          cargandoAbogados = false;
        });
      }
    } catch (e) {
      setState(() {
        mensajeError = '❌ No se pudo conectar al servidor';
        cargandoAbogados = false;
      });
    }
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
    Future<void> abrirRegistroAbogado() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistrarAbogado()),
    );
    if (resultado == true) {
      await cargarAbogados();
    }
  }

  Future<void> abrirEdicionAbogado(int id, String nombreActual) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarAbogado(id: id, nombreActual: nombreActual),
      ),
    );
    if (resultado == true) {
      await cargarAbogados();
    }
  }

  Future<void> eliminarAbogado(int id, String nombreAbogado) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar abogado?'),
        content: Text('¿Estás seguro de eliminar a "$nombreAbogado"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final url = Uri.parse('https://corporativolegaldigital.com/api/eliminar-abogado.php');
      try {
        final respuesta = await http.post(url, body: {
          'id': id.toString(),
        });

        final datos = json.decode(respuesta.body.trim());
        final mensaje = datos['mensaje'] ?? '❌ Error inesperado';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: mensaje.startsWith('✅') ? Colors.green : Colors.red,
          ),
        );

        if (datos['success'] == true) {
          await cargarAbogados();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No se pudo conectar al servidor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
    @override
  Widget build(BuildContext context) {
    if (validando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrador | COLEMEX'),
        backgroundColor: const Color(0xFFD4AF37),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: cargarAbogados,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: cerrarSesion,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👤 Bienvenido, $nombre',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: abrirRegistroAbogado,
              icon: const Icon(Icons.person_add),
              label: const Text('Registrar abogado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Lista de abogados:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: cargandoAbogados
                  ? const Center(child: CircularProgressIndicator())
                  : mensajeError.isNotEmpty
                      ? Center(
                          child: Text(
                            mensajeError,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: abogados.length,
                          itemBuilder: (context, index) {
                            final abogado = abogados[index];
                            final foto = (abogado['foto'] as String?) ?? '';
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: foto.isNotEmpty
                                      ? NetworkImage(foto)
                                      : const AssetImage('assets/default.jpg') as ImageProvider,
                                ),
                                title: Text(
                                  'ID: ${abogado["id"]} - Usuario: ${abogado["nombre"]}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                subtitle: Text(abogado['correo'] ?? 'Sin correo'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.green),
                                      tooltip: 'Editar',
                                      onPressed: () {
                                        abrirEdicionAbogado(
                                          int.parse(abogado["id"].toString()),
                                          abogado["nombre"],
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Eliminar',
                                      onPressed: () {
                                        eliminarAbogado(
                                          int.parse(abogado["id"].toString()),
                                          abogado["nombre"],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
class RegistrarAbogado extends StatefulWidget {
  const RegistrarAbogado({super.key});

  @override
  State<RegistrarAbogado> createState() => _RegistrarAbogadoState();
}

class _RegistrarAbogadoState extends State<RegistrarAbogado> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  bool cargando = false;
  String mensaje = '';

  Future<void> registrar() async {
    final nombre = nombreController.text.trim();
    final contrasena = contrasenaController.text;

    if (nombre.isEmpty || contrasena.isEmpty) {
      setState(() {
        mensaje = '❌ Debes completar todos los campos';
      });
      return;
    }

    setState(() {
      cargando = true;
      mensaje = '';
    });

    final url = Uri.parse('https://corporativolegaldigital.com/api/registrar-abogado.php');

    try {
      final respuesta = await http.post(url, body: {
        'usuario': nombreController.text.trim(),        // clave alineada al JSON de la API
        'contrasena': contrasena,
      });

      final datos = json.decode(respuesta.body.trim());

      setState(() {
        cargando = false;
        mensaje = datos['mensaje'] ?? '❌ Error inesperado';
      });

      if (datos['success'] == true) {
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        mensaje = '❌ No se pudo conectar al servidor';
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Abogado'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: contrasenaController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (mensaje.isNotEmpty)
              Text(
                mensaje,
                style: TextStyle(
                  color: mensaje.startsWith('✅') ? Colors.green : Colors.red,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: cargando ? null : registrar,
              icon: const Icon(Icons.save),
              label: const Text('Registrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class EditarAbogado extends StatefulWidget {
  final int id;
  final String nombreActual;

  const EditarAbogado({super.key, required this.id, required this.nombreActual});

  @override
  State<EditarAbogado> createState() => _EditarAbogadoState();
}

class _EditarAbogadoState extends State<EditarAbogado> {
  late TextEditingController nombreController;
  final TextEditingController contrasenaController = TextEditingController();
  bool cargando = false;
  String mensaje = '';

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.nombreActual);
  }

  Future<void> actualizar() async {
    final nombre = nombreController.text.trim();
    final contrasena = contrasenaController.text;

    if (nombre.isEmpty) {
      setState(() {
        mensaje = '❌ El campo nombre no puede estar vacío';
      });
      return;
    }

    setState(() {
      cargando = true;
      mensaje = '';
    });

    final url = Uri.parse('https://corporativolegaldigital.com/api/actualizar-abogado.php');

    try {
      final respuesta = await http.post(url, body: {
        'id': widget.id.toString(),
        'usuario': nombreController.text.trim(),         // clave alineada al JSON de la API
        'contrasena': contrasena, // puede ir vacío
      });

      final datos = json.decode(respuesta.body.trim());

      setState(() {
        cargando = false;
        mensaje = datos['mensaje'] ?? '❌ Error inesperado';
      });

      if (datos['success'] == true) {
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        mensaje = '❌ No se pudo conectar al servidor';
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Abogado'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nuevo nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: contrasenaController,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña (opcional)',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (mensaje.isNotEmpty)
              Text(
                mensaje,
                style: TextStyle(
                  color: mensaje.startsWith('✅') ? Colors.green : Colors.red,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: cargando ? null : actualizar,
              icon: const Icon(Icons.save),
              label: const Text('Guardar cambios'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}