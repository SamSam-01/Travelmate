import 'package:flutter_test/flutter_test.dart';
import 'package:front/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
    );
  });

  testWidgets('CRAZER welcome page smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('CRAZER'), findsOneWidget);
    expect(find.text('Explorer sans compte'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('guest exploration opens the map page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Explorer sans compte'));
    await tester.pumpAndSettle();

    expect(find.text('Token Mapbox manquant'), findsOneWidget);
  });
}
