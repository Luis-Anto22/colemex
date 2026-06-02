import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:advocatus/services/auth/biometric_auth_service.dart';
import 'package:advocatus/services/auth/saved_accounts_service.dart';
import 'package:advocatus/services/push/push_notifications_service.dart';

class ProfileSelectorScreen extends StatefulWidget {
  const ProfileSelectorScreen({super.key});

  @override
  State<ProfileSelectorScreen> createState() => _ProfileSelectorScreenState();
}

class _ProfileSelectorScreenState extends State<ProfileSelectorScreen> {
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _dark = Color(0xFF07111F);

  bool _cargando = true;
  bool _autenticando = false;
  bool _desbloqueado = false;

  String _mensaje = '';
  List<SavedAccount> _cuentas = [];

  @override
  void initState() {
    super.initState();
    _cargarCuentas();
  }

  Future<void> _cargarCuentas() async {
    setState(() {
      _cargando = true;
      _mensaje = '';
    });

    final cuentas = await SavedAccountsService.listarCuentas();

    if (!mounted) return;

    setState(() {
      _cuentas = cuentas;
      _cargando = false;
    });

    if (cuentas.isEmpty) {
      setState(() {
        _mensaje = 'No hay perfiles guardados para iniciar con huella.';
      });
      return;
    }

    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;

    await _desbloquearConHuella();
  }

  Future<void> _desbloquearConHuella() async {
    if (_autenticando) return;

    setState(() {
      _autenticando = true;
      _mensaje = '';
    });

    final metodo = await BiometricAuthService.nombreMetodoBiometrico();

    final ok = await BiometricAuthService.autenticar(
      motivo: 'Usa tu $metodo para entrar a tus perfiles guardados.',
    );

    if (!mounted) return;

    setState(() {
      _autenticando = false;
      _desbloqueado = ok;
    });

    if (!ok) {
      setState(() {
        _mensaje = 'No se pudo desbloquear con biometría.';
      });
      return;
    }

    if (_cuentas.length == 1) {
      await _entrarConCuenta(_cuentas.first);
    }
  }

  Future<void> _entrarConCuenta(SavedAccount cuenta) async {
    setState(() {
      _autenticando = true;
      _mensaje = '';
    });

    try {
      await SavedAccountsService.activarCuenta(cuenta);

      try {
        await PushNotificationsService.guardarTokenActual();
      } catch (e) {
        debugPrint('No se pudo actualizar FCM al activar cuenta: $e');
      }

      if (!mounted) return;

      final ruta = _rutaPorPerfil(cuenta.perfil);
      final argumentos = _necesitaId(cuenta.perfil) ? cuenta.id : null;

      Navigator.pushNamedAndRemoveUntil(
        context,
        ruta,
        (route) => false,
        arguments: argumentos,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _autenticando = false;
        _mensaje = 'No se pudo activar el perfil: $e';
      });
    }
  }

  String _normalizarPerfil(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(' ', '_');
  }

  String _rutaPorPerfil(String perfil) {
    final p = _normalizarPerfil(perfil);

    switch (p) {
      case 'admin':
      case 'administrador':
        return '/panel-admin-home';

      case 'cliente':
      case 'clientes':
        return '/panel-cliente';

      case 'abogado':
      case 'abogados':
        return '/panel-abogado';

      case 'psicologo':
      case 'psicologos':
        return '/panel-psicologos';

      case 'investigador':
      case 'investigadores':
        return '/panel-investigador';

      case 'valuador':
      case 'valuadores':
        return '/panel-valuador';

      case 'agente_inmobiliario':
      case 'agentes_inmobiliarios':
        return '/panel-inmuebles';

      case 'contador':
      case 'contadores':
        return '/panel-contador';

      case 'auditor':
      case 'auditores':
        return '/panel-auditor';

      case 'perito_en_criminalistica':
      case 'perito_criminalistica':
      case 'peritos_en_criminalistica':
      case 'peritos':
        return '/panel-perito';

      case 'ajustador':
      case 'ajustadores':
        return '/panel-ajustador';

      case 'agente_crediticio':
      case 'agentes_crediticios':
        return '/panel-agente';

      case 'asistencia_vial':
        return '/panel-asistencia-vial';

      default:
        return '/login';
    }
  }

  bool _necesitaId(String perfil) {
    final p = _normalizarPerfil(perfil);

    return p != 'admin' && p != 'administrador';
  }

  String _nombrePerfilBonito(String perfil, String tipoLogin) {
    final p = _normalizarPerfil(perfil);

    switch (p) {
      case 'admin':
      case 'administrador':
        return 'Administrador';
      case 'cliente':
      case 'clientes':
        return 'Cliente';
      case 'abogado':
      case 'abogados':
        return 'Abogado';
      case 'psicologo':
      case 'psicologos':
        return 'Psicólogo';
      case 'investigador':
      case 'investigadores':
        return 'Investigador';
      case 'valuador':
      case 'valuadores':
        return 'Valuador';
      case 'agente_inmobiliario':
      case 'agentes_inmobiliarios':
        return 'Agente inmobiliario';
      case 'contador':
      case 'contadores':
        return 'Contador';
      case 'auditor':
      case 'auditores':
        return 'Auditor';
      case 'perito_en_criminalistica':
      case 'perito_criminalistica':
      case 'peritos_en_criminalistica':
      case 'peritos':
        return 'Perito';
      case 'ajustador':
      case 'ajustadores':
        return 'Ajustador';
      case 'agente_crediticio':
      case 'agentes_crediticios':
        return 'Agente crediticio';
      case 'asistencia_vial':
        return 'Asistencia vial';
      default:
        return tipoLogin == 'cliente' ? 'Cliente' : 'Profesional';
    }
  }

  IconData _iconoPerfil(String perfil, String tipoLogin) {
    final p = _normalizarPerfil(perfil);

    switch (p) {
      case 'admin':
      case 'administrador':
        return Icons.admin_panel_settings_outlined;
      case 'cliente':
      case 'clientes':
        return Icons.person_outline_rounded;
      case 'abogado':
      case 'abogados':
        return Icons.gavel_rounded;
      case 'psicologo':
      case 'psicologos':
        return Icons.psychology_alt_outlined;
      case 'investigador':
      case 'investigadores':
        return Icons.search_rounded;
      case 'valuador':
      case 'valuadores':
        return Icons.home_work_outlined;
      case 'agente_inmobiliario':
      case 'agentes_inmobiliarios':
        return Icons.apartment_rounded;
      case 'contador':
      case 'contadores':
        return Icons.calculate_outlined;
      case 'auditor':
      case 'auditores':
        return Icons.verified_user_outlined;
      case 'perito_en_criminalistica':
      case 'perito_criminalistica':
      case 'peritos_en_criminalistica':
      case 'peritos':
        return Icons.fingerprint_rounded;
      case 'ajustador':
      case 'ajustadores':
        return Icons.health_and_safety_outlined;
      case 'agente_crediticio':
      case 'agentes_crediticios':
        return Icons.account_balance_wallet_outlined;
      case 'asistencia_vial':
        return Icons.car_repair_outlined;
      default:
        return tipoLogin == 'cliente'
            ? Icons.person_outline_rounded
            : Icons.badge_outlined;
    }
  }

  Widget _brandHeader(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortest = size.shortestSide;

    final titleSize = shortest < 360
        ? 36.0
        : shortest < 420
            ? 42.0
            : 48.0;

    return Column(
      children: [
        Text(
          'AppBogator',
          textAlign: TextAlign.center,
          style: GoogleFonts.bodoniModa(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            letterSpacing: .4,
            height: .96,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black87,
                blurRadius: 18,
                offset: Offset(0, 5),
              ),
              Shadow(
                color: _gold,
                blurRadius: 20,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 96,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [
                Colors.transparent,
                _gold,
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _desbloqueado
              ? 'Elige el perfil con el que deseas entrar'
              : 'Desbloquea tus perfiles guardados',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(.82),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _cuentaCard(SavedAccount cuenta) {
    final perfilBonito = _nombrePerfilBonito(
      cuenta.perfil,
      cuenta.tipoLogin,
    );

    final icono = _iconoPerfil(
      cuenta.perfil,
      cuenta.tipoLogin,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.075),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(.13),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _autenticando ? null : () => _entrarConCuenta(cuenta),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _gold.withOpacity(.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _gold.withOpacity(.32),
                  ),
                ),
                child: Icon(
                  icono,
                  color: _gold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      perfilBonito,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      cuenta.nombre.isEmpty ? 'Usuario guardado' : cuenta.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.78),
                        fontSize: 13.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (cuenta.correo.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        cuenta.correo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.50),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (_autenticando)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: _gold,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white70,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _estadoCentral() {
    if (_cargando) {
      return const Column(
        children: [
          SizedBox(height: 18),
          CircularProgressIndicator(color: _gold),
          SizedBox(height: 14),
          Text(
            'Cargando perfiles guardados...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      );
    }

    if (_cuentas.isEmpty) {
      return _messageBox(
        icon: Icons.no_accounts_outlined,
        title: 'No hay perfiles guardados',
        message:
            'Inicia sesión con correo y contraseña para guardar un perfil en este teléfono.',
      );
    }

    if (!_desbloqueado) {
      return Column(
        children: [
          const SizedBox(height: 8),
          Icon(
            Icons.fingerprint_rounded,
            size: 74,
            color: _gold.withOpacity(.95),
          ),
          const SizedBox(height: 12),
          Text(
            _autenticando
                ? 'Esperando autenticación...'
                : 'Usa tu huella o bloqueo del teléfono',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _autenticando ? null : _desbloquearConHuella,
              icon: const Icon(Icons.fingerprint_rounded),
              label: Text(
                _autenticando ? 'Validando...' : 'Desbloquear con huella',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: _cuentas.map(_cuentaCard).toList(),
    );
  }

  Widget _messageBox({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.075),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(.13),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: _gold,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(.68),
              height: 1.35,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentCard(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 430),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _dark.withOpacity(.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.38),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          _estadoCentral(),
          if (_mensaje.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.redAccent.withOpacity(.35),
                ),
              ),
              child: Text(
                _mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: _autenticando
                ? null
                : () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
            icon: const Icon(Icons.login_rounded),
            label: const Text('Entrar con correo y contraseña'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF9EC5FF),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final horizontalPadding = size.width < 370 ? 18.0 : 26.0;
    final verticalPadding = size.height < 720 ? 18.0 : 28.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/iconos/mazo-libro.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(.76),
                _dark.withOpacity(.82),
                Colors.black.withOpacity(.78),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _brandHeader(context),
                    SizedBox(height: size.height < 720 ? 18 : 24),
                    _contentCard(context),
                    const SizedBox(height: 14),
                    Text(
                      '© AppBogator',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.52),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}