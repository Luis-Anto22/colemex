import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiServiceContador {
  static const String baseUrl =
      "https://corporativolegaldigital.com/api/contador";

  static const String ingresosEndpoint = "$baseUrl/contador_ingresos.php";
  static const String documentosEndpoint = "$baseUrl/contador_documentos.php";

  /// ✅ Obtener casos contables desde Laravel
  static Future<List<dynamic>> obtenerCasos(int idContador) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/casos?contador_id=$idContador"),
        headers: {
          "Accept": "application/json",
        },
      );

      if (kDebugMode) {
        debugPrint("Respuesta casos Laravel: ${response.body}");
      }

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        return data["data"] ?? [];
      }

      throw Exception(data["message"] ?? "Error en casos");
    } catch (e) {
      throw Exception("Error al obtener casos: $e");
    }
  }
  
  static Future<List<dynamic>> obtenerClientesSolicitantes() async {
  try {
    final response = await http.get(
      Uri.parse("$baseUrl/clientes-solicitantes"),
      headers: {
        "Accept": "application/json",
      },
    );

    if (kDebugMode) {
      debugPrint("Respuesta clientes solicitantes: ${response.body}");
    }

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data["success"] == true) {
      return data["data"] ?? [];
    }

    throw Exception(data["message"] ?? "Error al obtener clientes");
  } catch (e) {
    throw Exception("Error al obtener clientes solicitantes: $e");
  }
}

  /// ✅ Crear caso contable desde Laravel
  static Future<String> crearCasoContable({
    required int contadorId,
    required int clienteId,
    required String titulo,
    required String descripcion,
    String estado = 'pendiente',
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/casos"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "contador_id": contadorId,
          "cliente_id": clienteId,
          "titulo": titulo,
          "descripcion": descripcion,
          "estado": estado,
        }),
      );

      if (kDebugMode) {
        debugPrint("Respuesta crear caso Laravel: ${response.body}");
      }

      final data = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["success"] == true) {
        return data["message"] ?? "Caso creado correctamente";
      }

      throw Exception(data["message"] ?? "No se pudo crear el caso");
    } catch (e) {
      throw Exception("Error al crear caso: $e");
    }
  }

  /// ✅ Obtener perfil del contador desde Laravel
  static Future<Map<String, dynamic>> obtenerPerfil(int idContador) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/perfil/$idContador"),
        headers: {
          "Accept": "application/json",
        },
      );

      if (kDebugMode) {
        debugPrint("Respuesta perfil Laravel: ${response.body}");
      }

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        return {
          "success": true,
          "perfil": data["data"],
        };
      }

      return {
        "success": false,
        "mensaje": data["message"] ?? "Error al obtener perfil",
      };
    } catch (e) {
      return {
        "success": false,
        "mensaje": "Error al obtener perfil: $e",
      };
    }
  }

  /// ✅ Obtener ingresos del contador
  static Future<List<dynamic>> obtenerIngresos(int idContador) async {
    try {
      final response = await http.get(
        Uri.parse("$ingresosEndpoint?id=$idContador"),
      );

      if (kDebugMode) {
        debugPrint("Respuesta ingresos: ${response.body}");
      }

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        return data["ingresos"] ?? [];
      }

      throw Exception(data["mensaje"] ?? "Error en ingresos");
    } catch (e) {
      throw Exception("Error al obtener ingresos: $e");
    }
  }

  /// ✅ Actualizar estado de caso contable desde Laravel
  static Future<String> actualizarCaso(int idCaso, String estado) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/casos/$idCaso/estado"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "estado": estado,
        }),
      );

      if (kDebugMode) {
        debugPrint("Respuesta actualizar caso Laravel: ${response.body}");
      }

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        return data["message"] ?? "Caso actualizado correctamente";
      }

      throw Exception(data["message"] ?? "Error al actualizar caso");
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

      if (kDebugMode) {
        debugPrint("Respuesta documentos: ${response.body}");
      }

      final data = json.decode(response.body);

      return data is List ? data : (data["documentos"] ?? []);
    } catch (e) {
      throw Exception("Error al obtener documentos: $e");
    }
  }

  /// ✅ Obtener detalle de documento
  static Future<Map<String, dynamic>> obtenerDetalleDocumento(
    String ticket,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("$documentosEndpoint?accion=detalle&ticket=$ticket"),
      );

      if (kDebugMode) {
        debugPrint("Respuesta detalle documento: ${response.body}");
      }

      return json.decode(response.body);
    } catch (e) {
      throw Exception("Error al obtener detalle documento: $e");
    }
  }

  /// ✅ Insertar documento
  static Future<String> insertarDocumento(
    Map<String, dynamic> documento,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(documentosEndpoint),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "accion": "insertar",
          ...documento,
        }),
      );

      if (kDebugMode) {
        debugPrint("Respuesta insertar documento: ${response.body}");
      }

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
  static Future<String> validarDocumento(
    String ticket,
    String estatus,
    String comentarios,
    int validadoPor,
  ) async {
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

      if (kDebugMode) {
        debugPrint("Respuesta validar documento: ${response.body}");
      }

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