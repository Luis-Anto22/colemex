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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) return data;
        throw Exception(data["mensaje"] ?? "Error en dashboard");
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error al obtener dashboard: $e");
    }
  }

  /// ✅ Obtener casos asignados al contador
  static Future<List<dynamic>> obtenerCasos(int idContador) async {
    try {
      final response = await http.get(Uri.parse("$casosEndpoint?id=$idContador"));
      if (kDebugMode) debugPrint("Respuesta casos: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) return data["casos"];
        throw Exception(data["mensaje"] ?? "Error en casos");
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error al obtener casos: $e");
    }
  }

  /// ✅ Obtener perfil del contador
  static Future<Map<String, dynamic>> obtenerPerfil(int idContador) async {
    try {
      final response = await http.get(Uri.parse("$perfilEndpoint?id=$idContador"));
      if (kDebugMode) debugPrint("Respuesta perfil: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) return data["perfil"];
        throw Exception(data["mensaje"] ?? "Error en perfil");
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error al obtener perfil: $e");
    }
  }

  /// ✅ Obtener ingresos del contador
  static Future<List<dynamic>> obtenerIngresos(int idContador) async {
    try {
      final response = await http.get(Uri.parse("$ingresosEndpoint?id=$idContador"));
      if (kDebugMode) debugPrint("Respuesta ingresos: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) return data["ingresos"];
        throw Exception(data["mensaje"] ?? "Error en ingresos");
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) return data["mensaje"] ?? "Caso actualizado";
        throw Exception(data["mensaje"] ?? "Error al actualizar caso");
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data; // devuelve lista de documentos
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data; // devuelve el detalle del documento
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
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
          "ticket": documento["ticket"],
          "contador_id": documento["contador_id"],
          "cliente_id": documento["cliente_id"],
          "tipo_documento": documento["tipo_documento"],
          "archivo_url": documento["archivo_url"],
          "descripcion": documento["descripcion"],
          "mes_periodo": documento["mes_periodo"],
        }),
      );
      if (kDebugMode) debugPrint("Respuesta insertar documento: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) return "Documento insertado correctamente";
        throw Exception(data["error"] ?? "Error al insertar documento");
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) return "Documento validado correctamente";
        throw Exception(data["error"] ?? "Error al validar documento");
      } else {
        throw Exception("Error HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error al validar documento: $e");
    }
  }
}
