import 'package:flutter_map/flutter_map.dart';

class MapStyles {
  /// ✅ OpenStreetMap oficial (permitido para apps móviles)
  static final TileLayer osm = TileLayer(
    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    userAgentPackageName: 'com.advocatus.app',
  );

  /// ✅ Carto claro (MUY estable)
  static final TileLayer cartoLight = TileLayer(
    urlTemplate:
        "https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
    subdomains: ['a', 'b', 'c'],
    userAgentPackageName: 'com.advocatus.app',
  );

  /// ✅ Carto oscuro (alternativa al Stadia)
  static final TileLayer cartoDark = TileLayer(
    urlTemplate:
        "https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png",
    subdomains: ['a', 'b', 'c'],
    userAgentPackageName: 'com.advocatus.app',
  );
}
