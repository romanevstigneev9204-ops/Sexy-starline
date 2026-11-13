import 'package:flutter/widgets.dart';

/// Free map tile config for Night Drive.
///
/// Default: OpenStreetMap raster tiles (no API key) + optional night color
/// filter so the base matches graphite UI without a paid dark-tile provider.
///
/// Override with `--dart-define`:
/// - `MAP_TILE_URL` — custom template (`{z}/{x}/{y}`, optional `{s}`, `{r}`, `{api_key}`)
/// - `MAP_TILE_KEY` — substituted into `{api_key}` when set
/// - `MAP_TILE_NIGHT_FILTER=true|false` — force night ColorFilter on/off
class MapTilesConfig {
  const MapTilesConfig._();

  static const String urlOverride = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: '',
  );

  static const String apiKey = String.fromEnvironment(
    'MAP_TILE_KEY',
    defaultValue: '',
  );

  /// When unset, night filter applies only for the built-in OSM default.
  static const String _nightFilterRaw = String.fromEnvironment(
    'MAP_TILE_NIGHT_FILTER',
    defaultValue: '',
  );

  /// OSM standard tiles — work without a key (respect OSM tile usage policy).
  static const String osmUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static const List<String> defaultSubdomains = ['a', 'b', 'c'];

  static String get urlTemplate {
    final raw = urlOverride.trim().isEmpty ? osmUrlTemplate : urlOverride.trim();
    if (apiKey.isEmpty) return raw;
    return raw.replaceAll('{api_key}', apiKey);
  }

  static bool get isCustomUrl => urlOverride.trim().isNotEmpty;

  static bool get applyNightFilter {
    switch (_nightFilterRaw.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
        return true;
      case 'false':
      case '0':
      case 'no':
        return false;
      default:
        // Built-in OSM is light; invert for Night Drive. Custom URLs
        // (e.g. Carto dark + key) are left untouched unless forced.
        return !isCustomUrl;
    }
  }

  static List<String> get subdomains {
    if (urlTemplate.contains('{s}')) return defaultSubdomains;
    return const [];
  }

  /// Approximate dark / Night Drive look over light OSM tiles.
  static const ColorFilter nightDriveFilter = ColorFilter.matrix(<double>[
    -0.35, -0.70, -0.15, 0, 255 * 0.22,
    -0.30, -0.65, -0.20, 0, 255 * 0.18,
    -0.20, -0.55, -0.35, 0, 255 * 0.28,
    0, 0, 0, 1, 0,
  ]);
}
