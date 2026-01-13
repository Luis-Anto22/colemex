import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'screens/admin/abogado.dart';

class ApiService {
  static const String baseUrl = "https://corporativolegaldigital.com/api";

  /// ✅ Listar abogados
  static Future<List<Abogado>> obtenerAbogados() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/listar-abogados.php"));
      debugPrint("Respuesta listar-abogados: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data["success"] == true) {
          final abogadosJson = data["abogados"];
          if (abogadosJson is List) {
            return abogadosJson.map((e) => Abogado.fromJson(e)).toList();
          } else {
            throw Exception("Formato inesperado en 'abogados': ${response.body}");
          }
        } else {
          throw Exception("Error en listar-abogados: ${data["mensaje"] ?? "Respuesta inválida"}");
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
        Uri.parse("$baseUrl/registrar-abogado.php"),
        body: {
          "usuario": usuario,
          "contrasena": contrasena,
        },
      );
      debugPrint("Respuesta registrar-abogado: ${response.body}");

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
        Uri.parse("$baseUrl/eliminar-abogado.php"),
        body: {
          "id": id.toString(),
        },
      );
      debugPrint("Respuesta eliminar-abogado: ${response.body}");

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

  /// ✅ Actualizar abogado
  static Future<String> actualizarAbogado(int id, String usuario, String? contrasena) async {
    try {
      final body = {
        "id": id.toString(),
        "usuario": usuario,
      };
      if (contrasena != null && contrasena.isNotEmpty) {
        body["contrasena"] = contrasena;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/actualizar-abogado.php"),
        body: body,
      );
      debugPrint("Respuesta actualizar-abogado: ${response.body}");

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
      final response = await http.get(Uri.parse("$baseUrl/estadisticas.php"));
      debugPrint("Respuesta estadísticas: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data["success"] == true) {
          return data as Map<String, dynamic>; // ✅ Cast explícito corregido
        } else {
          throw Exception("Error en estadísticas: ${data["mensaje"] ?? "Respuesta inválida"}");
        }
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error al obtener estadísticas: $e");
    }
  }
}