import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'screens/admin/profesional.dart';

class ApiService {
  static const String baseUrl = "https://corporativolegaldigital.com/api";

  // 🔹 Endpoints de admin
  static const String listarAbogadosEndpoint = "$baseUrl/listar-abogados.php";
  static const String registrarAbogadoEndpoint = "$baseUrl/registrar-abogado.php";
  static const String eliminarAbogadoEndpoint = "$baseUrl/eliminar-abogado.php";
  static const String actualizarAbogadoEndpoint = "$baseUrl/actualizar-abogado.php";
  static const String estadisticasEndpoint = "$baseUrl/estadisticas.php";

  /// ✅ Listar abogados tipados con modelo
  static Future<List<Profesional>> obtenerAbogados() async {
    try {
      final response = await http.get(Uri.parse(listarAbogadosEndpoint));
      if (kDebugMode) debugPrint("Respuesta listar-abogados: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data["success"] == true) {
          final abogadosJson = data["abogados"];
          if (abogadosJson is List) {
            return abogadosJson.map((e) => Profesional.fromJson(e)).toList();
          } else {
            throw Exception("Formato inesperado en 'abogados': ${response.body}");
          }
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
        if (data is Map && data["success"] == true) {
          return Map<String, dynamic>.from(data); // ✅ Cast seguro
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

  /// ✅ Historial de servicios de psicólogos
  static Future<List<dynamic>> obtenerHistorialServiciosPsicologo(int id) async {
    if (id <= 0) {
      throw Exception("ID inválido: el psicólogoId debe ser mayor a 0");
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/historial_servicios_psicologo.php?id=$id"),
      );
      debugPrint("Respuesta historial-servicios: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔧 Manejo de respuestas con error desde PHP
        if (data is Map && data.containsKey("success") && data["success"] == false) {
          throw Exception("Error en servidor: ${data["mensaje"]}");
        }

        if (data is List) {
          return data;
        } else {
          throw Exception("Formato inesperado en historial: ${response.body}");
        }
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error al obtener historial de servicios: $e");
    }
  }
}