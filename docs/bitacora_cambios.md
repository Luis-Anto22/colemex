# Bitacora de cambios

## 2026-04-16 - Reaplicacion de cambios de la sesion

### Resumen
Se reaplico la implementacion completa para hacer funcional el guardado de ubicacion en todas las pantallas con mapa, con fallback para entornos mixtos (legacy + Laravel).

### Detalle tecnico

- `ApiClient`
  - Soporte para `API_BASE_URL` por `dart-define`.
  - Nuevo metodo `put()` para endpoints REST.
  - Manejo de errores HTTP con preview recortado del body.

- `CommonApi`
  - `getUbicacion()` y `actualizarUbicacion()` con fallback automatico cuando `/common/ubicacion.php` devuelve 404.
  - Fallback admin basado en:
    - `GET /admin/profesionales`
    - `PUT /admin/profesionales/{id}`
  - Construccion de payload preservando campos del profesional para evitar perdida de informacion.

- `UniversalLocationButton`
  - `lat/lng` ahora opcionales.
  - Resolucion de `id` desde `SharedPreferences` si no llega por constructor.
  - Deteccion GPS on-demand si no hay coordenadas de pantalla.
  - Fallback adicional a `/universal/ubicacion_universal.php`.

- Paneles
  - `agente_imobiliario.dart`: se quitan coordenadas de ejemplo hardcodeadas.
  - `psicologos.dart`: se quitan coordenadas de ejemplo hardcodeadas.
  - `contador_panel.dart`: boton siempre visible; ya no depende de lat/lng del perfil.

- `ubicacion_despacho_screen.dart`
  - Migra a `CommonApi` para leer/guardar ubicacion.
  - Conserva fallback a endpoints legacy de abogado.
  - AppBar con flecha de regreso explicita.

- Comentarios de integracion
  - Se documentaron en codigo los puntos de conexion entre:
    - pantallas de mapa,
    - `UniversalLocationButton`,
    - `CommonApi`,
    - `ApiClient`,
    - rutas backend (`/common/ubicacion.php`, `/admin/profesionales`, `/universal/ubicacion_universal.php`).

- Fullscreen de mapas con regreso
  - Se agrego `lib/screens/common/ubicacion/mapa_selector_fullscreen_screen.dart` para seleccionar punto en pantalla completa.
  - `ubicacion_tiempo_real_screen.dart` dejo de usar mapas embebidos/dialog y ahora abre el selector fullscreen para confirmar y guardar.
  - `panel_servicios.dart` dejo de renderizar el mapa dentro del panel y ahora abre `_MapaProfesionalesFullScreen` en ruta dedicada.
  - Se agrego flecha de regreso explicita en `localizacion.dart` y `buscar_abogado_map_screen.dart`.
  - En el mapa fullscreen de servicios, al tocar un pin se regresa al panel y se abre la ficha del profesional.

### Resultado esperado

El boton `Guardar ubicacion` debe funcionar en pantallas con mapa aunque una de las rutas de backend no exista en un entorno especifico, porque ahora el flujo intenta rutas alternas de forma controlada.
