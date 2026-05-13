import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/entities/place_search_suggestion.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/screens/maps/widgets/map_place_search_panel.dart';

void main() {
  testWidgets(
    'should render suggestions when Google place results are available',
    (WidgetTester tester) async {
      final controller = TextEditingController(text: 'Louvre');

      await tester.pumpWidget(
        _buildLocalizedApp(
          child: Scaffold(
            body: MapPlaceSearchPanel(
              controller: controller,
              onSuggestionSelected: (_) {},
              onClear: () {},
              suggestions: const <PlaceSearchSuggestion>[
                PlaceSearchSuggestion(
                  placeId: 'place-1',
                  title: 'Louvre Museum',
                  subtitle: 'Paris, France',
                  fullText: 'Louvre Museum, Paris, France',
                ),
              ],
              isEnabled: true,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('Louvre Museum'), findsOneWidget);
      expect(find.text('Paris, France'), findsOneWidget);
      expect(find.text('Powered by Google'), findsOneWidget);
    },
  );
}

Widget _buildLocalizedApp({required Widget child}) {
  return MaterialApp(
    locale: const Locale('fr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}
