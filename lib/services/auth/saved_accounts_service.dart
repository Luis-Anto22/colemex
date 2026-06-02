import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedAccount {
  final String accountKey;
  final int id;
  final String nombre;
  final String correo;
  final String perfil;
  final String tipoLogin;
  final String token;
  final bool biometriaActiva;
  final String fechaGuardado;
  final String ultimoLoginReal;

  const SavedAccount({
    required this.accountKey,
    required this.id,
    required this.nombre,
    required this.correo,
    required this.perfil,
    required this.tipoLogin,
    required this.token,
    required this.biometriaActiva,
    required this.fechaGuardado,
    required this.ultimoLoginReal,
  });

  factory SavedAccount.fromJson(Map<String, dynamic> json) {
    return SavedAccount(
      accountKey: (json['accountKey'] ?? '').toString(),
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
      correo: (json['correo'] ?? '').toString(),
      perfil: (json['perfil'] ?? '').toString(),
      tipoLogin: (json['tipo_login'] ?? json['tipoLogin'] ?? '').toString(),
      token: (json['token'] ?? '').toString(),
      biometriaActiva: _toBool(json['biometria_activa'] ?? json['biometriaActiva']),
      fechaGuardado: (json['fecha_guardado'] ?? json['fechaGuardado'] ?? '').toString(),
      ultimoLoginReal: (json['ultimo_login_real'] ?? json['ultimoLoginReal'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountKey': accountKey,
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'perfil': perfil,
      'tipo_login': tipoLogin,
      'token': token,
      'biometria_activa': biometriaActiva,
      'fecha_guardado': fechaGuardado,
      'ultimo_login_real': ultimoLoginReal,
    };
  }

  SavedAccount copyWith({
    String? accountKey,
    int? id,
    String? nombre,
    String? correo,
    String? perfil,
    String? tipoLogin,
    String? token,
    bool? biometriaActiva,
    String? fechaGuardado,
    String? ultimoLoginReal,
  }) {
    return SavedAccount(
      accountKey: accountKey ?? this.accountKey,
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      perfil: perfil ?? this.perfil,
      tipoLogin: tipoLogin ?? this.tipoLogin,
      token: token ?? this.token,
      biometriaActiva: biometriaActiva ?? this.biometriaActiva,
      fechaGuardado: fechaGuardado ?? this.fechaGuardado,
      ultimoLoginReal: ultimoLoginReal ?? this.ultimoLoginReal,
    );
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value.toInt() == 1;

    final text = value?.toString().toLowerCase().trim() ?? '';

    return text == '1' || text == 'true' || text == 'si' || text == 'sí';
  }
}

class SavedAccountsService {
  SavedAccountsService._();

  static const String _storageKey = 'advocatus_saved_accounts_v1';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static String buildAccountKey({
    required String tipoLogin,
    required int id,
    required String perfil,
  }) {
    final tipo = tipoLogin.trim().toLowerCase();
    final perfilNormalizado = perfil.trim().toLowerCase();

    return '${tipo}_${perfilNormalizado}_$id';
  }

  static Future<List<SavedAccount>> listarCuentas() async {
    try {
      final raw = await _storage.read(key: _storageKey);

      if (raw == null || raw.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map((e) => SavedAccount.fromJson(Map<String, dynamic>.from(e)))
          .where((cuenta) {
            return cuenta.id > 0 &&
                cuenta.accountKey.trim().isNotEmpty &&
                cuenta.token.trim().isNotEmpty &&
                cuenta.perfil.trim().isNotEmpty &&
                cuenta.tipoLogin.trim().isNotEmpty;
          })
          .toList();
    } catch (e) {
      debugPrint('Error listando cuentas guardadas: $e');
      return [];
    }
  }

  static Future<bool> hayCuentasGuardadas() async {
    final cuentas = await listarCuentas();
    return cuentas.isNotEmpty;
  }

  static Future<int> totalCuentasGuardadas() async {
    final cuentas = await listarCuentas();
    return cuentas.length;
  }

  static Future<void> guardarCuenta({
    required int id,
    required String nombre,
    required String correo,
    required String perfil,
    required String tipoLogin,
    required String token,
    bool biometriaActiva = true,
  }) async {
    if (id <= 0) return;
    if (perfil.trim().isEmpty) return;
    if (tipoLogin.trim().isEmpty) return;
    if (token.trim().isEmpty) return;

    final now = DateTime.now().toIso8601String();

    final accountKey = buildAccountKey(
      tipoLogin: tipoLogin,
      id: id,
      perfil: perfil,
    );

    final nuevaCuenta = SavedAccount(
      accountKey: accountKey,
      id: id,
      nombre: nombre.trim(),
      correo: correo.trim(),
      perfil: perfil.trim(),
      tipoLogin: tipoLogin.trim(),
      token: token.trim(),
      biometriaActiva: biometriaActiva,
      fechaGuardado: now,
      ultimoLoginReal: now,
    );

    final cuentas = await listarCuentas();

    final index = cuentas.indexWhere((c) => c.accountKey == accountKey);

    if (index >= 0) {
      cuentas[index] = nuevaCuenta;
    } else {
      cuentas.add(nuevaCuenta);
    }

    await _guardarLista(cuentas);
  }

  static Future<void> eliminarCuenta(String accountKey) async {
    final cuentas = await listarCuentas();

    cuentas.removeWhere((c) => c.accountKey == accountKey);

    await _guardarLista(cuentas);
  }

  static Future<void> eliminarTodas() async {
    await _storage.delete(key: _storageKey);
  }

  static Future<SavedAccount?> obtenerCuenta(String accountKey) async {
    final cuentas = await listarCuentas();

    try {
      return cuentas.firstWhere((c) => c.accountKey == accountKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> activarCuenta(SavedAccount cuenta) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('id', cuenta.id);
    await prefs.setString('perfil', cuenta.perfil);
    await prefs.setString('nombre', cuenta.nombre);
    await prefs.setString('correo', cuenta.correo);
    await prefs.setString('token', cuenta.token);
    await prefs.setBool('sesion_activa', true);
    await prefs.setString('tipo_login', cuenta.tipoLogin);
    await prefs.setString('account_key_activa', cuenta.accountKey);
    await prefs.setString('ultima_actividad', DateTime.now().toIso8601String());
  }

  static Future<void> guardarCuentaActualDesdePrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getInt('id') ?? 0;
    final perfil = prefs.getString('perfil') ?? '';
    final nombre = prefs.getString('nombre') ?? '';
    final correo = prefs.getString('correo') ?? '';
    final token = prefs.getString('token') ?? '';
    final tipoLogin = prefs.getString('tipo_login') ?? '';

    await guardarCuenta(
      id: id,
      nombre: nombre,
      correo: correo,
      perfil: perfil,
      tipoLogin: tipoLogin,
      token: token,
      biometriaActiva: true,
    );
  }

  static Future<void> _guardarLista(List<SavedAccount> cuentas) async {
    final data = cuentas.map((c) => c.toJson()).toList();

    await _storage.write(
      key: _storageKey,
      value: jsonEncode(data),
    );
  }
}