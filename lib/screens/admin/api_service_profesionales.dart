import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceProfesionales {
  static const String baseUrl = "https://corporativolegaldigital.com/api/admin";

  /// 🔹 Login de admin/profesional
  static Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login.php"),
      body: {
        "correo": correo,
        "contrasena": contrasena,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error en login: ${response.statusCode}");
    }
  }

  /// 🔹 Obtener listado de profesionales
  static Future<List<dynamic>> obtenerProfesionales() async {
    final response = await http.get(Uri.parse("$baseUrl/listar_profesionales.php"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["success"] == true) {
        return data["profesionales"];
      } else {
        throw Exception(data["mensaje"]);
      }
    } else {
      throw Exception("Error al obtener profesionales");
    }
  }

  /// 🔹 Crear profesional
  static Future<String> crearProfesional(Map<String, String> profesional) async {
    final response = await http.post(
      Uri.parse("$baseUrl/crear_profesional.php"),
      body: profesional,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["mensaje"];
    } else {
      throw Exception("Error al crear profesional");
    }
  }

  /// 🔹 Editar profesional
  static Future<String> editarProfesional(int id, Map<String, String> profesional) async {
    final body = {"id": id.toString(), ...profesional};
    final response = await http.post(
      Uri.parse("$baseUrl/editar_profesional.php"),
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["mensaje"];
    } else {
      throw Exception("Error al editar profesional");
    }
  }

  /// 🔹 Eliminar profesional
  static Future<String> eliminarProfesional(int id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/eliminar_profesional.php"),
      body: {"id": id.toString()},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["mensaje"];
    } else {
      throw Exception("Error al eliminar profesional");
    }
  }

  /// 🔹 Obtener detalle de profesional por ID
  static Future<Map<String, dynamic>> obtenerDetalleProfesional(int id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/detalle_profesional.php"),
      body: {"id": id.toString()},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["success"] == true) {
        return data["profesional"];
      } else {
        throw Exception(data["mensaje"]);
      }
    } else {
      throw Exception("Error al obtener detalle");
    }
  }
}