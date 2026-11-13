import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/data/mock/mock_catalog.dart';
import 'package:sexy_starline/data/remote/starline_mappers.dart';
import 'package:sexy_starline/domain/entities/obd_params.dart';

void main() {
  group('StarlineMappers.obdParamsFromJson', () {
    test('parses fuel percent, mileage and errors', () {
      final obd = StarlineMappers.obdParamsFromJson('111', {
        'code': 200,
        'obd_params': {
          'fuel': {'val': 32, 'ts': 1705392271, 'type': 'percents'},
          'errors': {'val': 0, 'ts': 1705137991},
          'mileage': {'val': 65266, 'ts': 1705380470},
        },
      });

      expect(obd.deviceId, '111');
      expect(obd.fuelValue, 32);
      expect(obd.fuelUnit, ObdFuelUnit.percent);
      expect(obd.fuelLabelRu, '32 %');
      expect(obd.mileageKm, 65266);
      expect(obd.mileageLabelRu, '65266 км');
      expect(obd.errorCount, 0);
      expect(obd.errorsLabelRu, 'Нет ошибок');
      expect(obd.hasAny, isTrue);
    });

    test('parses litres fuel and nested wrapper', () {
      final obd = StarlineMappers.obdParamsFromJson('d1', {
        'obd_params': {
          'obd_params': {
            'fuel': {'val': 28.5, 'type': 'litres'},
            'mileage': {'val': 1200},
            'errors': {'val': 2},
          },
        },
      });
      expect(obd.fuelUnit, ObdFuelUnit.litres);
      expect(obd.fuelLabelRu, '28.5 л');
      expect(obd.errorsLabelRu, '2 ошибки');
    });
  });

  group('StarlineMappers.tracksFromJson', () {
    test('parses ways with point maps', () {
      final begin = DateTime.utc(2024, 1, 16);
      final end = begin.add(const Duration(hours: 24));
      final period = StarlineMappers.tracksFromJson(
        '111',
        {
          'code': 200,
          'ways': [
            {
              'id': 'w1',
              'begin': 1705392000,
              'end': 1705393800,
              'mileage': 6.4,
              'duration': 1800,
              'points': [
                {'x': 55.7784, 'y': 37.5865, 't': 1705392000},
                {'x': 55.7790, 'y': 37.5900, 't': 1705392600},
                {'x': 55.7800, 'y': 37.5950, 't': 1705393800},
              ],
            },
          ],
        },
        begin: begin,
        end: end,
      );

      expect(period.tracks, hasLength(1));
      final track = period.tracks.single;
      expect(track.id, 'w1');
      expect(track.points, hasLength(3));
      expect(track.mileageKm, closeTo(6.4, 0.01));
      expect(track.duration, const Duration(seconds: 1800));
      expect(track.hasGeometry, isTrue);
      expect(track.mileageLabelRu, '6.4 км');
    });

    test('parses array points [lat, lon, ts]', () {
      final begin = DateTime.now();
      final period = StarlineMappers.tracksFromJson(
        'x',
        {
          'ways': [
            {
              'points': [
                [55.1, 37.1, 1700000000],
                [55.2, 37.2, 1700000600],
              ],
              'mileage': 12,
            },
          ],
        },
        begin: begin,
        end: begin.add(const Duration(hours: 1)),
      );
      expect(period.tracks.single.points, hasLength(2));
      expect(period.tracks.single.points.first.latitude, closeTo(55.1, 0.001));
    });
  });

  group('Device capability gates', () {
    test('BMW demo supports OBD and tracks', () {
      final bmw = MockCatalog.devices.first;
      expect(bmw.supportsObd, isTrue);
      expect(bmw.supportsTracks, isTrue);
      expect(MockCatalog.obdFor(bmw.id)?.fuelValue, 42);
      expect(MockCatalog.tracksFor(bmw.id).tracks, isNotEmpty);
    });

    test('shared Vesta has neither OBD nor useful tracks gate beyond state', () {
      final vesta = MockCatalog.devices.last;
      expect(vesta.supportsObd, isFalse);
      expect(vesta.supportsTracks, isFalse);
      expect(MockCatalog.obdFor(vesta.id), isNull);
    });

    test('Skoda has tracks but no OBD', () {
      final skoda = MockCatalog.devices[1];
      expect(skoda.supportsTracks, isTrue);
      expect(skoda.supportsObd, isFalse);
      expect(MockCatalog.obdFor(skoda.id), isNull);
    });
  });

  group('ObdParams labels', () {
    test('summary concatenates available fields', () {
      const obd = ObdParams(
        deviceId: '1',
        fuelValue: 40,
        fuelUnit: ObdFuelUnit.percent,
        mileageKm: 1000,
        errorCount: 1,
      );
      expect(obd.summaryLabelRu, contains('Топливо'));
      expect(obd.summaryLabelRu, contains('Пробег'));
      expect(obd.summaryLabelRu, contains('1 ошибка'));
    });
  });
}
