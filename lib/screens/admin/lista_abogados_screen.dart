import 'package:flutter/material.dart';
import '../../api_service.dart'; // Servicio que consume tus APIs
import 'abogado.dart'; // Modelo dentro de la carpeta admin
import 'detalle_abogado_screen.dart'; // Pantalla de detalle
import 'buscador_abogados_widget.dart'; // Widget buscador
import 'editar_abogado_screen.dart'; // Navegación directa
import 'registrar_abogado_screen.dart'; // Navegación directa

class ListaAbogadosScreen extends StatefulWidget {
  const ListaAbogadosScreen({Key? key}) : super(key: key);

  @override
  State<ListaAbogadosScreen> createState() => _ListaAbogadosScreenState();
}

class _ListaAbogadosScreenState extends State<ListaAbogadosScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Abogado> _abogados = [];
  List<Abogado> _filteredAbogados = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAbogados();
    _searchController.addListener(_filterAbogados);
  }

  Future<void> _fetchAbogados() async {
    try {
      final data = await ApiService.obtenerAbogados();
      setState(() {
        // ✅ Aseguramos que la lista sea de tipo Abogado
        _abogados = data.map((e) => Abogado.fromJson(e)).toList();
        _filteredAbogados = _abogados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterAbogados() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAbogados = _abogados.where((abogado) {
        return abogado.nombre.toLowerCase().contains(query) ||
            abogado.correo.toLowerCase().contains(query) ||
            abogado.especialidad.toLowerCase().contains(query) ||
            abogado.ciudad.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterAbogados);
    _searchController.dispose();
    super.dispose();
  }

  void _verDetalle(Abogado abogado) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleAbogadoScreen(
          id: abogado.id,
          nombre: abogado.nombre,
          correo: abogado.correo,
          telefono: abogado.telefono,
          tipo: abogado.especialidad,
          casosPendientes: 2, // Simulado, luego lo traes de tu API
          casosEnProceso: 1,
          casosFinalizados: 3,
        ),
      ),
    );
  }

  Future<void> _eliminarAbogado(Abogado abogado) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar abogado?"),
        content: Text("¿Seguro que deseas eliminar a ${abogado.nombre}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final mensaje = await ApiService.eliminarAbogado(abogado.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
      _fetchAbogados(); // refresca lista
    }
  }

  Future<void> _editarAbogado(Abogado abogado) async {
    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarAbogadoScreen(abogado: abogado),
      ),
    );

    if (actualizado == true) {
      _fetchAbogados(); // refresca si se guardaron cambios
    }
  }

  Future<void> _registrarAbogado() async {
    final registrado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistrarAbogadoScreen(),
      ),
    );

    if (registrado == true) {
      _fetchAbogados(); // refresca si se registró uno nuevo
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Abogados"),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          // Buscador modular
          BuscadorAbogadosWidget(
            controller: _searchController,
            onChanged: (_) => _filterAbogados(),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text("Error: $_error"))
                    : _filteredAbogados.isEmpty
                        ? const Center(child: Text("No hay abogados registrados"))
                        : ListView.builder(
                            itemCount: _filteredAbogados.length,
                            itemBuilder: (context, index) {
                              final abogado = _filteredAbogados[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: abogado.foto.isNotEmpty
                                        ? NetworkImage(abogado.foto)
                                        : null,
                                    backgroundColor: Colors.grey[200],
                                    child: abogado.foto.isEmpty
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  title: Text(abogado.nombre),
                                  subtitle: Text(
                                    "${abogado.correo}\nTel: ${abogado.telefono}\nEsp: ${abogado.especialidad}\nCiudad: ${abogado.ciudad}",
                                  ),
                                  isThreeLine: true,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.orange),
                                        onPressed: () => _editarAbogado(abogado),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _eliminarAbogado(abogado),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _verDetalle(abogado),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _registrarAbogado,
        child: const Icon(Icons.person_add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}