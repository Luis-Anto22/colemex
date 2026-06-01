import 'api_client.dart';

class CalificacionesApi {
  final ApiClient client;

  CalificacionesApi(this.client);

  Future<void> crearCalificacion({
    required int profesionalId,
    required int clienteId,
    required int estrellas,
    String comentario = '',
    int? casoId,
    int? notificacionId,
  }) async {
    final res = await client.post(
      '/common/calificaciones',
      {
        'profesional_id': profesionalId,
        'cliente_id': clienteId,
        'estrellas': estrellas,
        'comentario': comentario,
        if (casoId != null) 'caso_id': casoId,
        if (notificacionId != null) 'notificacion_id': notificacionId,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al guardar calificación');
    }
  }
}