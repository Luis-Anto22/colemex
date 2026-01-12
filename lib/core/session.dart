import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('id_abogado');
  }

  static Future<void> saveSession(String idAbogado) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id_abogado', idAbogado);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id_abogado');
  }

  static Future<String?> getIdAbogado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id_abogado');
  }
}