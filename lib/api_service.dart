import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = "https://corporativolegaldigital.com/api";

  // 🔹 Endpoints de admin
  static const String listarAbogadosEndpoint = "$baseUrl/listar-abogados.php";
  static const String registrarAbogadoEndpoint = "$baseUrl/registrar-abogado.php";
  static const String eliminarAbogadoEndpoint = "$baseUrl/eliminar-abogado.php";
  static const String actualizarAbogadoEndpoint = "$baseUrl/actualizar-abogado.php";
  static const String estadisticasEndpoint = "$baseUrl/estadisticas.php";

  /// ✅ Listar abogados
  static Future<List<dynamic>> obtenerAbogados() async {
    try {
      final response = await http.get(Uri.parse(listarAbogadosEndpoint));
      if (kDebugMode) debugPrint("Respuesta listar-abogados: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data["success"] == true) {
          return data["abogados"] as List<dynamic>;
        } else {
          throw Exception(data["mensaje"] ?? "Error en listar-abogados");
        }
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error al obtener abogados: $e");
    }
  }

  /// ✅ Registrar abogado
  static Future<String> registrarAbogado(String usuario, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse(registrarAbogadoEndpoint),
        body: {
          "usuario": usuario,
          "contrasena": contrasena,
        },
      );
      if (kDebugMode) debugPrint("Respuesta registrar-abogado: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["mensaje"] ?? "❌ Error desconocido";
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error al registrar abogado: $e");
    }
  }

  /// ✅ Eliminar abogado
  static Future<String> eliminarAbogado(int id) async {
    try {
      final response = await http.post(
        Uri.parse(eliminarAbogadoEndpoint),
        body: {"id": id.toString()},
      );
      if (kDebugMode) debugPrint("Respuesta eliminar-abogado: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["mensaje"] ?? "❌ Error desconocido";
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error al eliminar abogado: $e");
    }
  }

  /// ✅ Actualizar abogado (con contraseña opcional)
  static Future<String> actualizarAbogado(int id, String usuario, {String? contrasena}) async {
    try {
      final body = {
        "id": id.toString(),
        "usuario": usuario,
      };
      if (contrasena != null && contrasena.isNotEmpty) {
        body["contrasena"] = contrasena;
      }

      final response = await http.post(
        Uri.parse(actualizarAbogadoEndpoint),
        body: body,
      );
      if (kDebugMode) debugPrint("Respuesta actualizar-abogado: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["mensaje"] ?? "❌ Error desconocido";
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error al actualizar abogado: $e");
    }
  }

  /// ✅ Obtener estadísticas generales
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      final response = await http.get(Uri.parse(estadisticasEndpoint));
      if (kDebugMode) debugPrint("Respuesta estadísticas: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data["success"] == true) {
          return data;
        } else {
          throw Exception(data["mensaje"] ?? "Error en estadísticas");
        }
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error al obtener estadísticas: $e");
    }
  }
}