# Cambios En Curso

## Objetivo actual
- Mover todos los mapas de ubicacion a una pantalla dedicada fullscreen.
- Mantener flecha de regreso visible en cada pantalla de mapa.

## Cambios aplicados
- Se agrego integracion completa de notificaciones (Laravel + Flutter):
  - Backend Laravel local creado en `C:\xampp\htdocs\app.com\advocatus`:
    - Model: `app/Models/Notificacion.php` (tabla `notificaciones`)
    - Controller: `app/Http/Controllers/Api/Common/NotificacionController.php`
    - Rutas: `routes/api.php` bajo prefijo `/api/notificaciones`
  - Endpoints nuevos:
    - `GET /api/notificaciones` (listado)
    - `GET /api/notificaciones/count` (conteo no leidas para badge)
    - `POST /api/notificaciones/{id}/leer` (marcar una)
    - `POST /api/notificaciones/leer-todas` (marcar todas)
  - Flutter:
    - Servicio nuevo `lib/services/api_services/notificaciones_api.dart`
    - Widget de campana con badge `lib/widgets/notification_badge_icon.dart`
    - `NotificacionesWidget` migrado a API nueva
    - `NotificacionesScreen` ahora resuelve `profesionalId` por argumento o sesion
    - Badge conectado en AppBar de paneles: agente inmobiliario, investigador, valuador, perito, ajustador y agente crediticio.
- Se rediseño `PanelAgentesInmobiliarios` para homologarlo con Investigador/Valuador:
  - Nuevo layout con mejor contraste para legibilidad (fondo + overlay + tarjetas).
  - Se reemplazo la fila compacta de acciones rapidas por grid responsivo con `Wrap`.
  - Se mantuvo navegacion a los mismos modulos del agente inmobiliario.
  - Ajuste adicional de estilo: se aplicaron colores y tonos de `login_screen.dart` (acento amber, overlays negros y contornos claros) para evaluacion visual.
  - Archivo:
    - `lib/screens/agente_imobiliario/agente_imobiliario.dart`
- Se agrego fondo de marca global con el logo institucional:
  - Se implemento `AppBrandBackground` para dibujar el logo como marca de agua elegante y de baja opacidad.
  - Se conecto en `MaterialApp.builder` para cubrir todas las pantallas sin editar cada `Scaffold`.
  - Ajuste visual aplicado: se agrego una marca central y dos marcas laterales con mejor contraste para que el fondo sea perceptible sin tapar contenido.
  - Archivos:
    - `lib/widgets/app_brand_background.dart`
    - `lib/main.dart`
- Se agrego un selector reusable de ubicacion fullscreen:
  - `lib/screens/common/ubicacion/fullscreen_location_picker_screen.dart`
- `UbicacionTiempoRealScreen` ya no usa mapa embebido ni dialog con mapa:
  - Ahora abre el selector fullscreen para confirmar y editar coordenadas.
  - Excepcion aplicada: en "Confirmar ubicacion" del flujo de tiempo real el usuario solo confirma el punto detectado (sin mover pin ni tocar mapa).
  - Archivo: `lib/screens/common/ubicacion/ubicacion_tiempo_real_screen.dart`
- `PanelServicios` ya no renderiza mapa dentro del panel:
  - Ahora abre una pantalla de mapa fullscreen para profesionales cercanos.
  - Al tocar un pin, el mapa regresa el profesional seleccionado para mostrar la ficha.
  - Archivos:
    - `lib/screens/cliente_panels/panel_servicios.dart`
    - `lib/screens/cliente_panels/profesionales_mapa_fullscreen.dart`
- Se forzo flecha de regreso explicita en pantallas de mapa:
  - `lib/screens/localizacion.dart`
  - `lib/screens/abogados/ubicacion_despacho_screen.dart`
  - `lib/screens/abogados/buscar_abogado_map_screen.dart`

## Flujo nuevo (resumen)
1. Pantallas funcionales (paneles) disparan apertura de mapa fullscreen.
2. Usuario ajusta/selecciona punto o toca pin en mapa fullscreen.
3. Pantalla fullscreen retorna resultado al caller (`Navigator.pop(result)`).
4. Pantalla caller continua flujo normal (guardar ubicacion o mostrar detalle).
5. Panel de agente inmobiliario ahora usa tarjetas de alto contraste y acciones rapidas en grid para evitar saturacion visual.

- Ajuste web de marca de agua: se retiro ColorFiltered y se incremento opacidad para mejorar visibilidad del logo en navegador.
