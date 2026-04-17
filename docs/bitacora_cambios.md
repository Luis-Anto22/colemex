# Bitacora De Cambios

## 2026-04-16 - Mapa fullscreen unificado

### Archivos nuevos
- `lib/widgets/app_brand_background.dart`
  - Capa visual global para mostrar el logo como fondo tipo marca de agua en toda la app.
  - Refuerzo de visibilidad: logo central + esquinas, con opacidad y tinte adaptado al tema para mantener legibilidad.
- `lib/screens/common/ubicacion/fullscreen_location_picker_screen.dart`
  - Selector fullscreen reusable para elegir/arrastrar ubicacion y regresar coordenadas al flujo origen.
- `lib/screens/cliente_panels/profesionales_mapa_fullscreen.dart`
  - Mapa fullscreen de profesionales cercanos; devuelve el profesional tocado.
- `docs/cambios_en_curso.md`
  - Documento operativo con estado y alcance del cambio.

### Archivos modificados
- `lib/main.dart`
  - Conecta `AppBrandBackground` en `MaterialApp.builder` para aplicar el logo de fondo en todas las pantallas.
- `lib/screens/common/ubicacion/ubicacion_tiempo_real_screen.dart`
  - Integra el selector fullscreen en deteccion y edicion visual de ubicacion.
  - Elimina mapa embebido para cumplir visibilidad fullscreen.
  - En "Confirmar ubicacion" de tiempo real bloquea seleccion manual (solo confirmacion del punto detectado).
- `lib/screens/cliente_panels/panel_servicios.dart`
  - Reemplaza mapa embebido por apertura de pantalla fullscreen.
  - Conserva el flujo de ficha de profesional usando el resultado retornado.
- `lib/screens/localizacion.dart`
  - Agrega flecha de regreso explicita en AppBar.
- `lib/screens/abogados/ubicacion_despacho_screen.dart`
  - Agrega flecha de regreso explicita en AppBar.
- `lib/screens/abogados/buscar_abogado_map_screen.dart`
  - Agrega flecha de regreso explicita en AppBar.

### Integracion entre archivos
- `UbicacionTiempoRealScreen` -> `FullscreenLocationPickerScreen`
  - Abre mapa fullscreen, recibe `LatLng`, actualiza preview y guarda por `CommonApi`.
- `PanelServicios` -> `ProfesionalesMapaFullscreen`
  - Abre mapa fullscreen con lista de profesionales y ubicacion del cliente.
  - Recibe profesional seleccionado y llama al flujo existente de detalle/solicitud.
