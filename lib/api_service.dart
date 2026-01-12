import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2/COLEMEX/api'; // usa tu IP local o dominio

  Future<http.Response> loginAbogado(String correo, String clave) {
    return http.post(
      Uri.parse('$baseUrl/login-abogado.php'),
      body: {
        'correo': correo,
        'clave': clave,
      },
    );
  }

  Future<http.Response> obtenerCasos(String idAbogado) {
    return http.get(
      Uri.parse('$baseUrl/casos-abogado.php?id=$idAbogado'),
    );
  }

  Future<http.Response> subirDocumento({
    required String idCaso,
    required String descripcion,
    required String filePath,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/subir-documento.php'),
    );
    request.fields['id_caso'] = idCaso;
    request.fields['descripcion'] = descripcion;
    request.files.add(await http.MultipartFile.fromPath('documento', filePath));
    var response = await request.send();
    return http.Response.fromStream(response);
  }
}