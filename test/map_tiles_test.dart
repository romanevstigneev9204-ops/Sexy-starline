import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/core/config/map_tiles.dart';

void main() {
  test('default tiles use free OSM without a key', () {
    expect(MapTilesConfig.urlTemplate, contains('openstreetmap.org'));
    expect(MapTilesConfig.urlTemplate, isNot(contains('cartocdn')));
    expect(MapTilesConfig.isCustomUrl, isFalse);
    expect(MapTilesConfig.applyNightFilter, isTrue);
  });
}
