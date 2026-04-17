import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceCrediticio {
  static const String _base = "https://corporativolegaldigital.com/api/crediticio/agente_crediticio.php";

  // ==============================
  // GET
  // ==============================

  static Future<List<dynamic>> listarClientes(int agenteId) async {
    final uri = Uri.parse("$_base?accion=listar_clientes&agente_id=$agenteId");
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("listarClientes: ${res.body}");
  }

  static Future<Map<String, dynamic>> detalleCredito(int id) async {
    final uri = Uri.parse("$_base?accion=detalle_credito&id=$id");
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("detalleCredito: ${res.body}");
  }

  static Future<List<dynamic>> listarDocumentos(int casoId) async {
    final uri = Uri.parse("$_base?accion=listar_documentos&caso_id=$casoId");
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("listarDocumentos: ${res.body}");
  }

  static Future<List<dynamic>> listarBitacora(int casoId) async {
    final uri = Uri.parse("$_base?accion=listar_bitacora&caso_id=$casoId");
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("listarBitacora: ${res.body}");
  }

  static Future<List<dynamic>> listarNotificaciones(int agenteId) async {
    final uri = Uri.parse("$_base?accion=listar_notificaciones&agente_id=$agenteId");
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("listarNotificaciones: ${res.body}");
  }

  static Future<List<dynamic>> listarCalificaciones(int agenteId) async {
    final uri = Uri.parse("$_base?accion=listar_calificaciones&agente_id=$agenteId");
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("listarCalificaciones: ${res.body}");
  }

  static Future<Map<String, dynamic>> dashboardAgente(int agenteId) async {
    final uri = Uri.parse("$_base?accion=dashboard_agente&agente_id=$agenteId");
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("dashboardAgente: ${res.body}");
  }

  static Future<List<dynamic>> listarCasos(int agenteId) async {
    final uri = Uri.parse("$_base?accion=listar_casos&agente_id=$agenteId");
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("listarCasos: ${res.body}");
  }

  static Future<Map<String, dynamic>> perfilAgente(int agenteId) async {
    final uri = Uri.parse("$_base?accion=perfil_agente&agente_id=$agenteId");
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("perfilAgente: ${res.body}");
  }

  // ==============================
  // POST
  // ==============================

  static Future<Map<String, dynamic>> insertarCredito(Map<String, dynamic> data) async {
    final uri = Uri.parse("$_base?accion=insertar_credito");
    final res = await http.post(uri,
        body: jsonEncode(data), headers: {"Content-Type": "application/json"});
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("insertarCredito: ${res.body}");
  }

  static Future<Map<String, dynamic>> crearCaso(Map<String, dynamic> data) async {
    final uri = Uri.parse("$_base?accion=crear_caso");
    final res = await http.post(uri,
        body: jsonEncode(data), headers: {"Content-Type": "application/json"});
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("crearCaso: ${res.body}");
  }

  static Future<Map<String, dynamic>> subirDocumento(Map<String, dynamic> data) async {
    final uri = Uri.parse("$_base?accion=subir_documento");
    final res = await http.post(uri,
        body: jsonEncode(data), headers: {"Content-Type": "application/json"});
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("subirDocumento: ${res.body}");
  }

  static Future<Map<String, dynamic>> agregarBitacora(Map<String, dynamic> data) async {
    final uri = Uri.parse("$_base?accion=agregar_bitacora");
    final res = await http.post(uri,
        body: jsonEncode(data), headers: {"Content-Type": "application/json"});
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("agregarBitacora: ${res.body}");
  }

  static Future<Map<String, dynamic>> crearNotificacion(Map<String, dynamic> data) async {
    final uri = Uri.parse("$_base?accion=crear_notificacion");
    final res = await http.post(uri,
        body: jsonEncode(data), headers: {"Content-Type": "application/json"});
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("crearNotificacion: ${res.body}");
  }

  static Future<Map<String, dynamic>> leerNotificacion(Map<String, dynamic> data) async {
    final uri = Uri.parse("$_base?accion=leer_notificacion");
    final res = await http.post(uri,
        body: jsonEncode(data), headers: {"Content-Type": "application/json"});
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("leerNotificacion: ${res.body}");
  }

  static Future<Map<String, dynamic>> crearCalificacion(Map<String, dynamic> data) async {
    final uri = Uri.parse("$_base?accion=crear_calificacion");
    final res = await http.post(uri,
        body: jsonEncode(data), headers: {"Content-Type": "application/json"});
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("crearCalificacion: ${res.body}");
  }

  // ==============================
  // PUT
  // ==============================

  static Future<Map<String, dynamic>> actualizarEstadoCredito(Map<String, dynamic> data) async {
    final uri = Uri.parse("$_base?accion=actualizar_estado_credito");
    final res = await http.put(uri,
        body: jsonEncode(data), headers: {"Content-Type": "application/json"});
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("actualizarEstadoCredito: ${res.body}");
  }

  static Future<Map<String, dynamic>> actualizarEstadoCaso(Map<String, dynamic> data) async {
    final uri = Uri.parse("$_base?accion=actualizar_estado_caso");
    final res = await http.put(uri,
        body: jsonEncode(data), headers: {"Content-Type": "application/json"});
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("actualizarEstadoCaso: ${res.body}");
  }

  // ==============================
  // DELETE
  // ==============================

  static Future<Map<String, dynamic>> eliminarDocumento(int id) async {
    final uri = Uri.parse("$_base?accion=eliminar_documento&id=$id");
    final res = await http.delete(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("eliminarDocumento: ${res.body}");
  }

  static Future<Map<String, dynamic>> eliminarBitacora(int id) async {
    final uri = Uri.parse("$_base?accion=eliminar_bitacora&id=$id");
    final res = await http.delete(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("eliminarBitacora: ${res.body}");
  }
}