import 'package:flutter_test/flutter_test.dart';
import 'package:front/screens/maps/models/selected_map_place.dart';

void main() {
  test(
    'should decode point geometry when coordinates are returned as raw list',
    () {
      final coordinate = SelectedMapPlace.coordinateFromGeometry(
        <String?, Object?>{
          'type': 'Point',
          'coordinates': <Object?>[55.4507, -20.8789],
        },
      );

      expect(coordinate, isNotNull);
      expect(coordinate!.coordinates.lng, 55.4507);
      expect(coordinate.coordinates.lat, -20.8789);
    },
  );

  test('should return null when geometry is missing coordinates', () {
    final coordinate = SelectedMapPlace.coordinateFromGeometry(
      <String?, Object?>{'type': 'Point'},
    );

    expect(coordinate, isNull);
  });
}
