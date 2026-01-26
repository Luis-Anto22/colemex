import 'package:flutter/material.dart';
import 'api_service_profesionales.dart'; // ✅ usa el servicio correcto
import 'profesional.dart'; 
import 'detalle_profesional_sreen.dart';
import 'buscador_profesionales_widget.dart';
import 'editar_profesional_screen.dart';
import 'registrar_profesional_screen.dart';

class ListaProfesionalesScreen extends StatefulWidget {
  const ListaProfesionalesScreen({Key? key}) : super(key: key);

  @override
  State<ListaProfesionalesScreen> createState() => _ListaProfesionalesScreenState();
}

class _ListaProfesionalesScreenState extends State<ListaProfesionalesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Profesional> _profesionales = [];
  List<Profesional> _filteredProfesionales = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfesionales();
    _searchController.addListener(_filterProfesionales);
  }

  Future<void> _fetchProfesionales() async {
    try {
      final data = await ApiServiceProfesionales.obtenerProfesionales();
      setState(() {
        _profesionales = data.map((e) => Profesional.fromJson(e)).toList();
        _filteredProfesionales = _profesionales;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterProfesionales() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProfesionales = _profesionales.where((p) {
        return p.nombre.toLowerCase().contains(query) ||
               p.correo.toLowerCase().contains(query) ||
               p.especialidad.toLowerCase().contains(query) ||
               p.ciudad.toLowerCase().contains(query) ||
               p.perfil.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProfesionales);
    _searchController.dispose();
    super.dispose();
  }

  void _verDetalle(Profesional profesional) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleProfesionalScreen(profesional: profesional),
      ),
    );
  }

  Future<void> _eliminarProfesional(Profesional profesional) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar profesional?"),
        content: Text("¿Seguro que deseas eliminar a ${profesional.nombre}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Eliminar")),
        ],
      ),
    );

    if (confirm == true) {
      final mensaje = await ApiServiceProfesionales.eliminarProfesional(profesional.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
      _fetchProfesionales();
    }
  }

  Future<void> _editarProfesional(Profesional profesional) async {
    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => EditarProfesionalScreen(profesional: profesional)),
    );
    if (actualizado == true) _fetchProfesionales();
  }

  Future<void> _registrarProfesional() async {
    final registrado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const RegistrarProfesionalScreen()),
    );
    if (registrado == true) _fetchProfesionales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista de Profesionales"), backgroundColor: Colors.indigo),
      body: Column(
        children: [
          BuscadorProfesionalesWidget(controller: _searchController, onChanged: (_) => _filterProfesionales()),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text("Error: $_error"))
                    : _filteredProfesionales.isEmpty
                        ? const Center(child: Text("No hay profesionales registrados"))
                        : ListView.builder(
                            itemCount: _filteredProfesionales.length,
                            itemBuilder: (context, index) {
                              final profesional = _filteredProfesionales[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: profesional.foto.isNotEmpty ? NetworkImage(profesional.foto) : null,
                                    backgroundColor: Colors.grey[200],
                                    child: profesional.foto.isEmpty ? const Icon(Icons.person) : null,
                                  ),
                                  title: Text(profesional.nombre),
                                  subtitle: Text(
                                    "${profesional.correo}\nTel: ${profesional.telefono}\nPerfil: ${profesional.perfil}\nEsp: ${profesional.especialidad}\nCiudad: ${profesional.ciudad}",
                                  ),
                                  isThreeLine: true,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _editarProfesional(profesional)),
                                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _eliminarProfesional(profesional)),
                                    ],
                                  ),
                                  onTap: () => _verDetalle(profesional),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _registrarProfesional,
        child: const Icon(Icons.person_add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}