import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService._();

  static final LocalAuthentication _auth = LocalAuthentication();

  /// Verifica si el dispositivo soporta biometría o autenticación local.
  static Future<bool> puedeUsarBiometria() async {
    if (kIsWeb) return false;

    try {
      final puedeVerificar = await _auth.canCheckBiometrics;
      final dispositivoSoportado = await _auth.isDeviceSupported();

      return puedeVerificar || dispositivoSoportado;
    } catch (e) {
      debugPrint('Biometría no disponible: $e');
      return false;
    }
  }

  /// Regresa las biometrías disponibles: huella, faceId, iris, etc.
  static Future<List<BiometricType>> biometriaDisponible() async {
    if (kIsWeb) return [];

    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error obteniendo biometrías disponibles: $e');
      return [];
    }
  }

  /// Pide huella / Face ID / PIN del teléfono.
  static Future<bool> autenticar({
    String motivo = 'Confirma tu identidad para acceder a tu sesión.',
  }) async {
    if (kIsWeb) return false;

    try {
      final disponible = await puedeUsarBiometria();

      if (!disponible) {
        return false;
      }

      final autenticado = await _auth.authenticate(
        localizedReason: motivo,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      return autenticado;
    } catch (e) {
      debugPrint('Error autenticando con biometría: $e');
      return false;
    }
  }

  /// Texto amigable para mostrar en botones/pantallas.
  static Future<String> nombreMetodoBiometrico() async {
    final biometria = await biometriaDisponible();

    if (biometria.contains(BiometricType.face)) {
      return 'Face ID';
    }

    if (biometria.contains(BiometricType.fingerprint)) {
      return 'huella';
    }

    if (biometria.contains(BiometricType.iris)) {
      return 'iris';
    }

    return 'bloqueo del teléfono';
  }
}