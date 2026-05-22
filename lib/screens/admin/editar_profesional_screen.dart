import 'dart:math';

import 'package:flutter/material.dart';

import 'api_service_profesionales.dart';
import 'profesional.dart';

class EditarProfesionalScreen extends StatefulWidget {
  final Profesional profesional;

  const EditarProfesionalScreen({
    super.key,
    required this.profesional,
  });

  @override
  State<EditarProfesionalScreen> createState() =>
      _EditarProfesionalScreenState();
}

class _EditarProfesionalScreenState extends State<EditarProfesionalScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _backgroundController;

  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _ciudadController;
  late TextEditingController _fotoController;

  bool _isLoading = false;
  String _perfilSeleccionado = 'Abogados';
  int? _especialidadSeleccionada;

  final List<String> perfiles = const [
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

  final List<Map<String, dynamic>> especialidades = const [
    {"id": 1, "nombre": "Derecho Civil"},
    {"id": 2, "nombre": "Derecho Penal"},
    {"id": 3, "nombre": "Derecho Familiar"},
    {"id": 4, "nombre": "Derecho Laboral"},
    {"id": 5, "nombre": "Derecho Mercantil / Corporativo"},
    {"id": 6, "nombre": "Derecho Fiscal / Tributario"},
    {"id": 7, "nombre": "Derecho Administrativo"},
    {"id": 8, "nombre": "Derecho Constitucional"},
    {"id": 9, "nombre": "Derecho Agrario"},
    {"id": 10, "nombre": "Derecho Inmobiliario"},
    {"id": 11, "nombre": "Derecho Migratorio"},
    {"id": 12, "nombre": "Derecho Internacional"},
    {"id": 13, "nombre": "Derecho Bancario y Financiero"},
    {"id": 14, "nombre": "Derecho de Propiedad Intelectual"},
    {"id": 15, "nombre": "Derecho Digital / Tecnológico"},
    {"id": 16, "nombre": "Derecho Ambiental"},
    {"id": 17, "nombre": "Derecho Aduanero"},
    {"id": 18, "nombre": "Derecho Electoral"},
    {"id": 19, "nombre": "Derecho de Seguridad Social"},
    {"id": 20, "nombre": "Derecho Médico"},
    {"id": 21, "nombre": "Derecho Energético"},
    {"id": 22, "nombre": "Derecho de Amparo"},
    {"id": 23, "nombre": "Derecho de Seguros"},
    {"id": 24, "nombre": "Derecho de Consumidor"},
  ];

  Profesional get profesional => widget.profesional;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _nombreController = TextEditingController(text: profesional.nombre);
    _telefonoController = TextEditingController(text: profesional.telefono);
    _ciudadController = TextEditingController(text: profesional.ciudad);
    _fotoController = TextEditingController(text: profesional.foto);

    _perfilSeleccionado = perfiles.contains(profesional.perfil)
        ? profesional.perfil
        : 'Abogados';

    if (_perfilSeleccionado == 'Abogados') {
      _especialidadSeleccionada = profesional.especialidadId;
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _ciudadController.dispose();
    _fotoController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    if (_perfilSeleccionado == 'Abogados' &&
        _especialidadSeleccionada == null) {
      _showSnack(
        'Selecciona una especialidad',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    final datos = {
      "nombre": _nombreController.text.trim(),
      "telefono": _telefonoController.text.trim(),
      "perfil": _perfilSeleccionado,
      "especialidad": _perfilSeleccionado == 'Abogados'
          ? _especialidadSeleccionada?.toString() ?? ""
          : "",
      "ciudad": _ciudadController.text.trim(),
      "foto": _fotoController.text.trim(),
    };

    try {
      final mensaje = await ApiServiceProfesionales.editarProfesional(
        profesional.id,
        datos,
      );

      if (!mounted) return;

      _showSnack(mensaje);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showSnack(
        'Error al guardar: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 850;
    final Color perfilColor = _colorForPerfil(_perfilSeleccionado);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.90),
        foregroundColor: Colors.white,
        title: const Text(
          'Editar profesional',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Guardar',
            onPressed: _isLoading ? null : _guardarCambios,
            icon: const Icon(Icons.save_rounded),
          ),
          const SizedBox(width: 6),
        ],
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
                    perfilColor.withOpacity(0.25),
                    const Color(0xFF020617).withOpacity(0.92),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isWide ? 24 : 16,
                16,
                isWide ? 24 : 16,
                28,
              ),
              child: Column(
                children: [
                  _HeaderEditar(
                    nombre: _nombreController.text,
                    correo: profesional.correo,
                    foto: _fotoController.text,
                    perfil: _perfilSeleccionado,
                    color: perfilColor,
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool twoColumns = constraints.maxWidth >= 900;

                      if (twoColumns) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildFormPanel(perfilColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _PreviewPanel(
                                nombre: _nombreController.text,
                                correo: profesional.correo,
                                telefono: _telefonoController.text,
                                ciudad: _ciudadController.text,
                                foto: _fotoController.text,
                                perfil: _perfilSeleccionado,
                                especialidad: _nombreEspecialidad(),
                                color: perfilColor,
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _buildFormPanel(perfilColor),
                          const SizedBox(height: 16),
                          _PreviewPanel(
                            nombre: _nombreController.text,
                            correo: profesional.correo,
                            telefono: _telefonoController.text,
                            ciudad: _ciudadController.text,
                            foto: _fotoController.text,
                            perfil: _perfilSeleccionado,
                            especialidad: _nombreEspecialidad(),
                            color: perfilColor,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _ActionsPanel(
                    isLoading: _isLoading,
                    color: perfilColor,
                    onCancel: () => Navigator.pop(context, false),
                    onSave: _guardarCambios,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPanel(Color perfilColor) {
    return _DarkPanel(
      title: 'Datos editables',
      icon: Icons.edit_note_rounded,
      glowColor: perfilColor,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _PremiumTextField(
              controller: _nombreController,
              label: 'Nombre completo',
              icon: Icons.person_rounded,
              color: perfilColor,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obligatorio';
                }
                if (value.trim().length < 3) {
                  return 'El nombre es muy corto';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            _PremiumTextField(
              controller: _telefonoController,
              label: 'Teléfono',
              icon: Icons.phone_rounded,
              color: const Color(0xFF22C55E),
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            _PremiumDropdown<String>(
              value: _perfilSeleccionado,
              label: 'Perfil profesional',
              icon: Icons.work_rounded,
              color: const Color(0xFF38BDF8),
              items: perfiles,
              itemLabel: (item) => item,
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _perfilSeleccionado = value;
                  if (_perfilSeleccionado != 'Abogados') {
                    _especialidadSeleccionada = null;
                  }
                });
              },
            ),
            const SizedBox(height: 14),
            if (_perfilSeleccionado == 'Abogados') ...[
              _PremiumDropdown<int>(
                value: _especialidadSeleccionada,
                label: 'Especialidad',
                icon: Icons.workspace_premium_rounded,
                color: const Color(0xFFA855F7),
                items: especialidades.map((e) => e['id'] as int).toList(),
                itemLabel: (id) {
                  final item = especialidades.firstWhere(
                    (e) => e['id'] == id,
                    orElse: () => {'nombre': 'Especialidad'},
                  );
                  return item['nombre'].toString();
                },
                onChanged: (value) {
                  setState(() {
                    _especialidadSeleccionada = value;
                  });
                },
                validator: (value) {
                  if (_perfilSeleccionado == 'Abogados' && value == null) {
                    return 'Selecciona una especialidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
            ],
            _PremiumTextField(
              controller: _ciudadController,
              label: 'Ciudad',
              icon: Icons.location_city_rounded,
              color: const Color(0xFFFACC15),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            _PremiumTextField(
              controller: _fotoController,
              label: 'URL de foto',
              icon: Icons.image_rounded,
              color: const Color(0xFFF97316),
              keyboardType: TextInputType.url,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            _LockedEmailInfo(
              correo: profesional.correo,
            ),
          ],
        ),
      ),
    );
  }

  String _nombreEspecialidad() {
    if (_perfilSeleccionado != 'Abogados') return 'No aplica';
    if (_especialidadSeleccionada == null) return 'Sin especialidad';

    final item = especialidades.firstWhere(
      (e) => e['id'] == _especialidadSeleccionada,
      orElse: () => {'nombre': 'Sin especialidad'},
    );

    return item['nombre'].toString();
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

class _HeaderEditar extends StatelessWidget {
  final String nombre;
  final String correo;
  final String foto;
  final String perfil;
  final Color color;

  const _HeaderEditar({
    required this.nombre,
    required this.correo,
    required this.foto,
    required this.perfil,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 720;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 26 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.065),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                _AvatarPreview(foto: foto, nombre: nombre, color: color),
                const SizedBox(width: 18),
                Expanded(
                  child: _HeaderText(
                    nombre: nombre,
                    correo: correo,
                    perfil: perfil,
                    color: color,
                  ),
                ),
                const SizedBox(width: 18),
                _EditBadge(color: color),
              ],
            )
          : Column(
              children: [
                _AvatarPreview(foto: foto, nombre: nombre, color: color),
                const SizedBox(height: 16),
                _HeaderText(
                  nombre: nombre,
                  correo: correo,
                  perfil: perfil,
                  color: color,
                ),
                const SizedBox(height: 14),
                _EditBadge(color: color),
              ],
            ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String nombre;
  final String correo;
  final String perfil;
  final Color color;

  const _HeaderText({
    required this.nombre,
    required this.correo,
    required this.perfil,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 720;

    return Column(
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          nombre.trim().isEmpty ? 'Profesional sin nombre' : nombre.trim(),
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          correo,
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.60),
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 13),
        _ChipDetalle(
          icon: Icons.work_rounded,
          label: perfil,
          color: color,
        ),
      ],
    );
  }
}

class _EditBadge extends StatelessWidget {
  final Color color;

  const _EditBadge({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.30)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.16),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Modo edición',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  final String nombre;
  final String correo;
  final String telefono;
  final String ciudad;
  final String foto;
  final String perfil;
  final String especialidad;
  final Color color;

  const _PreviewPanel({
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.ciudad,
    required this.foto,
    required this.perfil,
    required this.especialidad,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _DarkPanel(
      title: 'Vista previa',
      icon: Icons.visibility_rounded,
      glowColor: color,
      child: Column(
        children: [
          _AvatarPreview(
            foto: foto,
            nombre: nombre,
            color: color,
            size: 92,
          ),
          const SizedBox(height: 14),
          Text(
            nombre.trim().isEmpty ? 'Profesional sin nombre' : nombre.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            correo,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _ChipDetalle(
                icon: Icons.work_rounded,
                label: perfil,
                color: color,
              ),
              _ChipDetalle(
                icon: Icons.workspace_premium_rounded,
                label: especialidad,
                color: const Color(0xFFA855F7),
              ),
              _ChipDetalle(
                icon: Icons.location_city_rounded,
                label: ciudad.trim().isEmpty ? 'Sin ciudad' : ciudad.trim(),
                color: const Color(0xFFFACC15),
              ),
              _ChipDetalle(
                icon: Icons.phone_rounded,
                label:
                    telefono.trim().isEmpty ? 'Sin teléfono' : telefono.trim(),
                color: const Color(0xFF22C55E),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LockedEmailInfo extends StatelessWidget {
  final String correo;

  const _LockedEmailInfo({
    required this.correo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF38BDF8).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF38BDF8).withOpacity(0.20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_rounded,
            color: Color(0xFF38BDF8),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Correo bloqueado: $correo',
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: 12.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsPanel extends StatelessWidget {
  final bool isLoading;
  final Color color;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _ActionsPanel({
    required this.isLoading,
    required this.color,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.end,
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.18)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: isLoading ? null : onCancel,
            icon: const Icon(Icons.close_rounded),
            label: const Text(
              'Cancelar',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: isLoading ? null : onSave,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(
              isLoading ? 'Guardando...' : 'Guardar cambios',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color color;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.color,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      cursorColor: color,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: _premiumInputDecoration(
        label: label,
        icon: icon,
        color: color,
      ),
    );
  }
}

class _PremiumDropdown<T> extends StatelessWidget {
  final T? value;
  final String label;
  final IconData icon;
  final Color color;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const _PremiumDropdown({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final T? safeValue = items.contains(value) ? value : null;

    return DropdownButtonFormField<T>(
      value: safeValue,
      dropdownColor: const Color(0xFF020617),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      iconEnabledColor: color,
      validator: validator,
      decoration: _premiumInputDecoration(
        label: label,
        icon: icon,
        color: color,
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

InputDecoration _premiumInputDecoration({
  required String label,
  required IconData icon,
  required Color color,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      color: Colors.white.withOpacity(0.55),
      fontWeight: FontWeight.w700,
    ),
    prefixIcon: Icon(
      icon,
      color: color,
    ),
    filled: true,
    fillColor: Colors.black.withOpacity(0.26),
    errorStyle: const TextStyle(
      color: Color(0xFFFCA5A5),
      fontWeight: FontWeight.w700,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.10),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.10),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
        color: color,
        width: 1.4,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(
        color: Color(0xFFEF4444),
        width: 1.2,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(
        color: Color(0xFFEF4444),
        width: 1.4,
      ),
    ),
  );
}

class _AvatarPreview extends StatelessWidget {
  final String foto;
  final String nombre;
  final Color color;
  final double size;

  const _AvatarPreview({
    required this.foto,
    required this.nombre,
    required this.color,
    this.size = 106,
  });

  @override
  Widget build(BuildContext context) {
    final String inicial =
        nombre.trim().isEmpty ? '?' : nombre.trim()[0].toUpperCase();

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 28,
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: const Color(0xFF020617),
        backgroundImage: foto.trim().isNotEmpty ? NetworkImage(foto) : null,
        child: foto.trim().isEmpty
            ? Text(
                inicial,
                style: TextStyle(
                  color: color,
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w900,
                ),
              )
            : null,
      ),
    );
  }
}

class _ChipDetalle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ChipDetalle({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label.trim().isEmpty ? 'No especificado' : label.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11.8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color glowColor;
  final Widget child;

  const _DarkPanel({
    required this.title,
    required this.icon,
    required this.glowColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.065),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.13),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _GlowIcon(
                icon: icon,
                glowColor: glowColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _GlowIcon extends StatelessWidget {
  final IconData icon;
  final Color glowColor;

  const _GlowIcon({
    required this.icon,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: glowColor.withOpacity(0.12),
        border: Border.all(color: glowColor.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.22),
            blurRadius: 22,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: glowColor,
        size: 27,
      ),
    );
  }
}

class _MovingParticlesPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _MovingParticlesPainter({required this.progress})
      : particles = List.generate(80, (index) {
          final random = Random(index * 801);
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