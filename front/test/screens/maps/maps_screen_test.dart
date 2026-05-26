import 'package:flutter_test/flutter_test.dart';
import 'package:front/screens/maps/maps_screen.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  test('should use Standard style for interactive place features', () {
    expect(mapsInteractiveStyleUri, MapboxStyles.STANDARD);
  });
}
