import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services/api_client.dart';

class PerfilClienteScreen extends StatefulWidget {
  const PerfilClienteScreen({super.key});

  @override
  State<PerfilClienteScreen> createState() => _PerfilClienteScreenState();
}

class _PerfilClienteScreenState extends State<PerfilClienteScreen> {
  static const Color _bg = Color(0xFF050B14);
  static const Color _card = Color(0xFF111B28);
  static const Color _card2 = Color(0xFF162232);
  static const Color _gold = Color(0xFFD6A84F);
  static const Color _green = Color(0xFF54C26B);
  static const Color _muted = Color(0xFF8C99AA);

  final ApiClient _api = ApiClient();

  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  int? _clienteId;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _ciudadCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id') ?? 0;

    if (id <= 0) {
      if (!mounted) return;
      setState(() => _cargando = false);
      return;
    }

    _clienteId = id;

    try {
      final res = await _api.get('/clientes/$id');

      if (!mounted) return;

      if (res['success'] == true) {
        final cliente = Map<String, dynamic>.from(res['cliente'] ?? {});

        _nombreCtrl.text = (cliente['nombre'] ?? '').toString();
        _correoCtrl.text = (cliente['correo'] ?? '').toString();
        _telefonoCtrl.text = (cliente['telefono'] ?? '').toString();
        _ciudadCtrl.text = (cliente['ciudad'] ?? '').toString();
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cargar tu perfil.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
    }

    if (!mounted) return;
    setState(() => _cargando = false);
  }

  Future<void> _guardar() async {
    if (_clienteId == null) return;

    final nombre = _nombreCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();
    final ciudad = _ciudadCtrl.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre es obligatorio.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final res = await _api.put('/clientes/$_clienteId', {
        'nombre': nombre,
        'telefono': telefono,
        'ciudad': ciudad,
      });

      if (!mounted) return;

      final success = res['success'] == true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Perfil actualizado correctamente'
                : (res['message'] ?? res['mensaje'] ?? 'Error al actualizar'),
          ),
          backgroundColor:
              success ? const Color(0xFF166534) : const Color(0xFFB91C1C),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo actualizar tu perfil.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  String _primerNombre() {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) return 'Cliente';
    return nombre.split(' ').first;
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          _buildGlow(),
          const Center(
            child: CircularProgressIndicator(color: _gold),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow() {
    return Positioned(
      top: -100,
      left: -100,
      right: -100,
      height: 300,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 0.9,
            colors: [
              const Color(0xFF233653).withValues(alpha: 0.9),
              const Color(0xFF0B1420).withValues(alpha: 0.74),
              _bg.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            'Mi perfil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.065),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.07),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 74,
                height: 74,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                  border: Border.all(
                    color: _gold.withValues(alpha: 0.8),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/iconos/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: const Color(0xFF0C1420),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nombreCtrl.text.trim().isEmpty
                          ? 'Cliente AppBogator'
                          : _nombreCtrl.text.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _correoCtrl.text.trim().isEmpty
                          ? 'Correo no registrado'
                          : _correoCtrl.text.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _buildChip(
                          icon: Icons.verified_user_rounded,
                          text: 'Cliente',
                          color: _gold,
                        ),
                        _buildChip(
                          icon: Icons.check_circle_rounded,
                          text: 'Activo',
                          color: _green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          _PremiumTextField(
            controller: _nombreCtrl,
            label: 'Nombre completo',
            hint: 'Escribe tu nombre',
            icon: Icons.person_outline_rounded,
            enabled: !_guardando,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 13),
          _PremiumTextField(
            controller: _correoCtrl,
            label: 'Correo electrónico',
            hint: 'Correo registrado',
            icon: Icons.email_outlined,
            enabled: false,
          ),
          const SizedBox(height: 13),
          _PremiumTextField(
            controller: _telefonoCtrl,
            label: 'Teléfono',
            hint: 'Ej. 55 1234 5678',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            enabled: !_guardando,
          ),
          const SizedBox(height: 13),
          _PremiumTextField(
            controller: _ciudadCtrl,
            label: 'Ciudad',
            hint: 'Ej. Chalco, Estado de México',
            icon: Icons.location_on_outlined,
            enabled: !_guardando,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card2.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.055),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: _gold,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tu correo está protegido y no se puede editar desde esta pantalla. Para cambiarlo, solicita soporte.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.58),
                height: 1.35,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _guardando ? null : _guardar,
        style: ElevatedButton.styleFrom(
          backgroundColor: _gold,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
          foregroundColor: const Color(0xFF111827),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.38),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _guardando
              ? const Row(
                  key: ValueKey('loading'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Guardando...',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                )
              : const Row(
                  key: ValueKey('save'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_rounded),
                    SizedBox(width: 9),
                    Text(
                      'Guardar cambios',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return _buildLoading();
    }

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          _buildGlow(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildProfileCard(),
                const SizedBox(height: 22),
                _buildSectionTitle('Información personal'),
                _buildInputCard(),
                const SizedBox(height: 14),
                _buildInfoCard(),
                const SizedBox(height: 22),
                _buildSaveButton(),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Hola, ${_primerNombre()}',
                    style: TextStyle(
                      color: _muted.withValues(alpha: 0.78),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
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

class _PremiumTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.enabled = true,
    this.keyboardType,
    this.onChanged,
  });

  static const Color _gold = Color(0xFFD6A84F);

  @override
  Widget build(BuildContext context) {
    final borderColor = enabled
        ? Colors.white.withValues(alpha: 0.075)
        : Colors.white.withValues(alpha: 0.04);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(
            color: enabled
                ? Colors.white
                : Colors.white.withValues(alpha: 0.46),
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(
              icon,
              color: enabled ? _gold : Colors.white.withValues(alpha: 0.35),
              size: 22,
            ),
            filled: true,
            fillColor: enabled
                ? const Color(0xFF0C1420)
                : const Color(0xFF0C1420).withValues(alpha: 0.55),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _gold, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}