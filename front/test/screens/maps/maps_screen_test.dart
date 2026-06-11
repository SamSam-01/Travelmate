import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/screens/maps/maps_screen.dart';
import 'package:front/screens/maps/models/selected_map_place.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  test('should use Standard style for interactive place features', () {
    expect(mapsInteractiveStyleUri, MapboxStyles.STANDARD);
  });

  group('PickedPlacesBar', () {
    testWidgets('should render nothing when places list is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PickedPlacesBar(places: [], onRemove: _noop),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('should render chips for each picked place', (
      WidgetTester tester,
    ) async {
      const places = [
        SelectedMapPlace(
          name: 'Tour Eiffel',
          sourceLabel: 'Google',
          longitude: 2.2945,
          latitude: 48.8584,
        ),
        SelectedMapPlace(
          name: 'Louvre Museum',
          sourceLabel: 'Google',
          longitude: 2.3376,
          latitude: 48.8606,
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PickedPlacesBar(places: places, onRemove: _noop),
          ),
        ),
      );

      expect(find.text('Tour Eiffel'), findsOneWidget);
      expect(find.text('Louvre Museum'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(2));
    });

    testWidgets('should call onRemove with the correct index', (
      WidgetTester tester,
    ) async {
      var removedIndex = -1;
      const places = [
        SelectedMapPlace(
          name: 'Tour Eiffel',
          sourceLabel: 'Google',
          longitude: 2.2945,
          latitude: 48.8584,
        ),
        SelectedMapPlace(
          name: 'Louvre Museum',
          sourceLabel: 'Google',
          longitude: 2.3376,
          latitude: 48.8606,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PickedPlacesBar(
              places: places,
              onRemove: (index) {
                removedIndex = index;
              },
            ),
          ),
        ),
      );

      final deleteIcons = find.byIcon(Icons.close);
      expect(deleteIcons, findsNWidgets(2));

      await tester.tap(deleteIcons.last);
      await tester.pump();

      expect(removedIndex, 1);
    });

    testWidgets('should render with chip delete icons', (
      WidgetTester tester,
    ) async {
      const places = [
        SelectedMapPlace(
          name: 'Tour Eiffel',
          sourceLabel: 'Google',
          longitude: 2.2945,
          latitude: 48.8584,
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PickedPlacesBar(places: places, onRemove: _noop),
          ),
        ),
      );

      expect(find.byIcon(Icons.place), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  group('MapsScreen outingMode', () {
    test('should default outingMode to false', () {
      const screen = MapsScreen();
      expect(screen.outingMode, isFalse);
    });

    test('should accept outingMode true', () {
      const screen = MapsScreen(outingMode: true);
      expect(screen.outingMode, isTrue);
    });

    test('should accept addToOutingLabel', () {
      const screen = MapsScreen(addToOutingLabel: 'Ajouter à ma sortie');
      expect(screen.addToOutingLabel, 'Ajouter à ma sortie');
    });

    test('should accept onConfirmPlaces callback', () {
      var called = false;
      MapsScreen(
        onConfirmPlaces: (_) {
          called = true;
        },
      ).onConfirmPlaces?.call([]);
      expect(called, isTrue);
    });
  });
}

void _noop(int index) {}