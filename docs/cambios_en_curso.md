# Cambios en curso

Fecha: 2026-04-16

## Objetivo activo
Hacer funcional el guardado de ubicacion en todas las pantallas que usan mapa, reutilizando el flujo comun y manteniendo compatibilidad con endpoints legacy.

## Cambios aplicados

1. `ApiClient` ahora permite definir `API_BASE_URL` por `--dart-define` y agrega metodo `PUT`.
2. `CommonApi` ahora guarda y consulta ubicacion con fallback:
   - Primero usa `/common/ubicacion.php`.
   - Si recibe HTTP 404, usa fallback REST de Laravel:
     - `GET /admin/profesionales`
     - `PUT /admin/profesionales/{id}`
3. `UniversalLocationButton` se volvio tolerante:
   - `lat/lng` ahora son opcionales.
   - Si no recibe coordenadas, detecta GPS en el momento.
   - Si no recibe `idProfesional`, intenta resolver `id` desde `SharedPreferences`.
   - Incluye fallback extra al endpoint `/universal/ubicacion_universal.php`.
4. Paneles actualizados para usar el boton sin coordenadas hardcodeadas:
   - `agente_imobiliario.dart`
   - `psicologos.dart`
   - `contador_panel.dart` (ahora siempre visible)
5. `ubicacion_despacho_screen.dart` migro al flujo comun y mantiene fallback legacy.
6. Se agregaron comentarios descriptivos en el codigo nuevo para explicar el flujo agregado.
7. Se agregaron comentarios de integracion entre archivos (pantallas -> widget -> servicios -> endpoints).
8. El mapa de ubicacion ahora se abre en pantalla completa en flujos donde antes se mostraba embebido:
   - `ubicacion_tiempo_real_screen.dart` ahora usa `mapa_selector_fullscreen_screen.dart`.
   - `panel_servicios.dart` ahora abre `_MapaProfesionalesFullScreen` en otra pantalla.
9. Se agrego flecha de regreso explicita en pantallas de mapa:
   - `localizacion.dart`
   - `buscar_abogado_map_screen.dart`
   - `_MapaProfesionalesFullScreen` (nuevo)
   - `mapa_selector_fullscreen_screen.dart` (nuevo)

## Archivos modificados

- `lib/services/api_services/api_client.dart`
- `lib/services/api_services/common_api.dart`
- `lib/screens/universal_location_button.dart`
- `lib/screens/agente_imobiliario/agente_imobiliario.dart`
- `lib/screens/psicologos/psicologos.dart`
- `lib/screens/contador/contador_panel.dart`
- `lib/screens/abogados/ubicacion_despacho_screen.dart`
- `lib/screens/common/ubicacion/mapa_selector_fullscreen_screen.dart`
- `lib/screens/common/ubicacion/ubicacion_tiempo_real_screen.dart`
- `lib/screens/cliente_panels/panel_servicios.dart`
- `lib/screens/localizacion.dart`
- `lib/screens/abogados/buscar_abogado_map_screen.dart`
- `docs/cambios_en_curso.md`
- `docs/bitacora_cambios.md`

## Nuevo flujo de guardado de ubicacion

1. Usuario toca `Guardar ubicacion`.
2. Se resuelve `idProfesional` (parametro o `SharedPreferences.id`).
3. Se obtienen coordenadas:
   - De la pantalla actual (si fueron enviadas), o
   - GPS actual (si no hay coordenadas).
4. Se intenta guardar en `/common/ubicacion.php`.
5. Si responde 404, se ejecuta fallback admin (`GET /admin/profesionales` + `PUT /admin/profesionales/{id}`).
6. Si aun falla y esta activo el fallback legacy, se intenta `/universal/ubicacion_universal.php`.
7. Se notifica resultado por `SnackBar`.

## Nota de configuracion

Para pruebas locales, ejecutar Flutter con base URL personalizada:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2/app.com/api
```

Ajustar host segun dispositivo (emulador Android, iOS simulator o dispositivo fisico).
