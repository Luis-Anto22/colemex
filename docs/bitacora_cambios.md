# Bitacora De Cambios

## 2026-04-16 - Mapa fullscreen unificado

### Archivos nuevos
- `lib/services/api_services/notificaciones_api.dart`
  - Cliente Flutter para consumir listado, conteo y marcado de notificaciones en API Laravel.
- `lib/widgets/notification_badge_icon.dart`
  - Campana reutilizable con contador pequeno (badge) de no leidas para AppBar.
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
- `lib/widgets_global/notificaciones_widget.dart`
  - Se migra de `notificaciones.php` legado a `NotificacionesApi` (rutas Laravel).
  - Permite marcar una o todas como leidas y refrescar listado.
- `lib/screens/common/notificaciones/notificaciones_screen.dart`
  - Pasa de demo estatico a pantalla real conectada al API.
  - Obtiene `profesionalId` por argumento o desde `SharedPreferences`.
- `lib/screens/agente_imobiliario/agente_imobiliario.dart`
  - AppBar usa `NotificationBadgeIcon` con conteo real para `agenteId`.
- `lib/main.dart`
  - Conecta `AppBrandBackground` en `MaterialApp.builder` para aplicar el logo de fondo en todas las pantallas.
- `lib/screens/agente_imobiliario/agente_imobiliario.dart`
  - Refactor visual completo para alinearlo con los paneles de Investigador y Valuador.
  - Mejora contraste de texto y estructura en tarjetas para legibilidad.
  - Reemplaza acciones rapidas en fila por grid responsivo para evitar elementos amontonados.
  - Prueba de branding: se ajusta la paleta al estilo de login (`amber` + negro + blanco) para validar adopcion en otras pantallas.
  - Conserva enlaces a agenda, propiedades, historial, ingresos, calificaciones, notificaciones, ubicacion, configuracion y soporte.
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
- `lib/screens/investigador/investigador.dart`
  - AppBar usa campana con badge y abre `NotificacionesScreen(profesionalId: investigadorId)`.
- `lib/screens/valuador/valuador.dart`
  - AppBar usa campana con badge y abre `NotificacionesScreen(profesionalId: valuadorId)`.
- `lib/screens/perito_criminalistica/perito.dart`
  - AppBar usa campana con badge y abre `NotificacionesScreen(profesionalId: peritoId)`.
- `lib/screens/ajustador/ajustador.dart`
  - AppBar usa campana con badge y abre `NotificacionesScreen(profesionalId: ajustadorId)`.
- `lib/screens/agente_crediticio/agente_panel.dart`
  - AppBar usa campana con badge para `idAgente`.

### Integracion entre archivos
- Laravel local (`C:\xampp\htdocs\app.com\advocatus`) -> Flutter (`colemex`)
  - `routes/api.php` expone `/api/notificaciones/*`
  - `NotificacionesApi` consume esos endpoints
  - `NotificationBadgeIcon` usa `count` para mostrar numero pequeno junto al icono
  - `NotificacionesWidget` usa listado y marcado de leidas
- `PanelAgentesInmobiliarios` -> modulos de agente inmobiliario
  - Navega a `PantallaAgendaInmuebles`, `PantallaPropiedades`, `PantallaHistorialInmuebles`,
    `PantallaIngresosInmuebles`, `PantallaCalificacionesInmuebles`,
    `PantallaNotificacionesInmuebles`, `PantallaConfiguracionInmuebles`,
    `PantallaContactoSoporteInmuebles` y `LocalizacionPanel`.
- `UbicacionTiempoRealScreen` -> `FullscreenLocationPickerScreen`
  - Abre mapa fullscreen, recibe `LatLng`, actualiza preview y guarda por `CommonApi`.
- `PanelServicios` -> `ProfesionalesMapaFullscreen`
  - Abre mapa fullscreen con lista de profesionales y ubicacion del cliente.
  - Recibe profesional seleccionado y llama al flujo existente de detalle/solicitud.

- Ajuste 2026-04-17: fondo de logo visible en web (sin ColorFiltered, opacidad mayor).
