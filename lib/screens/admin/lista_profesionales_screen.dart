import 'dart:math';

import 'package:flutter/material.dart';

import 'api_service_profesionales.dart';
import 'profesional.dart';
import 'detalle_profesional_sreen.dart';
import 'editar_profesional_screen.dart';
import 'registrar_profesional_screen.dart';

class ListaProfesionalesScreen extends StatefulWidget {
  const ListaProfesionalesScreen({super.key});

  @override
  State<ListaProfesionalesScreen> createState() =>
      _ListaProfesionalesScreenState();
}

class _ListaProfesionalesScreenState extends State<ListaProfesionalesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  late final AnimationController _backgroundController;

  List<Profesional> _profesionales = [];
  List<Profesional> _filteredProfesionales = [];

  bool _isLoading = true;
  String? _error;
  String _perfilSeleccionado = 'Todos';

  final List<String> _perfiles = const [
    'Todos',
    'Abogados',
    'Ajustadores',
    'Peritos en criminalística',
    'Valuadores',
    'Investigadores',
    'Psicólogos',
    'Agentes inmobiliarios',
    'Contadores',
    'Agentes crediticios',
    'Asistencia vial',
  ];

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _fetchProfesionales();
    _searchController.addListener(_filterProfesionales);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _searchController.removeListener(_filterProfesionales);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfesionales() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiServiceProfesionales.obtenerProfesionales();

      if (!mounted) return;

      setState(() {
        _profesionales = data.map((e) => Profesional.fromJson(e)).toList();
        _filteredProfesionales = _profesionales;
        _isLoading = false;
      });

      _filterProfesionales();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterProfesionales() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredProfesionales = _profesionales.where((p) {
        final matchesSearch = p.nombre.toLowerCase().contains(query) ||
            p.correo.toLowerCase().contains(query) ||
            p.telefono.toLowerCase().contains(query) ||
            p.ciudad.toLowerCase().contains(query) ||
            p.perfil.toLowerCase().contains(query) ||
            (p.especialidadNombre ?? '').toLowerCase().contains(query);

        final matchesPerfil =
            _perfilSeleccionado == 'Todos' || p.perfil == _perfilSeleccionado;

        return matchesSearch && matchesPerfil;
      }).toList();
    });
  }

  Future<void> _registrarProfesional() async {
    final registrado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const RegistrarProfesionalScreen(),
      ),
    );

    if (registrado == true) {
      _fetchProfesionales();
    }
  }

  Future<void> _editarProfesional(Profesional profesional) async {
    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarProfesionalScreen(profesional: profesional),
      ),
    );

    if (actualizado == true) {
      _fetchProfesionales();
    }
  }

  void _verDetalle(Profesional profesional) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleProfesionalScreen(profesional: profesional),
      ),
    );
  }

  Future<void> _eliminarProfesional(Profesional profesional) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF020617),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          title: const Text(
            '¿Eliminar profesional?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            '¿Seguro que deseas eliminar a ${profesional.nombre}?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_rounded, size: 18),
              label: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final mensaje =
          await ApiServiceProfesionales.eliminarProfesional(profesional.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: const Color(0xFF0F172A),
        ),
      );

      _fetchProfesionales();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.90),
        foregroundColor: Colors.white,
        title: const Text(
          'Profesionales',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _fetchProfesionales,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 10,
        onPressed: _registrarProfesional,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'Registrar',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (_, __) {
                return CustomPaint(
                  painter: _MovingParticlesPainter(
                    progress: _backgroundController.value,
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.35,
                  colors: [
                    const Color(0xFF1E3A8A).withOpacity(0.34),
                    const Color(0xFF020617).withOpacity(0.90),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: Colors.white,
              backgroundColor: const Color(0xFF111827),
              onRefresh: _fetchProfesionales,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  isWide ? 24 : 16,
                  16,
                  isWide ? 24 : 16,
                  96,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderProfesionales(
                      total: _profesionales.length,
                      filtrados: _filteredProfesionales.length,
                    ),
                    const SizedBox(height: 18),
                    _SearchAndFilterPanel(
                      searchController: _searchController,
                      perfiles: _perfiles,
                      perfilSeleccionado: _perfilSeleccionado,
                      onPerfilChanged: (value) {
                        setState(() {
                          _perfilSeleccionado = value;
                        });
                        _filterProfesionales();
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildBody(isWide),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isWide) {
    if (_isLoading) {
      return const _LoadingPanel();
    }

    if (_error != null) {
      return _ErrorPanel(
        error: _error!,
        onRetry: _fetchProfesionales,
      );
    }

    if (_filteredProfesionales.isEmpty) {
      return const _EmptyPanel();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredProfesionales.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 1,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: isWide ? 1.55 : 1.38,
      ),
      itemBuilder: (_, index) {
        final profesional = _filteredProfesionales[index];

        return _ProfesionalCard(
          profesional: profesional,
          onTap: () => _verDetalle(profesional),
          onEdit: () => _editarProfesional(profesional),
          onDelete: () => _eliminarProfesional(profesional),
        );
      },
    );
  }
}

class _HeaderProfesionales extends StatelessWidget {
  final int total;
  final int filtrados;

  const _HeaderProfesionales({
    required this.total,
    required this.filtrados,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 720;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 26 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.065),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withOpacity(0.13),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                _buildIcon(),
                const SizedBox(width: 18),
                const Expanded(child: _HeaderText()),
                const SizedBox(width: 18),
                _HeaderCounter(total: total, filtrados: filtrados),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildIcon(),
                    const SizedBox(width: 14),
                    const Expanded(child: _HeaderText()),
                  ],
                ),
                const SizedBox(height: 16),
                _HeaderCounter(total: total, filtrados: filtrados),
              ],
            ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF38BDF8),
            Color(0xFF2563EB),
            Color(0xFF1E40AF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withOpacity(0.35),
            blurRadius: 26,
          ),
        ],
      ),
      child: const Icon(
        Icons.badge_rounded,
        color: Colors.white,
        size: 36,
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión de profesionales',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Administra abogados, peritos, valuadores, investigadores y más.',
          style: TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 13.5,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _HeaderCounter extends StatelessWidget {
  final int total;
  final int filtrados;

  const _HeaderCounter({
    required this.total,
    required this.filtrados,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _SmallCounter(
          label: 'Total',
          value: '$total',
          icon: Icons.groups_rounded,
          color: const Color(0xFF38BDF8),
        ),
        _SmallCounter(
          label: 'Mostrando',
          value: '$filtrados',
          icon: Icons.filter_alt_rounded,
          color: const Color(0xFF22C55E),
        ),
      ],
    );
  }
}

class _SmallCounter extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SmallCounter({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 122,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.075),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilterPanel extends StatelessWidget {
  final TextEditingController searchController;
  final List<String> perfiles;
  final String perfilSeleccionado;
  final ValueChanged<String> onPerfilChanged;

  const _SearchAndFilterPanel({
    required this.searchController,
    required this.perfiles,
    required this.perfilSeleccionado,
    required this.onPerfilChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 720;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(child: _buildSearchField()),
                const SizedBox(width: 12),
                SizedBox(width: 260, child: _buildDropdown()),
              ],
            )
          : Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 12),
                _buildDropdown(),
              ],
            ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      cursorColor: const Color(0xFF38BDF8),
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, correo, teléfono, ciudad o perfil...',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.42),
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFF38BDF8),
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.10),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: const BorderSide(
            color: Color(0xFF38BDF8),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: perfilSeleccionado,
      dropdownColor: const Color(0xFF020617),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      iconEnabledColor: const Color(0xFF38BDF8),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.tune_rounded,
          color: Color(0xFF38BDF8),
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.10),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: const BorderSide(
            color: Color(0xFF38BDF8),
            width: 1.4,
          ),
        ),
      ),
      items: perfiles.map((perfil) {
        return DropdownMenuItem<String>(
          value: perfil,
          child: Text(perfil),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onPerfilChanged(value);
        }
      },
    );
  }
}

class _ProfesionalCard extends StatelessWidget {
  final Profesional profesional;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProfesionalCard({
    required this.profesional,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Color perfilColor = _colorForPerfil(profesional.perfil);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.065),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.11)),
            boxShadow: [
              BoxShadow(
                color: perfilColor.withOpacity(0.11),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _AvatarProfesional(
                    foto: profesional.foto,
                    nombre: profesional.nombre,
                    color: perfilColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NombreCorreo(
                      nombre: profesional.nombre,
                      correo: profesional.correo,
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: const Color(0xFF020617),
                    iconColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                    onSelected: (value) {
                      if (value == 'editar') onEdit();
                      if (value == 'eliminar') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, color: Color(0xFFFACC15)),
                            SizedBox(width: 10),
                            Text(
                              'Editar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'eliminar',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, color: Color(0xFFEF4444)),
                            SizedBox(width: 10),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChipInfo(
                    icon: Icons.work_rounded,
                    label: profesional.perfil,
                    color: perfilColor,
                  ),
                  _ChipInfo(
                    icon: Icons.location_city_rounded,
                    label:
                        profesional.ciudad.trim().isEmpty ? 'Sin ciudad' : profesional.ciudad,
                    color: const Color(0xFF38BDF8),
                  ),
                  _ChipInfo(
                    icon: Icons.workspace_premium_rounded,
                    label: profesional.especialidadNombre ?? 'Sin especialidad',
                    color: const Color(0xFFA855F7),
                  ),
                ],
              ),
              const Spacer(),
              Divider(color: Colors.white.withOpacity(0.10), height: 22),
              Row(
                children: [
                  Expanded(
                    child: _MiniInfo(
                      icon: Icons.phone_rounded,
                      text: profesional.telefono.trim().isEmpty
                          ? 'Sin teléfono'
                          : profesional.telefono,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.edit_rounded,
                    color: const Color(0xFFFACC15),
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.delete_rounded,
                    color: const Color(0xFFEF4444),
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorForPerfil(String perfil) {
    final p = perfil.toLowerCase();

    if (p.contains('abogado')) return const Color(0xFF38BDF8);
    if (p.contains('ajustador')) return const Color(0xFFF97316);
    if (p.contains('perito')) return const Color(0xFFEF4444);
    if (p.contains('valuador')) return const Color(0xFF22C55E);
    if (p.contains('investigador')) return const Color(0xFFA855F7);
    if (p.contains('psic')) return const Color(0xFFEC4899);
    if (p.contains('inmobiliario')) return const Color(0xFFFACC15);
    if (p.contains('contador')) return const Color(0xFF14B8A6);
    if (p.contains('crediticio')) return const Color(0xFF6366F1);
    if (p.contains('vial')) return const Color(0xFF06B6D4);

    return const Color(0xFF94A3B8);
  }
}

class _AvatarProfesional extends StatelessWidget {
  final String foto;
  final String nombre;
  final Color color;

  const _AvatarProfesional({
    required this.foto,
    required this.nombre,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = nombre.trim().isEmpty ? '?' : nombre.trim()[0].toUpperCase();

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.30),
            blurRadius: 18,
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        backgroundImage: foto.trim().isNotEmpty ? NetworkImage(foto) : null,
        child: foto.trim().isEmpty
            ? Text(
                inicial,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              )
            : null,
      ),
    );
  }
}

class _NombreCorreo extends StatelessWidget {
  final String nombre;
  final String correo;

  const _NombreCorreo({
    required this.nombre,
    required this.correo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          correo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(0.56),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ChipInfo({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 210),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.50),
          size: 17,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.62),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.11),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF38BDF8)),
          SizedBox(height: 16),
          Text(
            'Cargando profesionales...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorPanel({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.35)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'No se pudieron cargar los profesionales',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'Reintentar',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.manage_search_rounded,
            color: Color(0xFF38BDF8),
            size: 52,
          ),
          const SizedBox(height: 12),
          const Text(
            'No hay profesionales para mostrar',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Intenta cambiar el filtro o la búsqueda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovingParticlesPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _MovingParticlesPainter({required this.progress})
      : particles = List.generate(80, (index) {
          final random = Random(index * 901);
          return _Particle(
            x: random.nextDouble(),
            y: random.nextDouble(),
            radius: 0.8 + random.nextDouble() * 2.1,
            speed: 0.015 + random.nextDouble() * 0.045,
            opacity: 0.22 + random.nextDouble() * 0.58,
          );
        });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      final animatedY = (particle.y + progress * particle.speed) % 1.0;
      final wave = sin((progress * 2 * pi) + particle.y * 10) * 14;

      final position = Offset(
        particle.x * size.width + wave,
        animatedY * size.height,
      );

      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(position, particle.radius, paint);
    }

    final linePaint = Paint()
      ..strokeWidth = 0.4
      ..color = Colors.white.withOpacity(0.055);

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];

        final o1 = Offset(
          p1.x * size.width,
          ((p1.y + progress * p1.speed) % 1.0) * size.height,
        );

        final o2 = Offset(
          p2.x * size.width,
          ((p2.y + progress * p2.speed) % 1.0) * size.height,
        );

        final distance = (o1 - o2).distance;

        if (distance < 100) {
          canvas.drawLine(o1, o2, linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MovingParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _Particle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double opacity;

  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}