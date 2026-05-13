import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/screens/maps/models/selected_map_place.dart';
import 'package:front/screens/maps/widgets/map_place_details_sheet.dart';

void main() {
  testWidgets('should render nothing when no place is selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildLocalizedApp(
        child: const Scaffold(
          body: MapPlaceDetailsSheet(place: null, onClose: _noop),
        ),
      ),
    );

    expect(find.byType(SizedBox), findsOneWidget);
    expect(find.byIcon(Icons.place_outlined), findsNothing);
  });

  testWidgets(
    'should render all available place details when place is selected',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildLocalizedApp(
          child: Scaffold(
            body: MapPlaceDetailsSheet(
              place: const SelectedMapPlace(
                name: 'Gare Saint-Lazare',
                sourceLabel: 'Google Places',
                longitude: 2.325551,
                latitude: 48.875247,
                address: '13 Rue d\'Amsterdam, 75008 Paris',
                rating: 4.6,
                reviewCount: 2087,
                isOpenNow: true,
                openingHours: <String>[
                  'lundi: 05:00-01:15',
                  'mardi: 05:00-01:15',
                ],
                category: 'station',
                photoAttribution: 'John Smith',
                photoUrl: 'https://example.com/place-photo.jpg',
              ),
              onClose: _noop,
            ),
          ),
        ),
      );

      expect(find.text('Gare Saint-Lazare'), findsOneWidget);
      expect(find.text('Google Places'), findsOneWidget);
      expect(find.text('station'), findsOneWidget);
      expect(find.text('4.6 (2087)'), findsOneWidget);
      expect(find.text('Ouvert'), findsOneWidget);
      expect(find.text('13 Rue d\'Amsterdam, 75008 Paris'), findsOneWidget);
      expect(find.text('lundi: 05:00-01:15'), findsOneWidget);
      expect(find.text('mardi: 05:00-01:15'), findsOneWidget);
      expect(find.text('Photo: John Smith'), findsOneWidget);
    },
  );

  testWidgets('should call onClose when close button is tapped', (
    WidgetTester tester,
  ) async {
    var didClose = false;

    await tester.pumpWidget(
      _buildLocalizedApp(
        child: Scaffold(
          body: MapPlaceDetailsSheet(
            place: const SelectedMapPlace(
              name: 'Le Barachois',
              sourceLabel: 'Lieu',
              longitude: 55.455000,
              latitude: -20.878900,
            ),
            onClose: () {
              didClose = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(didClose, isTrue);
  });
}

Widget _buildLocalizedApp({required Widget child}) {
  return MaterialApp(
    locale: const Locale('fr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void _noop() {}
