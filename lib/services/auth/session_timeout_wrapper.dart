import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'biometric_auth_service.dart';
import 'saved_accounts_service.dart';
import '../push/push_notifications_service.dart';

class SessionTimeoutWrapper extends StatefulWidget {
  final Widget child;

  /// Tiempo de inactividad permitido.
  /// Para pruebas puedes poner Duration(minutes: 2).
  /// Para producción recomiendo Duration(minutes: 15).
  final Duration timeout;

  final bool enabled;

  const SessionTimeoutWrapper({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 15),
    this.enabled = true,
  });

  @override
  State<SessionTimeoutWrapper> createState() => _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends State<SessionTimeoutWrapper>
    with WidgetsBindingObserver {
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _dark = Color(0xFF07111F);

  Timer? _timer;
  DateTime _ultimaActividad = DateTime.now();

  bool _bloqueado = false;
  bool _desbloqueando = false;
  String _mensaje = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _registrarActividad();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SessionTimeoutWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.timeout != widget.timeout ||
        oldWidget.enabled != widget.enabled) {
      _registrarActividad();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enabled) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _guardarUltimaActividad();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _revisarTiempoAlVolver();
    }
  }

  Future<bool> _haySesionActiva() async {
    final prefs = await SharedPreferences.getInstance();

    final sesionActiva = prefs.getBool('sesion_activa') ?? false;
    final token = prefs.getString('token') ?? '';
    final id = prefs.getInt('id') ?? 0;

    return sesionActiva && token.trim().isNotEmpty && id > 0;
  }

  Future<void> _guardarUltimaActividad() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'ultima_actividad',
      _ultimaActividad.toIso8601String(),
    );
  }

  Future<void> _revisarTiempoAlVolver() async {
    if (!widget.enabled || _bloqueado) return;

    final tieneSesion = await _haySesionActiva();

    if (!mounted || !tieneSesion) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ultima_actividad');

    DateTime ultima = _ultimaActividad;

    if (raw != null && raw.trim().isNotEmpty) {
      ultima = DateTime.tryParse(raw) ?? _ultimaActividad;
    }

    final diferencia = DateTime.now().difference(ultima);

    if (diferencia >= widget.timeout) {
      _bloquearSesion();
    } else {
      _registrarActividad();
    }
  }

  void _registrarActividad() {
    if (!widget.enabled) return;
    if (_bloqueado) return;

    _ultimaActividad = DateTime.now();
    _guardarUltimaActividad();

    _timer?.cancel();
    _timer = Timer(widget.timeout, () async {
      final tieneSesion = await _haySesionActiva();

      if (!mounted || !tieneSesion) return;

      _bloquearSesion();
    });
  }

  Future<void> _bloquearSesion() async {
    if (!mounted) return;

    final tieneSesion = await _haySesionActiva();

    if (!mounted || !tieneSesion) return;

    setState(() {
      _bloqueado = true;
      _mensaje = 'Cerramos tu sesión por seguridad.';
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sesion_bloqueada_por_inactividad', true);
  }

  Future<void> _desbloquearConHuella() async {
    if (_desbloqueando) return;

    setState(() {
      _desbloqueando = true;
      _mensaje = '';
    });

    try {
      final metodo = await BiometricAuthService.nombreMetodoBiometrico();

      final ok = await BiometricAuthService.autenticar(
        motivo: 'Usa tu $metodo para volver a tu sesión.',
      );

      if (!mounted) return;

      if (!ok) {
        setState(() {
          _desbloqueando = false;
          _mensaje = 'No se pudo desbloquear la sesión.';
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('sesion_bloqueada_por_inactividad', false);
      await prefs.setString('ultima_actividad', DateTime.now().toIso8601String());

      try {
        await PushNotificationsService.guardarTokenActual();
      } catch (e) {
        debugPrint('No se pudo actualizar FCM después de desbloquear: $e');
      }

      if (!mounted) return;

      setState(() {
        _bloqueado = false;
        _desbloqueando = false;
        _mensaje = '';
      });

      _registrarActividad();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _desbloqueando = false;
        _mensaje = 'Error al desbloquear: $e';
      });
    }
  }

  Future<void> _entrarConContrasena() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('sesion_activa', false);
    await prefs.setBool('sesion_bloqueada_por_inactividad', false);

    if (!mounted) return;

    setState(() {
      _bloqueado = false;
      _desbloqueando = false;
      _mensaje = '';
    });

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  Future<void> _cambiarPerfil() async {
    final hayCuentas = await SavedAccountsService.hayCuentasGuardadas();

    if (!mounted) return;

    if (!hayCuentas) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
      return;
    }

    setState(() {
      _bloqueado = false;
      _desbloqueando = false;
      _mensaje = '';
    });

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/profile-selector',
      (route) => false,
    );
  }

  Widget _bloqueoOverlay() {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(.86),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 430),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _dark.withOpacity(.96),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withOpacity(.14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.45),
                      blurRadius: 30,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        color: _gold.withOpacity(.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _gold.withOpacity(.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: _gold,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Sesión bloqueada',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _mensaje.isEmpty
                          ? 'Cerramos tu sesión por seguridad.'
                          : _mensaje,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.75),
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed:
                            _desbloqueando ? null : _desbloquearConHuella,
                        icon: const Icon(Icons.fingerprint_rounded),
                        label: Text(
                          _desbloqueando
                              ? 'Validando...'
                              : 'Desbloquear con huella',
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
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _desbloqueando ? null : _cambiarPerfil,
                        icon: const Icon(Icons.switch_account_rounded),
                        label: const Text('Cambiar perfil'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: _gold.withOpacity(.70),
                            width: 1.2,
                          ),
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
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: _desbloqueando ? null : _entrarConContrasena,
                      child: const Text(
                        'Entrar con correo y contraseña',
                        style: TextStyle(
                          color: Color(0xFF9EC5FF),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (_desbloqueando) ...[
                      const SizedBox(height: 10),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: _gold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _registrarActividad(),
      onPointerMove: (_) => _registrarActividad(),
      onPointerSignal: (_) => _registrarActividad(),
      child: Stack(
        children: [
          widget.child,
          if (_bloqueado) _bloqueoOverlay(),
        ],
      ),
    );
  }
}