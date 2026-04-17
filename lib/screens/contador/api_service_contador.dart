import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiServiceContador {
  static const String baseUrl = "https://corporativolegaldigital.com/api/contador";

  // 🔹 Endpoints
  static const String dashboardEndpoint = "$baseUrl/contador_dashboard.php";
  static const String casosEndpoint = "$baseUrl/contador_casos.php";
  static const String perfilEndpoint = "$baseUrl/contador_perfil.php";
  static const String ingresosEndpoint = "$baseUrl/contador_ingresos.php";
  static const String actualizarCasoEndpoint = "$baseUrl/contador_actualizar_caso.php";
  static const String documentosEndpoint = "$baseUrl/contador_documentos.php";

  /// ✅ Obtener dashboard del contador
  static Future<Map<String, dynamic>> obtenerDashboard(int idContador) async {
    try {
      final response = await http.get(Uri.parse("$dashboardEndpoint?id=$idContador"));
      if (kDebugMode) debugPrint("Respuesta dashboard: ${response.body}");

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        return data;
      }
      throw Exception(data["mensaje"] ?? "Error en dashboard");
    } catch (e) {
      throw Exception("Error al obtener dashboard: $e");
    }
  }

  /// ✅ Obtener casos asignados al contador
  static Future<List<dynamic>> obtenerCasos(int idContador) async {
    try {
      final response = await http.get(Uri.parse("$casosEndpoint?id=$idContador"));
      if (kDebugMode) debugPrint("Respuesta casos: ${response.body}");

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        return data["casos"] ?? [];
      }
      throw Exception(data["mensaje"] ?? "Error en casos");
    } catch (e) {
      throw Exception("Error al obtener casos: $e");
    }
  }

  /// ✅ Obtener perfil del contador
  static Future<Map<String, dynamic>> obtenerPerfil(int idContador) async {
    try {
      final response = await http.get(Uri.parse("$perfilEndpoint?id=$idContador"));
      if (kDebugMode) debugPrint("Respuesta perfil: ${response.body}");

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        // 🔹 Ajuste: el backend devuelve "perfil"
        return data["perfil"] as Map<String, dynamic>;
      }
      return {
        "success": false,
        "mensaje": data["mensaje"] ?? "Error en perfil"
      };
    } catch (e) {
      return {
        "success": false,
        "mensaje": "Error al obtener perfil: $e"
      };
    }
  }

  /// ✅ Obtener ingresos del contador
  static Future<List<dynamic>> obtenerIngresos(int idContador) async {
    try {
      final response = await http.get(Uri.parse("$ingresosEndpoint?id=$idContador"));
      if (kDebugMode) debugPrint("Respuesta ingresos: ${response.body}");

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        return data["ingresos"] ?? [];
      }
      throw Exception(data["mensaje"] ?? "Error en ingresos");
    } catch (e) {
      throw Exception("Error al obtener ingresos: $e");
    }
  }

  /// ✅ Actualizar estado de un caso
  static Future<String> actualizarCaso(int idCaso, String estado) async {
    try {
      final response = await http.post(
        Uri.parse(actualizarCasoEndpoint),
        body: {
          "id_caso": idCaso.toString(),
          "estado": estado,
        },
      );
      if (kDebugMode) debugPrint("Respuesta actualizar caso: ${response.body}");

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        return data["mensaje"] ?? "Caso actualizado";
      }
      throw Exception(data["mensaje"] ?? "Error al actualizar caso");
    } catch (e) {
      throw Exception("Error al actualizar caso: $e");
    }
  }

  /// ✅ Listar documentos por contador
  static Future<List<dynamic>> obtenerDocumentos(int idContador) async {
    try {
      final response = await http.get(
        Uri.parse("$documentosEndpoint?accion=listar&contador_id=$idContador"),
      );
      if (kDebugMode) debugPrint("Respuesta documentos: ${response.body}");

      final data = json.decode(response.body);
      // 🔹 Ajuste: puede venir como lista o como objeto con "documentos"
      return data is List ? data : (data["documentos"] ?? []);
    } catch (e) {
      throw Exception("Error al obtener documentos: $e");
    }
  }

  /// ✅ Obtener detalle de un documento
  static Future<Map<String, dynamic>> obtenerDetalleDocumento(String ticket) async {
    try {
      final response = await http.get(
        Uri.parse("$documentosEndpoint?accion=detalle&ticket=$ticket"),
      );
      if (kDebugMode) debugPrint("Respuesta detalle documento: ${response.body}");

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      throw Exception("Error al obtener detalle documento: $e");
    }
  }

  /// ✅ Insertar nuevo documento
  static Future<String> insertarDocumento(Map<String, dynamic> documento) async {
    try {
      final response = await http.post(
        Uri.parse(documentosEndpoint),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "accion": "insertar",
          ...documento,
        }),
      );
      if (kDebugMode) debugPrint("Respuesta insertar documento: ${response.body}");

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        return data["mensaje"] ?? "Documento insertado correctamente";
      }
      throw Exception(data["error"] ?? "Error al insertar documento");
    } catch (e) {
      throw Exception("Error al insertar documento: $e");
    }
  }

  /// ✅ Validar documento
  static Future<String> validarDocumento(String ticket, String estatus, String comentarios, int validadoPor) async {
    try {
      final response = await http.post(
        Uri.parse(documentosEndpoint),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "accion": "validar",
          "ticket": ticket,
          "estatus": estatus,
          "comentarios": comentarios,
          "validado_por": validadoPor,
        }),
      );
      if (kDebugMode) debugPrint("Respuesta validar documento: ${response.body}");

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        return data["mensaje"] ?? "Documento validado correctamente";
      }
      throw Exception(data["error"] ?? "Error al validar documento");
    } catch (e) {
      throw Exception("Error al validar documento: $e");
    }
  }
}