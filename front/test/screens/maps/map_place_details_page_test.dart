import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/screens/maps/map_place_details_page.dart';
import 'package:front/screens/maps/models/selected_map_place.dart';

void main() {
  testWidgets('should render extended place details on full screen page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildLocalizedApp(
        child: const MapPlaceDetailsPage(
          place: SelectedMapPlace(
            name: 'Gare Saint-Lazare',
            sourceLabel: 'Google Places',
            longitude: 2.325551,
            latitude: 48.875247,
            address: '13 Rue d\'Amsterdam, 75008 Paris',
            rating: 4.6,
            reviewCount: 2087,
            isOpenNow: true,
            openingHours: <String>['lundi: 05:00-01:15', 'mardi: 05:00-01:15'],
            category: 'station',
            photoAttribution: 'John Smith',
            photoUrl: 'https://example.com/place-photo.jpg',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Gare Saint-Lazare'), findsOneWidget);
    expect(find.text('Google Places'), findsOneWidget);
    expect(find.text('station'), findsOneWidget);
    expect(find.text('4.6 (2087)'), findsOneWidget);
    expect(find.text('Ouvert'), findsOneWidget);
    expect(find.text('Adresse'), findsOneWidget);
    expect(find.text('13 Rue d\'Amsterdam, 75008 Paris'), findsOneWidget);
    expect(find.text('Horaires d\'ouverture'), findsOneWidget);
    expect(find.text('lundi: 05:00-01:15'), findsOneWidget);
    expect(find.text('mardi: 05:00-01:15'), findsOneWidget);
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
